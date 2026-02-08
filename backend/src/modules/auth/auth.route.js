// src/modules/auth/auth.routes.js

// Import express router
const express = require('express');
const router = express.Router();

// Import controllers
const { register, login } = require('./auth.controller');
const validate = require('../../middlewares/validate');
const { registerSchema, loginSchema } = require('./auth.validator');

// Define POST route for registration
router.post('/register', validate(registerSchema), register);

// Define POST route for login
router.post('/login', validate(loginSchema), login);

// Export router to be used in app.js
module.exports = router;
