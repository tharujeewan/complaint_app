// src/middlewares/auth.middleware.js
const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

/**
 * protect - Middleware to protect routes
 * 1. Checks Authorization header for JWT token
 * 2. Verifies token
 * 3. Populates req.user if valid
 */
const protect = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    const error = new Error('Not authorized, no token provided');
    error.statusCode = 401;
    logger.warn('Unauthorized access attempt on %s %s', req.method, req.originalUrl);
    return next(error);
  }

  const token = authHeader.split(' ')[1]?.trim();

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      error.message = 'Token expired, please login again';
      error.statusCode = 401;
    } else if (error.name === 'JsonWebTokenError') {
      error.message = 'Invalid token';
      error.statusCode = 401;
    }

    logger.warn('JWT Error on %s %s: %s', req.method, req.originalUrl, error.message);
    next(error);
  }
};

module.exports = { protect };