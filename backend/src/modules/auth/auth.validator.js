const Joi = require('joi');

/**
 * Reusable password rule
 * - Min 8 chars (NIST recommends 8 as minimum)
 * - Max 72 chars (bcrypt silently truncates at 72 — prevent surprises)
 * - At least one uppercase, one lowercase, one digit
 */
const passwordRule = Joi.string()
  .min(8)
  .max(72)
  .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  .label('Password');

// ─────────────────────────────────────────────────────────────────────────────

const registerSchema = Joi.object({
  name: Joi.string().min(3).max(100).required().label('Name').messages({
    'string.min': 'Name must be at least 3 characters',
    'string.max': 'Name cannot exceed 100 characters',
    'any.required': 'Name is required',
  }),
  email: Joi.string().email().max(255).required().label('Email').messages({
    'string.email': 'Please enter a valid email address',
    'any.required': 'Email is required',
  }),
  password: passwordRule.required().messages({
    'string.min': 'Password must be at least 8 characters',
    'string.max': 'Password cannot exceed 72 characters',
    'string.pattern.base':
      'Password must contain at least one uppercase letter, one lowercase letter, and one number',
    'any.required': 'Password is required',
  }),
  // Users cannot self-assign admin — enforced here AND again in service layer
  role: Joi.string().valid('user').default('user'),
});

// ─────────────────────────────────────────────────────────────────────────────

const loginSchema = Joi.object({
  email: Joi.string().email().required().label('Email').messages({
    'string.email': 'Please enter a valid email address',
    'any.required': 'Email is required',
  }),
  password: Joi.string().required().label('Password').messages({
    'any.required': 'Password is required',
  }),
});

// ─────────────────────────────────────────────────────────────────────────────

const updateUserSchema = Joi.object({
  name: Joi.string().min(3).max(100).label('Name').messages({
    'string.min': 'Name must be at least 3 characters',
    'string.max': 'Name cannot exceed 100 characters',
  }),
  email: Joi.string().email().max(255).label('Email').messages({
    'string.email': 'Please enter a valid email address',
  }),
  // Both required together — .with() enforces this
  currentPassword: Joi.string().label('Current Password'),
  newPassword: passwordRule
    .invalid(Joi.ref('currentPassword')) // New password must differ from old
    .label('New Password')
    .messages({
      'any.invalid': 'New password must be different from current password',
      'string.pattern.base':
        'Password must contain at least one uppercase letter, one lowercase letter, and one number',
    }),
  // Only admin can set this — service enforces it, schema just types it
  role: Joi.string().valid('user', 'admin').label('Role'),
})
  .min(1) // Reject empty body
  .with('newPassword', 'currentPassword') // newPassword requires currentPassword
  .messages({
    'object.min': 'At least one field must be provided for update',
    'object.with': 'Current password is required when setting a new password',
  });

// ─────────────────────────────────────────────────────────────────────────────

const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string().required().label('Refresh Token').messages({
    'any.required': 'Refresh token is required',
  }),
});

module.exports = { registerSchema, loginSchema, updateUserSchema, refreshTokenSchema };