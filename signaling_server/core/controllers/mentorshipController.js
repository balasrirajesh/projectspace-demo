const MentorshipRequest = require('../models/MentorshipRequest');
const User = require('../models/User');
const { v4: uuidv4 } = require('uuid');

// DTO Helper to match Flutter's MentorshipRequest model exactly
const mapToFlutterDTO = (request) => {
    if (!request) return null;
    return {
        id: request.id,
        student: {
            id: request.student ? request.student.id : 'unknown',
            name: request.student ? request.student.name : 'Unknown Student',
            branch: request.student ? request.student.branch : '',
            year: request.student ? request.student.year : '',
            skills: request.student ? request.student.skills : [],
        },
        reason: request.reason,
        topics: request.topics || [],
        preferredSchedule: request.preferredSchedule,
        status: request.status,
        createdAt: request.createdAt,
    };
};

exports.getAllRequests = async (req, res) => {
    try {
        const { mentorId, studentId, status } = req.query;
        let query = {};
        
        if (mentorId) {
            const mentor = await User.findOne({ id: mentorId });
            if (mentor) query.mentor = mentor._id;
        }
        
        if (studentId) {
            const student = await User.findOne({ id: studentId });
            if (student) query.student = student._id;
        }

        if (status) query.status = status;

        const requests = await MentorshipRequest.find(query)
            .populate('student')
            .populate('mentor')
            .sort({ createdAt: -1 });

        res.json(requests.map(mapToFlutterDTO));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.submitRequest = async (req, res) => {
    try {
        const { id, reason, topics, preferredSchedule, studentId, mentorId } = req.body;
        
        const student = await User.findOne({ id: studentId });
        if (!student) return res.status(404).json({ message: 'Student not found' });

        const mentor = mentorId ? await User.findOne({ id: mentorId }) : null;

        const newRequest = new MentorshipRequest({
            id: id || uuidv4(),
            student: student._id,
            mentor: mentor ? mentor._id : null,
            reason,
            topics: topics || [],
            preferredSchedule,
            status: 'pending'
        });

        await newRequest.save();
        const populated = await MentorshipRequest.findById(newRequest._id).populate('student');
        res.status(201).json(mapToFlutterDTO(populated));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.updateStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body; // status should be accepted/rejected/ended

        const request = await MentorshipRequest.findOneAndUpdate(
            { id: id },
            { status: status },
            { new: true }
        ).populate('student').populate('mentor');

        if (!request) return res.status(404).json({ message: 'Mentorship request not found' });
        
        res.json(mapToFlutterDTO(request));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
