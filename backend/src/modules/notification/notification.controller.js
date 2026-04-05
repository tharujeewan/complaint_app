const Notification = require('./notification.model');

const getNotifications = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const notifications = await Notification.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']]
    });
    res.status(200).json({ success: true, notifications });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};

const markAsRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const notification = await Notification.findOne({ where: { id, userId } });
    if (!notification) {
      const error = new Error('Notification not found');
      error.statusCode = 404;
      return next(error);
    }

    notification.isRead = true;
    await notification.save();

    res.status(200).json({ success: true, message: 'Notification marked as read' });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};

module.exports = { getNotifications, markAsRead };
