const Alumni = require('../models/Alumni');
const User = require('../../core/models/User');

exports.getProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const alumni = await Alumni.findOne({ userId });
        if (!alumni) return res.status(404).json({ message: 'Alumni profile not found' });
        res.status(200).json(alumni);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const updateData = req.body;
        
        let alumni = await Alumni.findOneAndUpdate(
            { userId },
            { $set: updateData },
            { new: true, upsert: true }
        );

        // SYNC: Update the core User document to ensure "Balance" in global lists
        await User.findOneAndUpdate(
            { id: userId },
            { 
                $set: { 
                    techField: updateData.techField,
                    company: updateData.company,
                    yoe: updateData.yoe,
                    skills: updateData.skills,
                    name: updateData.name // Ensure display name is also synced
                } 
            }
        );
        
        res.status(200).json(alumni);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.submitVerification = async (req, res) => {
    try {
        const { userId } = req.params;
        const alumni = await Alumni.findOneAndUpdate(
            { userId },
            { $set: { verificationStatus: 'pending' } },
            { new: true }
        );

        // SYNC: Update core User status for Admin visibility
        await User.findOneAndUpdate(
            { id: userId },
            { $set: { status: 'pending' } }
        );

        res.status(200).json(alumni);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.getAllMentors = async (req, res) => {
    try {
        const mentors = await User.find({ role: 'mentor' }).select('id name email techField company status');
        res.status(200).json(mentors);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
