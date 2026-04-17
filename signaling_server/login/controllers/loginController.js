const User = require('../../core/models/User');
const { v4: uuidv4 } = require('uuid');

exports.login = async (req, res) => {
    try {
        console.log('[AUTH] Login Request Body:', JSON.stringify(req.body));
        const { email, name } = req.body;
        
        if (!email) {
            console.warn('[AUTH] Missing email in request');
            return res.status(400).json({ message: 'Email is required' });
        }

        let user = await User.findOne({ email });
        console.log('[AUTH] User Search Result:', user ? 'Found' : 'Not Found');
        
        if (!user) {
            console.log(`[AUTH] Auto-registering new user: ${email}`);
            
            // AUTOMATED ROLE DETECTION
            const lowEmail = email.toLowerCase();
            let role = 'student';
            if (lowEmail.endsWith('@admin.com')) {
                role = 'admin';
            } else if (lowEmail.endsWith('@alumin.com')) {
                role = 'mentor';
            } else if (lowEmail.endsWith('@stud.com')) {
                role = 'student';
            }

            user = new User({
                id: uuidv4(),
                email: email,
                name: name || email.split('@')[0],
                role: role,
                status: role === 'admin' ? 'verified' : 'incomplete'
            });
            await user.save();
            console.log(`[AUTH] New ${role} account saved successfully`);
        } else if (name && name !== user.name) {
            // SYNC: Update name if it has changed in the Flutter app
            user.name = name;
            await user.save();
            console.log(`[AUTH] Updated name for user: ${email}`);
        }
        
        res.status(200).json(user);
};

exports.getStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const user = await User.findOne({ id });
        if (!user) return res.status(404).json({ message: 'User not found' });
        res.status(200).json({ status: user.status });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
