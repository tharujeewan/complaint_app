const express = require('express');
const cors = require('cors');
const path = require('path');

// Route imports
const authRoutes = require('./modules/auth/auth.routes');
const complaintRoutes = require('./modules/complaint/complaint.routes');
const notificationRoutes = require('./modules/notification/notification.routes');

// Middleware imports
const { errorHandler } = require('./middlewares/error.middleware');

const app = express();

// Global middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/complaints', complaintRoutes);
app.use('/api/notifications', notificationRoutes);

// Global error handler (must be last)
app.use(errorHandler);

module.exports = app;
