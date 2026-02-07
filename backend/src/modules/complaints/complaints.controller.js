const { createComplaint } = require('./complaints.service');

// Controller to handle complaint creation
const complaintController = async (req, res) => {
  try {
    // req.file comes from multer
    const photo = req.file ? req.file.filename : null;

    // Extract other data from request body
    const { title, description, location } = req.body;
    const user_id = req.user.id; // from auth middleware

    const complaint = await createComplaint({ title, description, user_id, location, photo });

    res.status(201).json({ success: true, complaint });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

const getComplaints = async (req, res) => {
  try {
    const { getAllComplaints } = require('./complaints.service');
    const complaints = await getAllComplaints();
    res.status(200).json({ success: true, complaints });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { complaintController, getComplaints };
