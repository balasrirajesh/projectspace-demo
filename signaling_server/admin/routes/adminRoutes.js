const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

router.get('/stats', adminController.getStats);
router.get('/users', adminController.getAllUsers);
router.patch('/users/:id/status', adminController.updateUserStatus);
router.post('/announcements', adminController.broadcastAnnouncement);
router.delete('/sessions/:roomId', adminController.terminateSession);

router.get('/connections', adminController.getConnections);
router.patch('/connections/:id', adminController.moderateConnection);

module.exports = router;
