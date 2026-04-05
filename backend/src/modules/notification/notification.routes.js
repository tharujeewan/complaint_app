const express = require('express');
const router = express.Router();
const { getNotifications, markAsRead } = require('./notification.controller');
const { protect } = require('../../middlewares/auth.middleware');

// All notification routes are protected
router.use(protect);

// GET /api/notifications — Get user notifications
router.get('/', getNotifications);

// PUT /api/notifications/:id/read — Mark as read
router.put('/:id/read', markAsRead);

module.exports = router;
