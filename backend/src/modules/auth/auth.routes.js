const express = require('express');
const router = express.Router();

const {
  register, login, getAll, getById, getMe,
  update, remove, refreshTokenHandler, logout, logoutAll,
} = require('./auth.controller');

const validate = require('../../middlewares/validate');
const { protect, authorize } = require('../../middlewares/auth.middleware');
const {
  registerSchema,
  loginSchema,
  updateUserSchema,
  refreshTokenSchema,
} = require('./auth.validator');

// ─────────────────────────────────────────────────────────────────────────────
// Public routes — no token required
// ─────────────────────────────────────────────────────────────────────────────

// POST /api/auth/register
router.post('/register', validate(registerSchema), register);

// POST /api/auth/login
router.post('/login', validate(loginSchema), login);

// POST /api/auth/refresh — validate body then rotate tokens
router.post('/refresh', validate(refreshTokenSchema), refreshTokenHandler);

// POST /api/auth/logout
// No protect — access token may be expired at logout time, refresh token is enough
router.post('/logout', logout);

// ─────────────────────────────────────────────────────────────────────────────
// Authenticated routes — valid access token required
// ─────────────────────────────────────────────────────────────────────────────

// POST /api/auth/logout-all — revoke all sessions for current user
router.post('/logout-all', protect, logoutAll);

// GET /api/auth/me — own profile
router.get('/me', protect, getMe);

// PUT /api/auth/:id — update account
// Ownership + role escalation enforced in service, not here
router.put('/:id', protect, validate(updateUserSchema), update);

// DELETE /api/auth/:id — delete account
// Ownership enforced in service
router.delete('/:id', protect, remove);

// ─────────────────────────────────────────────────────────────────────────────
// Admin-only routes
// ─────────────────────────────────────────────────────────────────────────────

// GET /api/auth/ — list all users (paginated)
router.get('/', protect, authorize('admin'), getAll);

// GET /api/auth/:id — get any user by ID
router.get('/:id', protect, authorize('admin'), getById);

module.exports = router;