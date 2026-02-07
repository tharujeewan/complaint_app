// src/modules/auth/auth.routes.js

// Import express router
const express = require('express');
const router = express.Router();

// Import controllers
const { register, login } = require('./auth.controller');

// Define POST route for registration
router.post('/register', register);

// Define POST route for login
router.post('/login', login);

// Export router to be used in app.js
module.exports = router;
