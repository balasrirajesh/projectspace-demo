const User = require('../models/User');
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
            user = new User({
                id: uuidv4(),
                email: email,
                name: name || email.split('@')[0],
            });
            await user.save();
            console.log('[AUTH] New user saved successfully');
        }
        
        res.status(200).json(user);
    } catch (err) {
        console.error('[AUTH] Login Error:', err);
        res.status(500).json({ message: err.message });
    }
};

exports.signup = async (req, res) => {
    try {
        const userData = req.body;
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
