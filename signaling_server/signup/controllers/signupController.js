const User = require('../../core/models/User');
const { v4: uuidv4 } = require('uuid');

exports.signup = async (req, res) => {
    try {
        const userData = req.body;
        
        // AUTOMATED ROLE FORCING (Security hardening)
        if (userData.email) {
            const lowEmail = userData.email.toLowerCase();
            if (lowEmail.endsWith('@admin.com')) {
                userData.role = 'admin';
            } else if (
                lowEmail.endsWith('@mentor.com') ||
                lowEmail.endsWith('@mentors.com') ||
                lowEmail.endsWith('@alum.com') ||
                lowEmail.endsWith('@alumni.com') ||
                lowEmail.endsWith('@alumin.com')
            ) {
                userData.role = 'mentor';
            } else if (lowEmail.endsWith('@stud.com')) {
                userData.role = 'student';
            }
        }

        if (!userData.id) {
            userData.id = uuidv4();
        }
        const user = new User(userData);
        await user.save();
        res.status(201).json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
