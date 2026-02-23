// src/modules/auth/auth.routes.js

// Import express router
const express = require('express');
const router = express.Router();

// Import controllers
const { register, login, getAll, getById, update, remove } = require('./auth.controller');
const validate = require('../../middlewares/validate');
const { protect } = require('../../middlewares/auth.middleware');
const { registerSchema, loginSchema, updateUserSchema } = require('./auth.validator');

// Define POST route for registration
router.post('/register', validate(registerSchema), register);

// Define POST route for login
router.post('/login', validate(loginSchema), login);

// Get all users (protected)
router.get('/', protect, getAll);

// Get user by ID (protected)
router.get('/:id', protect, getById);

// Update user by ID (protected)
router.put('/:id', protect, validate(updateUserSchema), update);

// Delete user by ID (protected)
router.delete('/:id', protect, remove);

// Export router to be used in app.js
module.exports = router;
