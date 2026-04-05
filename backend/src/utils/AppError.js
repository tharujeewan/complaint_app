/**
 * AppError - Custom error class for operational errors
 *
 * isOperational = true  → expected errors (invalid input, not found, unauthorized)
 * isOperational = false → programmer bugs (caught by unhandledRejection)
 *
 * Every service/middleware throws this instead of plain new Error()
 * so statusCode travels correctly to the global error handler without
 * the controller ever needing to set or overwrite it.
 *
 * Usage:
 *   throw new AppError('Email already registered', 409);
 *   throw new AppError('User not found', 404);
 *   throw new AppError('Forbidden', 403);
 */
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    // Keeps stack trace clean — excludes AppError constructor itself
    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;