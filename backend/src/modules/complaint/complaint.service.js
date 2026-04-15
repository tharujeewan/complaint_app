const Complaint = require('./complaint.model');
const { addNotificationJob } = require('../notification/notification.service');

const { Op } = require('sequelize');

const createComplaint = async ({ title, description, user_id, location, photo }) => {
  const complaint = await Complaint.create({
    title,
    description,
    user_id,
    location,
    photo
  });

  // Trigger notification via BullMQ
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

const getAllComplaints = async ({ search, status } = {}) => {
  const whereClause = {};

  if (status && status !== 'all') {
    whereClause.status = status.toLowerCase();
  }

  if (search) {
    whereClause[Op.or] = [
      { title: { [Op.iLike]: `%${search}%` } },
      { description: { [Op.iLike]: `%${search}%` } },
      { location: { [Op.iLike]: `%${search}%` } }
    ];
  }

  return await Complaint.findAll({
    where: whereClause,
    order: [['created_at', 'DESC']]
  });
};

const updateComplaintStatus = async (id, status) => {
  const complaint = await Complaint.findByPk(id);
  if (!complaint) throw new Error('Complaint not found');

  complaint.status = status;

  // Track timestamps based on status
  if (status === 'in progress') {
    complaint.in_progress_at = new Date();
  } else if (status === 'resolved') {
    complaint.resolved_at = new Date();
  }

  await complaint.save();
  return complaint;
};

module.exports = { createComplaint, getAllComplaints, updateComplaintStatus };
