const express = require('express');
const router = express.Router();
const mentorshipController = require('../controllers/mentorshipController');

// Unified routes at /api/mentorship
router.get('/requests', mentorshipController.getAllRequests);
router.post('/requests', mentorshipController.submitRequest);
router.patch('/requests/:id/status', mentorshipController.updateStatus);

module.exports = router;
