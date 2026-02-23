// src/modules/auth/auth.controller.js

// Import service functions
const { registerUser, loginUser, getAllUsers, getUserById, updateUser, deleteUser } = require('./auth.service');

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

// Controller to get all users
const getAll = async (req, res) => {
  try {
    const users = await getAllUsers();
    res.status(200).json({ success: true, users });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Controller to get user by ID
const getById = async (req, res) => {
  try {
    const user = await getUserById(req.params.id);
    res.status(200).json({ success: true, user });
  } catch (error) {
    res.status(404).json({ success: false, message: error.message });
  }
};

// Controller to update user
const update = async (req, res) => {
  try {
    const user = await updateUser(req.params.id, req.body);
    res.status(200).json({ success: true, user });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// Controller to delete user
const remove = async (req, res) => {
  try {
    const result = await deleteUser(req.params.id);
    res.status(200).json({ success: true, ...result });
  } catch (error) {
    res.status(404).json({ success: false, message: error.message });
  }
};

// Export controllers for routes to use
module.exports = { register, login, getAll, getById, update, remove };
