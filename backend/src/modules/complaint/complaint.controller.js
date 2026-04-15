const { createComplaint, getAllComplaints, updateComplaintStatus } = require('./complaint.service');

const create = async (req, res, next) => {
  try {
    const photo = req.file ? req.file.filename : null;
    const { title, description, location } = req.body;
    const user_id = req.user.id;

    const complaint = await createComplaint({ title, description, user_id, location, photo });
    res.status(201).json({ success: true, complaint });
  } catch (error) {
    error.statusCode = 400;
    next(error);
  }
};

const getAll = async (req, res, next) => {
  try {
    const { search, status } = req.query;
    const complaints = await getAllComplaints({ search, status });
    res.status(200).json({ success: true, complaints });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};

const updateStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['pending', 'in progress', 'resolved'];
    if (!validStatuses.includes(status.toLowerCase())) {
      const error = new Error('Invalid status');
      error.statusCode = 400;
      return next(error);
    }

    const complaint = await updateComplaintStatus(id, status.toLowerCase());
    res.status(200).json({ success: true, complaint });
  } catch (error) {
    error.statusCode = 400;
    next(error);
  }
};

module.exports = { create, getAll, updateStatus };
