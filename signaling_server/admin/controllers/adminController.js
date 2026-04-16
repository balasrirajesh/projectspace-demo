const User = require('../../core/models/User');
const MentorshipRequest = require('../../core/models/MentorshipRequest');
// We require index.js at runtime to avoid circular dependency issues
// or we can just pass the rooms object. Let's use a safe requirement.
const server = require('../../index');

exports.getStats = async (req, res) => {
    try {
        const totalStudents = await User.countDocuments({ role: 'student' });
        const totalAlumni = await User.countDocuments({ role: 'mentor' });
        const verifiedAlumni = await User.countDocuments({ role: 'mentor', status: 'verified' });
        const pendingRequests = await User.countDocuments({ status: 'pending' });

        res.json({
            totalStudents,
            totalAlumni,
            verifiedAlumni,
            pendingRequests,
            totalConnections: 320, 
            activeSessions: 12     
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.getAllUsers = async (req, res) => {
    try {
        const { role, status, search } = req.query;
        let query = {};
        
        if (role) query.role = role;
        if (status) query.status = status;
        if (search) {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } }
            ];
        }

        const users = await User.find(query).sort({ createdAt: -1 });
        res.json(users);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.updateUserStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        
        const user = await User.findOneAndUpdate(
            { id: id }, 
            { status: status }, 
            { new: true }
        );
        
        if (!user) return res.status(404).json({ message: 'User not found' });
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.broadcastAnnouncement = async (req, res) => {
    try {
        const { title, message, target } = req.body;
        const { io } = server;

        console.log(`[ADMIN BROADCAST] To: ${target} | ${title}: ${message}`);

        if (io) {
            // Broadcast to all connected clients
            io.emit('new-announcement', {
                title,
                message,
                target,
                timestamp: new Date().toISOString()
            });
        }

        res.json({ message: 'Announcement broadcasted successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.terminateSession = async (req, res) => {
    try {
        const { roomId } = req.params;
        const { rooms, io } = server;

        if (rooms && rooms[roomId]) {
            console.log(`[ADMIN SUPERIOR] Terminating room: ${roomId}`);
            
            // Notify all participants in the room
            io.to(roomId).emit('session-terminated', { 
                message: 'This session has been terminated by a College Administrator.' 
            });

            // Delete the room
            delete rooms[roomId];
            
            // Broadcast updated room list
            const roomList = Object.keys(rooms).map(id => ({
                id,
                title: rooms[id].title || id,
                isLive: true,
                attendees: rooms[id].students.length,
                startTime: rooms[id].startTime
            }));
            io.emit('room-list', roomList);

            res.json({ message: `Session ${roomId} terminated successfully` });
        } else {
            res.status(404).json({ message: 'Session not found or already ended' });
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.getConnections = async (req, res) => {
    try {
        const connections = await MentorshipRequest.find()
            .populate('student', 'name collegeName')
            .populate('mentor', 'name collegeName')
            .sort({ createdAt: -1 });
        res.json(connections);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.moderateConnection = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const conn = await MentorshipRequest.findOneAndUpdate(
            { id: id },
            { status: status },
            { new: true }
        );
        if (!conn) return res.status(404).json({ message: 'Connection not found' });
        res.json(conn);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
