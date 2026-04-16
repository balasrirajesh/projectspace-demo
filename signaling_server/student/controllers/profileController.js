const Student = require('../models/Student');
const User = require('../../core/models/User');

exports.getProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const student = await Student.findOne({ userId });
        if (!student) return res.status(404).json({ message: 'Student profile not found' });
        res.status(200).json(student);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const updateData = req.body;
        
        let student = await Student.findOneAndUpdate(
            { userId },
            { $set: updateData },
            { new: true, upsert: true }
        );

        // SYNC: Update the core User document for balanced analytics
        await User.findOneAndUpdate(
            { id: userId },
            { 
                $set: { 
                    branch: updateData.branch,
                    year: updateData.year,
                    skills: updateData.skills,
                    name: updateData.name
                } 
            }
        );
        
        res.status(200).json(student);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
