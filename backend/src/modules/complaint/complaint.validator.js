const Joi = require('joi');

const createComplaintSchema = Joi.object({
  title: Joi.string().required().messages({
    'string.base': 'Title should be a type of text',
    'string.empty': 'Title cannot be an empty field',
    'any.required': 'Title is a required field'
  }),
  description: Joi.string().required(),
  location: Joi.string().optional(),
  status: Joi.string().valid('pending', 'resolved', 'rejected').default('pending')
});

module.exports = { createComplaintSchema };
