const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, {
    abortEarly: false, // return all errors
  });

  if (error) {
    const errorDetails = {};

    error.details.forEach((detail) => {
      const field = detail.path[0];

      // Store message separately for each field
      errorDetails[field] = detail.message.replace(/"/g, "");
    });

    return res.status(400).json({
      success: false,
      message: "Validation Error",
      errors: errorDetails,
    });
  }

  next();
};

module.exports = validate;
