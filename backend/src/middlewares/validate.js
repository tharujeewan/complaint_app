// src/middlewares/validate.js
const AppError = require('../utils/AppError');
const logger = require('../utils/logger');

/**
 * validate - Middleware factory for Joi schema validation
 *
 * Validates req.body, req.query, or req.params depending on target.
 * Collects ALL errors at once (abortEarly: false).
 * Strips unknown fields silently (stripUnknown: true).
 *
 * @param {object} schema  - Joi schema
 * @param {string} target  - 'body' | 'query' | 'params'  (default: 'body')
 *
 * Usage:
 *   router.post('/register', validate(registerSchema), register)
 *   router.get('/users', validate(querySchema, 'query'), getAll)
 *   router.get('/users/:id', validate(paramsSchema, 'params'), getById)
 */
const validate = (schema, target = 'body') => (req, res, next) => {
  const { error, value } = schema.validate(req[target], {
    abortEarly: false,   // Collect all errors, not just the first
    stripUnknown: true,  // Remove fields not in schema — prevents mass assignment
    convert: true,       // Auto-coerce types (e.g. "3" → 3 for integers)
  });

  if (error) {
    const errorDetails = {};

    error.details.forEach((detail) => {
      // join('.') handles nested paths: "address.city", not just "address"
      const field = detail.path.join('.');
      // Joi .label() on schema fields produces clean messages without quotes
      errorDetails[field] = detail.message;
    });

    logger.warn({
      message: 'Validation failed',
      method: req.method,
      path: req.originalUrl,
      requestId: req.id,
      target,
      errors: errorDetails,
    });

    const err = new AppError('Validation Error', 400);
    err.errors = errorDetails;
    return next(err);
  }

  // Replace req[target] with the sanitized/coerced value from Joi
  req[target] = value;
  next();
};

module.exports = validate;