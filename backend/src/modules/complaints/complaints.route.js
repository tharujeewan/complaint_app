const express = require('express');
const router = express.Router();
const { protect } = require('../../middlewares/auth.middleware');
const { complaintController, getComplaints } = require('./complaints.controller');
const upload = require('../../config/multer'); // multer config
const validate = require('../../middlewares/validate');
const { createComplaintSchema } = require('./complaints.validator');

// POST /api/complaints → Create complaint with photo
router.post('/', protect, upload.single('photo'), validate(createComplaintSchema), complaintController);

// GET /api/complaints → Get all complaints
router.get('/', protect, getComplaints);

module.exports = router;
