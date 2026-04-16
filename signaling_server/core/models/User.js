const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String },
    branch: { type: String },
    year: { type: String },
    skills: [{ type: String }],
    techField: { type: String },
    company: { type: String },
    yoe: { type: String },
    role: { type: String, enum: ['mentor', 'student', 'admin'], default: 'student' },
    status: { type: String, enum: ['incomplete', 'pending', 'verified', 'rejected', 'blocked'], default: 'incomplete' }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
