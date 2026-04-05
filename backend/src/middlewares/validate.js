// src/middlewares/validate.js
const logger = require('../utils/logger');

/**
 * validate - Middleware to validate request body using Joi schema
 * @param schema - Joi validation schema
 */
const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, { abortEarly: false });

  if (error) {
    const errorDetails = {};
    error.details.forEach((detail) => {
      const field = detail.path.join('.') || detail.path[0]; // support nested fields
      errorDetails[field] = detail.message.replace(/"/g, '');
    });

    const err = new Error('Validation Error');
    err.statusCode = 400;
    err.errors = errorDetails;

    // Log validation error
    logger.warn('Validation Error on %s %s: %o', req.method, req.originalUrl, errorDetails);

    return next(err); // Pass to global error handler
  }

  next(); // Validation passed
};

module.exports = validate;