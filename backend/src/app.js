// src/app.js

const express = require('express');          // Import Express
const cors = require('cors');                // Import CORS middleware
const authRoutes = require('./modules/auth/auth.route'); // Import auth routes

const app = express(); // Create Express app instance

app.use(cors());        // Enable CORS for all routes
app.use(express.json()); // Parse JSON body automatically

// Mount auth routes at /api/auth
app.use('/api/auth', authRoutes);
const complaintsRoutes = require('./modules/complaints/complaints.route');
const notificationsRoutes = require('./modules/notifications/notifications.route');

app.use('/api/complaints', complaintsRoutes);
app.use('/api/notifications', notificationsRoutes);

// Export app for server.js to run
module.exports = app;
