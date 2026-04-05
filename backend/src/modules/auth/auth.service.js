const bcrypt = require('bcrypt');
const { Op } = require('sequelize');
const User = require('./auth.model');
const RefreshToken = require('./refreshToken.model');
const AppError = require('../../utils/AppError');
const { generateAccessToken, generateRefreshToken, verifyToken } = require('../../utils/jwt');
const logger = require('../../utils/logger');

const BCRYPT_ROUNDS = 12; // 10 = minimum acceptable, 12 = production standard
const REFRESH_TOKEN_EXPIRY_DAYS = 7;

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

/**
 * sanitizeUser — strips any sensitive fields before sending to client
 * Even though defaultScope excludes password, this makes the contract explicit
 */
const sanitizeUser = (user) => ({
  id: user.id,
  name: user.name,
  email: user.email,
  role: user.role,
  created_at: user.created_at,
  updated_at: user.updated_at,
});

/**
 * issueTokens
 * Generates both tokens and persists the refresh token to DB.
 * Called on register, login, and token rotation.
 *
 * WHY persist refresh token:
 * Without DB storage, refresh tokens can never be revoked.
 * A stolen token would give an attacker indefinite access until expiry.
 */
const issueTokens = async (user) => {
  const payload = { id: user.id, role: user.role };
  const accessToken = generateAccessToken(payload);
  const refreshToken = generateRefreshToken(payload);

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_EXPIRY_DAYS);

  await RefreshToken.create({ token: refreshToken, userId: user.id, expiresAt });

  return { accessToken, refreshToken };
};

// ─────────────────────────────────────────────────────────────────────────────

const registerUser = async ({ name, email, password }) => {
  // Explicit check before hitting DB unique constraint
  // Gives cleaner 409 vs letting SequelizeUniqueConstraintError bubble up
  const existing = await User.unscoped().findOne({ where: { email } });
  if (existing) throw new AppError('Email already registered', 409);

  const hashedPassword = await bcrypt.hash(password, BCRYPT_ROUNDS);

  // Force role = 'user' regardless of what came in the request body
  // Validator already blocks non-user roles, but defense-in-depth matters
  const user = await User.create({ name, email, password: hashedPassword, role: 'user' });

  logger.info({ message: 'User registered', userId: user.id, email: user.email });

  const tokens = await issueTokens(user);
  return { ...tokens, user: sanitizeUser(user) };
};

// ─────────────────────────────────────────────────────────────────────────────

const loginUser = async ({ email, password }) => {
  // Must use withPassword scope — defaultScope excludes password column
  const user = await User.scope('withPassword').findOne({ where: { email } });

  // Generic message for both cases — don't reveal whether the email exists
  if (!user) throw new AppError('Invalid credentials', 401);

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new AppError('Invalid credentials', 401);

  logger.info({ message: 'User logged in', userId: user.id });

  const tokens = await issueTokens(user);
  return { ...tokens, user: sanitizeUser(user) };
};

// ─────────────────────────────────────────────────────────────────────────────

/**
 * getAllUsers — paginated
 *
 * WHY paginate:
 * Without pagination, a single request could return millions of rows,
 * crash the server, and expose all user data in one response.
 */
const getAllUsers = async ({ page = 1, limit = 20 } = {}) => {
  // Clamp values to prevent abuse (e.g. limit=999999)
  const safeLimit = Math.min(Math.max(parseInt(limit, 10) || 20, 1), 100);
  const safePage = Math.max(parseInt(page, 10) || 1, 1);
  const offset = (safePage - 1) * safeLimit;

  const { count, rows } = await User.findAndCountAll({
    limit: safeLimit,
    offset,
    order: [['created_at', 'DESC']],
  });

  return {
    total: count,
    page: safePage,
    limit: safeLimit,
    totalPages: Math.ceil(count / safeLimit),
    users: rows,
  };
};

// ─────────────────────────────────────────────────────────────────────────────

const getUserById = async (id) => {
  const user = await User.findByPk(id);
  if (!user) throw new AppError('User not found', 404);
  return sanitizeUser(user);
};

// ─────────────────────────────────────────────────────────────────────────────

/**
 * updateUser
 *
 * Security enforced here (not just in routes):
 * 1. IDOR prevention — non-admins can only update themselves
 * 2. Role escalation prevention — only admins can change roles
 * 3. Password change requires current password verification
 *
 * @param {string|number} id        - Target user ID from route params
 * @param {object}        updates   - Validated fields from req.body
 * @param {object}        requester - req.user (decoded JWT payload)
 */
