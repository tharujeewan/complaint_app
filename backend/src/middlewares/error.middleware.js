const logger = require('../utils/logger');

/**
 * errorHandler - Global centralized error handler
 *
 * Flow: normalize → log → respond (single path, no early returns)
 *
 * Never called directly — Express invokes it automatically when
 * next(err) is called from any route, controller, or middleware.
 *
 * Registered LAST in app.js after all routes.
 */
const errorHandler = (err, req, res, next) => {
  const isProduction = process.env.NODE_ENV === 'production';

  // ─── Step 1: Normalize defaults ───────────────────────────────────────────
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  const errors = err.errors || null; // Joi field-level errors

  // ─── Step 2: Normalize known third-party error types ──────────────────────
  // These arrive without a statusCode because they're thrown by libraries,
  // not by our AppError. We normalize them here into clean HTTP responses.

  // JWT errors (when errorHandler receives them directly — normally caught in auth.middleware)
  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired, please login again';
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  }

  // Sequelize errors
  else if (err.name === 'SequelizeUniqueConstraintError') {
    statusCode = 409;
    const field = err.errors?.[0]?.path || 'field';
    // Capitalizes field name: "email" → "Email already exists"
    message = `${field.charAt(0).toUpperCase() + field.slice(1)} already exists`;
  } else if (err.name === 'SequelizeValidationError') {
    // Model-level validation (separate from Joi — e.g. isEmail on model)
    statusCode = 400;
    message = err.errors.map((e) => e.message).join(', ');
  } else if (err.name === 'SequelizeConnectionAcquireTimeoutError') {
    statusCode = 503;
    message = 'Server is busy, please try again later';
  }

  // Body parser payload size exceeded
  else if (err.type === 'entity.too.large') {
    statusCode = 413;
    message = 'Request payload too large';
  }

  // ─── Step 3: Single structured log point ──────────────────────────────────
  // Structured object → queryable in any log aggregator
  const logPayload = {
    message,
    statusCode,
    method: req.method,
    path: req.originalUrl,
    requestId: req.id,             // Set by requestId.middleware.js
    userId: req.user?.id || null,  // Populated by protect middleware if authed
    operational: err.isOperational ?? false,
  };

  // Non-operational (unexpected) errors are bugs — log full stack always
  if (!err.isOperational) {
    logPayload.stack = err.stack;
  } else if (!isProduction) {
    logPayload.stack = err.stack;
  }

  if (errors) logPayload.errors = errors;

  // 5xx → error level, 4xx → warn level (4xx are user mistakes, not system faults)
  if (statusCode >= 500) {
    logger.error(logPayload);
  } else {
    logger.warn(logPayload);
  }

  // ─── Step 4: Single response point ────────────────────────────────────────
  return res.status(statusCode).json({
    success: false,
    message,
    ...(errors && { errors }),
    // Never expose stack traces in production
    ...(!isProduction && { stack: err.stack }),
  });
};

module.exports = { errorHandler };