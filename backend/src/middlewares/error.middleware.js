const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  // Normalize defaults
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  const errors = err.errors || null;

  // Normalize known error types
  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired, please login again';
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  } else if (err.name === 'SequelizeConnectionAcquireTimeoutError') {
    statusCode = 503;
    message = 'Server is busy, please try again later';
  } else if (err.name === 'SequelizeUniqueConstraintError') {
    statusCode = 409;
    message = 'Resource already exists';
  }

  // Log structured error
  logger.error({
    message,
    statusCode,
    path: req.originalUrl,
    method: req.method,
    requestId: req.id, // correlation ID if set
    stack: process.env.NODE_ENV !== 'production' ? err.stack : undefined,
    errors,
  });

  // Send response once
  res.status(statusCode).json({
    success: false,
    message,
    ...(errors && { errors }),
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
  });
};

module.exports = { errorHandler };