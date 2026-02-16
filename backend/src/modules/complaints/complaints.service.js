const Complaint = require('./complaints.model');
const { addNotificationJob } = require('../notifications/notifications.service');

const createComplaint = async ({ title, description, user_id, location, photo }) => {
  const complaint = await Complaint.create({
    title,
    description,
    user_id,
    location,
    photo
  });

  // Trigger Notification
  try {
      await addNotificationJob({
          title: complaint.title,
          description: complaint.description,
          type: 'info'
      });
  } catch (error) {
      console.error('Failed to trigger notification:', error);
  }

  return complaint;
};

const getAllComplaints = async () => {
    return await Complaint.findAll();
};

module.exports = { createComplaint, getAllComplaints };
