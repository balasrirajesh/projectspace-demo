const mongoose = require('mongoose');

const mentorshipRequestSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    mentor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: { type: String },
    topics: [{ type: String }],
    preferredSchedule: { type: String },
    status: { 
        type: String, 
        enum: ['pending', 'accepted', 'rejected', 'ended'], 
        default: 'pending' 
    }
}, { timestamps: true });

module.exports = mongoose.model('MentorshipRequest', mentorshipRequestSchema);
