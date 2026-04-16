const express = require('express');
const router = express.Router();
const mentorshipController = require('../controllers/mentorshipController');

router.get('/mentor/:mentorId', mentorshipController.getMentorRequests);
router.get('/requests', mentorshipController.getMentorRequests); // Match Flutter's expected path
router.post('/requests', mentorshipController.submitRequest); // Ensure creation is possible
router.put('/:id/status', mentorshipController.updateStatus);
router.patch('/requests/:id/status', mentorshipController.updateStatus); // Support Flutter's PATCH method
router.get('/dashboard/:mentorId', mentorshipController.getDashboardSummary);


module.exports = router;
