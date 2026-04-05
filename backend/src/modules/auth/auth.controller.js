// src/modules/auth/auth.controller.js

// Import service functions
const {
  registerUser,
  loginUser,
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  refreshAuthToken,
  logoutUser,
  logoutAllDevices,
} = require('./auth.service');

/**
 * Auth controllers — intentionally thin
 *
 * Each controller does exactly three things:
 *   1. Extract data from req (params, body, user)
 *   2. Call the service function
 *   3. Send the response
 *
 * No business logic lives here.
 * No statusCode is set on errors here — AppError in the service carries it.
 * All errors are passed to next() for the global error handler.
 */

const register = async (req, res, next) => {
  try {
    const data = await registerUser(req.body);
    res.status(201).json({ success: true, ...data });
  } catch (err) {
    next(err);
  }
};

const login = async (req, res, next) => {
  try {
    const data = await loginUser(req.body);
    res.status(200).json({ success: true, ...data });
  } catch (err) {
    next(err);
  }
};

const getAll = async (req, res, next) => {
  try {
    const data = await getAllUsers({ page: req.query.page, limit: req.query.limit });
    res.status(200).json({ success: true, ...data });
  } catch (err) {
    next(err);
  }
};

const getById = async (req, res, next) => {
  try {
    const user = await getUserById(req.params.id);
    res.status(200).json({ success: true, user });
  } catch (err) {
    next(err);
  }
};

// GET /me — returns the currently authenticated user's profile
const getMe = async (req, res, next) => {
  try {
    const user = await getUserById(req.user.id);
    res.status(200).json({ success: true, user });
  } catch (err) {
    next(err);
  }
};

const update = async (req, res, next) => {
  try {
    // Pass req.user so service can enforce IDOR and role escalation checks
    const user = await updateUser(req.params.id, req.body, req.user);
    res.status(200).json({ success: true, user });
  } catch (err) {
    next(err);
  }
};

const remove = async (req, res, next) => {
  try {
    // Pass req.user so service can enforce ownership check
    const result = await deleteUser(req.params.id, req.user);
    res.status(200).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
};

const refreshTokenHandler = async (req, res, next) => {
  try {
    const tokens = await refreshAuthToken(req.body.refreshToken);
    res.status(200).json({ success: true, ...tokens });
  } catch (err) {
    next(err);
  }
};

const logout = async (req, res, next) => {
  try {
    const result = await logoutUser(req.body.refreshToken);
    res.status(200).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
};

const logoutAll = async (req, res, next) => {
  try {
    const result = await logoutAllDevices(req.user.id);
    res.status(200).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  register,
  login,
  getAll,
  getById,
  getMe,
  update,
  remove,
  refreshTokenHandler,
  logout,
  logoutAll,
};