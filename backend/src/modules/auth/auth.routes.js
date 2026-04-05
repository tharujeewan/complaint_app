const express = require('express');
const router = express.Router();
const { register, login, getAll, getById, getMe, update, remove, refreshTokenHandler } = require('./auth.controller');
const validate = require('../../middlewares/validate');
const { protect } = require('../../middlewares/auth.middleware');
const { registerSchema, loginSchema, updateUserSchema } = require('./auth.validator');

// Public routes
router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);
router.post('/refresh', refreshTokenHandler);

// Protected routes
router.get('/', protect, getAll);
router.get('/me', protect, getMe);
router.get('/:id', protect, getById);
router.put('/:id', protect, validate(updateUserSchema), update);
router.delete('/:id', protect, remove);

module.exports = router;
