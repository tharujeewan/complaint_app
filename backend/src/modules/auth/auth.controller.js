// src/modules/auth/auth.controller.js

// Import service functions
const { registerUser, loginUser, getAllUsers, getUserById, updateUser, deleteUser, refreshAuthToken } = require('./auth.service');

const register = async (req, res, next) => {
  try {
    const data = await registerUser(req.body);
    res.status(201).json({ success: true, ...data });
  } catch (error) {
    error.statusCode = 400;
    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const data = await loginUser(req.body);
    res.status(200).json({ success: true, ...data });
  } catch (error) {
    error.statusCode = 401;
    next(error);
  }
};

const getAll = async (req, res, next) => {
  try {
    const users = await getAllUsers();
    res.status(200).json({ success: true, users });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};

const getById = async (req, res, next) => {
  try {
    const user = await getUserById(req.params.id);
    res.status(200).json({ success: true, user });
  } catch (error) {
    error.statusCode = 404;
    next(error);
  }
};

const getMe = async (req, res, next) => {
  try {
    const user = await getUserById(req.user.id);
    res.status(200).json({ success: true, user });
  } catch (error) {
    error.statusCode = 404;
    next(error);
  }
};

const update = async (req, res, next) => {
  try {
    const user = await updateUser(req.params.id, req.body);
    res.status(200).json({ success: true, user });
  } catch (error) {
    error.statusCode = 400;
    next(error);
  }
};

const remove = async (req, res, next) => {
  try {
    const result = await deleteUser(req.params.id);
    res.status(200).json({ success: true, ...result });
  } catch (error) {
    error.statusCode = 404;
    next(error);
  }
};

const refreshTokenHandler = async (req, res, next) => {
  try {
    const tokens = await refreshAuthToken(req.body.refreshToken);
    res.status(200).json({ success: true, ...tokens });
  } catch (error) {
    error.statusCode = 401;
    next(error);
  }
};

// Export controllers for routes to use
module.exports = { register, login, getAll, getById, getMe, update, remove, refreshTokenHandler };
