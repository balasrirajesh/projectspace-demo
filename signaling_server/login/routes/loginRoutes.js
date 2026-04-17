const express = require('express');
const router = express.Router();
const loginController = require('../controllers/loginController');

router.post('/', loginController.login);
router.get('/status/:id', loginController.getStatus);

module.exports = router;
