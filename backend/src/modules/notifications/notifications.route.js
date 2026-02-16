const express = require('express');
const router = express.Router();
const { getNotifications, markAsRead } = require('./notifications.controller');
const { protect } = require('../../middlewares/auth.middleware');

router.use(protect);
router.get('/', getNotifications);
router.put('/:id/read', markAsRead);

module.exports = router;
