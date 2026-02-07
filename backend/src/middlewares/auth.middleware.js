// src/middlewares/auth.middleware.js

const jwt = require('jsonwebtoken');

// Middleware to protect routes
const protect = (req, res, next) => {
  // Get token from Authorization header (Bearer <token>)
  const token = req.headers.authorization?.split(' ')[1];

  // If no token, return 401 Unauthorized
  if (!token) return res.status(401).json({ message: 'Not authorized' });

  try {
    // Verify token using JWT secret
    req.user = jwt.verify(token, process.env.JWT_SECRET);

    // If valid, allow next middleware/controller
    next();
  } catch (error) {
    // If token invalid, return 401
    res.status(401).json({ message: 'Invalid token' });
  }
};

module.exports = { protect };
