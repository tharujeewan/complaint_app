const express = require('express');
const router = express.Router();
const { protect } = require('../../middlewares/auth.middleware');
const { create, getAll, updateStatus } = require('./complaint.controller');
const upload = require('../../config/multer');
const validate = require('../../middlewares/validate');
const { createComplaintSchema } = require('./complaint.validator');

// POST /api/complaints — Create complaint with photo
router.post('/', protect, upload.single('photo'), validate(createComplaintSchema), create);

// GET /api/complaints — Get all complaints
router.get('/', protect, getAll);

// PUT /api/complaints/:id/status — Update complaint status
router.put('/:id/status', protect, updateStatus);

module.exports = router;
