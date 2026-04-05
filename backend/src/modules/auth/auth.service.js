const User = require('./auth.model');
const bcrypt = require('bcrypt');
const { generateAccessToken, generateRefreshToken, verifyToken } = require('../../utils/jwt');

const registerUser = async ({ name, email, password }) => {
  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) {
    throw new Error('Email already registered');
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const user = await User.create({ name, email, password: hashedPassword });
  
  const token = generateAccessToken({ id: user.id, role: user.role });
  const refreshToken = generateRefreshToken({ id: user.id, role: user.role });
  
  return { token, refreshToken, user: { id: user.id, name: user.name, email: user.email, role: user.role } };
};

const loginUser = async ({ email, password }) => {
  const user = await User.findOne({ where: { email } });
  if (!user) throw new Error('Invalid credentials');

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new Error('Invalid credentials');

  const token = generateAccessToken({ id: user.id, role: user.role });
  const refreshToken = generateRefreshToken({ id: user.id, role: user.role });

  return { token, refreshToken, user: { id: user.id, name: user.name, email: user.email, role: user.role } };
};

// Get all users (excluding passwords)
const getAllUsers = async () => {
  const users = await User.findAll({
    attributes: { exclude: ['password'] }
  });
  return users;
};

// Get a single user by ID
const getUserById = async (id) => {
  const user = await User.findByPk(id, {
    attributes: { exclude: ['password'] }
  });
  if (!user) throw new Error('User not found');
  return user;
};

// Update user by ID
const updateUser = async (id, updates) => {
  const user = await User.findByPk(id);
  if (!user) throw new Error('User not found');

  // If password is being updated, hash it
  if (updates.password) {
    updates.password = await bcrypt.hash(updates.password, 10);
  }

  await user.update(updates);
  return { id: user.id, name: user.name, email: user.email, role: user.role };
};

// Delete user by ID
const deleteUser = async (id) => {
  const user = await User.findByPk(id);
  if (!user) throw new Error('User not found');

  await user.destroy();
  return { message: 'User deleted successfully' };
};

// Refresh token service
const refreshAuthToken = async (refreshToken) => {
  if (!refreshToken) throw new Error('Refresh token is required');
  try {
    const decoded = verifyToken(refreshToken);
    const user = await User.findByPk(decoded.id);
    if (!user) throw new Error('User not found');
    
    const newAccessToken = generateAccessToken({ id: user.id, role: user.role });
    const newRefreshToken = generateRefreshToken({ id: user.id, role: user.role });
    
    return { token: newAccessToken, refreshToken: newRefreshToken };
  } catch (error) {
    throw new Error('Invalid or expired refresh token');
  }
};

module.exports = { registerUser, loginUser, getAllUsers, getUserById, updateUser, deleteUser, refreshAuthToken };
