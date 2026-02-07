const Complaint = require('./complaints.model');

const createComplaint = async ({ title, description, user_id, location, photo }) => {
  const complaint = await Complaint.create({
    title,
    description,
    user_id,
    location,
    photo
  });
  return complaint;
};

const getAllComplaints = async () => {
    return await Complaint.findAll();
};

module.exports = { createComplaint, getAllComplaints };
