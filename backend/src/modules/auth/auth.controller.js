// src/modules/auth/auth.controller.js

// Import service functions
const { registerUser, loginUser } = require('./auth.service');

// Controller for user registration
const register = async (req, res) => {
  try {
    const user = await registerUser(req.body);   // Call service with request body
    res.status(201).json({ success: true, user }); // Send success response
  } catch (error) {
    res.status(400).json({ success: false, message: error.message }); // Send error
  }
};

// Controller for user login
const login = async (req, res) => {
  try {
    const data = await loginUser(req.body);     // Call login service
    res.status(200).json({ success: true, ...data }); // Send token back
  } catch (error) {
    res.status(401).json({ success: false, message: error.message }); // Send error
  }
};

// Export controllers for routes to use
module.exports = { register, login };