const updateUser = async (id, updates, requester) => {
  // Fetch with password for potential password change verification
  const user = await User.scope('withPassword').findByPk(id);
  if (!user) throw new AppError('User not found', 404);

  // IDOR check — non-admins cannot update other users
  if (requester.role !== 'admin' && requester.id !== user.id) {
    throw new AppError('Forbidden: you can only update your own account', 403);
  }

  // Role escalation check — only admins can change roles
  if (updates.role !== undefined && requester.role !== 'admin') {
    throw new AppError('Forbidden: only admins can change roles', 403);
  }

  // Password change flow — requires current password verification
  if (updates.newPassword) {
    const isMatch = await bcrypt.compare(updates.currentPassword, user.password);
    if (!isMatch) throw new AppError('Current password is incorrect', 400);
    updates.password = await bcrypt.hash(updates.newPassword, BCRYPT_ROUNDS);
  }

  // Strip fields that must not be passed directly to model.update()
  const { newPassword, currentPassword, ...safeUpdates } = updates;

  await user.update(safeUpdates);

  logger.info({ message: 'User updated', targetUserId: user.id, updatedBy: requester.id });

  return sanitizeUser(user);
};

// ─────────────────────────────────────────────────────────────────────────────

/**
 * deleteUser
 *
 * IDOR check: only admins or the user themselves can delete an account.
 * RefreshToken rows are deleted via DB CASCADE.
 *
 * @param {string|number} id        - Target user ID
 * @param {object}        requester - req.user
 */
const deleteUser = async (id, requester) => {
  const user = await User.findByPk(id);
  if (!user) throw new AppError('User not found', 404);

  if (requester.role !== 'admin' && requester.id !== user.id) {
    throw new AppError('Forbidden: you can only delete your own account', 403);
  }

  await user.destroy(); // CASCADE removes refresh_tokens rows

  logger.info({ message: 'User deleted', targetUserId: user.id, deletedBy: requester.id });

  return { message: 'User deleted successfully' };
};

// ─────────────────────────────────────────────────────────────────────────────

/**
 * refreshAuthToken — Token rotation
 *
 * Flow:
 * 1. Verify JWT signature and expiry
 * 2. Look up token in DB — reject if not found or already revoked
 * 3. Revoke old token (prevents reuse — rotation pattern)
 * 4. Issue new access + refresh token pair
 *
 * WHY rotation:
 * If a refresh token is stolen, rotating it means the attacker's copy
 * becomes invalid the next time the legitimate user refreshes.
 */
const refreshAuthToken = async (incomingToken) => {
  // Throws AppError(401) if expired or invalid
  const decoded = verifyToken(incomingToken, process.env.JWT_REFRESH_SECRET);

  // Verify it exists in DB and hasn't been revoked
  const stored = await RefreshToken.findOne({
    where: {
      token: incomingToken,
      revoked: false,
      expiresAt: { [Op.gt]: new Date() },
    },
  });

  if (!stored) {
    // Could indicate token reuse after revocation → possible theft
    logger.warn({
      message: 'Refresh token reuse attempt or revoked token used',
      userId: decoded.id,
    });
    throw new AppError('Refresh token is invalid or has been revoked', 401);
  }

  const user = await User.findByPk(decoded.id);
  if (!user) throw new AppError('User no longer exists', 401);

  // Revoke old token before issuing new one
  await stored.update({ revoked: true });

  const tokens = await issueTokens(user);
  return tokens;
};

// ─────────────────────────────────────────────────────────────────────────────

/**
 * logoutUser — Revoke a single refresh token
 * Idempotent — succeeds even if token not found (already revoked or never existed)
 */
const logoutUser = async (refreshToken) => {
  if (!refreshToken) throw new AppError('Refresh token is required', 400);

  const stored = await RefreshToken.findOne({ where: { token: refreshToken } });
  if (stored) await stored.update({ revoked: true });

  return { message: 'Logged out successfully' };
};

// ─────────────────────────────────────────────────────────────────────────────

/**
 * logoutAllDevices — Revoke every active refresh token for a user
 * Use case: password change, suspected compromise, security lockdown
 */
const logoutAllDevices = async (userId) => {
  await RefreshToken.update(
    { revoked: true },
    { where: { userId, revoked: false } }
  );

  logger.info({ message: 'All sessions revoked', userId });

  return { message: 'Logged out from all devices' };
};

// ─────────────────────────────────────────────────────────────────────────────

module.exports = {
  registerUser,
  loginUser,
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  refreshAuthToken,
  logoutUser,
  logoutAllDevices,
};