const express = require('express');
const router = express.Router();
const alumniController = require('../controllers/profileController');

router.get('/profile/:userId', alumniController.getProfile);
router.get('/list', alumniController.getAllMentors);
router.post('/profile/:userId', alumniController.updateProfile);
router.post('/verify/:userId', alumniController.submitVerification);

module.exports = router;
