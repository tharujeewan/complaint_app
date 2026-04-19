const jwt = require('jsonwebtoken');
const AppError = require('./AppError');

/**
 * generateAccessToken
 * Short-lived (15m default) — used to authenticate API requests
 */
const generateAccessToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '1d',
  });
};

/**
 * generateRefreshToken
 * Long-lived (7d default) — used only to rotate access tokens
 * Stored in DB so it can be revoked
 */
const generateRefreshToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  });
};

/**
 * verifyToken
 * Wraps jwt.verify and converts JWT errors → AppError
 * so the global error handler receives a clean, typed error
 *
 * @param {string} token
 * @param {string} secret - JWT_SECRET for access, JWT_REFRESH_SECRET for refresh
 * @returns decoded payload
 * @throws AppError(401)
 */
const verifyToken = (token, secret) => {
  try {
    return jwt.verify(token, secret);
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      throw new AppError('Token expired, please login again', 401);
    }
    throw new AppError('Invalid token', 401);
  }
};

module.exports = { generateAccessToken, generateRefreshToken, verifyToken };