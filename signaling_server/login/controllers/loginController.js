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
        
        // AUTOMATED ROLE DETECTION & SYNC
        const lowEmail = email.toLowerCase();
        let correctRole = 'student';
        if (lowEmail.endsWith('@admin.com')) {
            correctRole = 'admin';
        } else if (
            lowEmail.endsWith('@mentor.com') ||
            lowEmail.endsWith('@mentors.com') ||
            lowEmail.endsWith('@alum.com') ||
            lowEmail.endsWith('@alumni.com') ||
            lowEmail.endsWith('@alumin.com')
        ) {
            correctRole = 'mentor';
        } else if (lowEmail.endsWith('@stud.com')) {
            correctRole = 'student';
        }

        if (!user) {
            console.log(`[AUTH] Auto-registering new user: ${email} as ${correctRole}`);
            user = new User({
                id: uuidv4(),
                email: email,
                name: name || email.split('@')[0],
                role: correctRole,
                status: correctRole === 'admin' ? 'verified' : 'incomplete'
            });
            await user.save();
            console.log(`[AUTH] New ${correctRole} account saved successfully`);
        } else {
            // SYNC: Ensure existing user's role and name are accurately updated
            let needsSave = false;
            if (user.role !== correctRole) {
                console.log(`[AUTH] Correcting role for ${email}: ${user.role} -> ${correctRole}`);
                user.role = correctRole;
                needsSave = true;
            }
            if (name && name !== user.name) {
                user.name = name;
                needsSave = true;
            }
            if (needsSave) {
                await user.save();
                console.log(`[AUTH] Updated user info for: ${email} (role: ${user.role})`);
            }
        }
        
        res.status(200).json(user);
    } catch (err) {
        console.error('[AUTH] Login Error:', err);
        res.status(500).json({ message: err.message });
    }
};
