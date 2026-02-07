const express = require('express');
const router = express.Router();
const { protect } = require('../../middlewares/auth.middleware');
const { complaintController, getComplaints } = require('./complaints.controller');
const upload = require('../../config/multer'); // multer config

// POST /api/complaints → Create complaint with photo
router.post('/', protect, upload.single('photo'), complaintController);

// GET /api/complaints → Get all complaints
router.get('/', protect, getComplaints);

module.exports = router;
