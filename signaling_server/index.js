// Unified Backend: WebRTC signaling + REST API
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const morgan = require('morgan');

const loginRoutes = require('./login/routes/loginRoutes');
const signupRoutes = require('./signup/routes/signupRoutes');
const alumniProfileRoutes = require('./alumni/routes/profileRoutes');
const alumniMentorshipRoutes = require('./alumni/routes/mentorshipRoutes');
const alumniChatRoutes = require('./alumni/routes/chatRoutes');
const studentProfileRoutes = require('./student/routes/profileRoutes');
const studentMentorshipRoutes = require('./student/routes/mentorshipRoutes');
const studentChatRoutes = require('./student/routes/chatRoutes');
const adminRoutes = require('./admin/routes/adminRoutes');

const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
  path: '/api/socket',
  cors: { 
    origin: (origin, callback) => {
      // Allow all origins in dev, but mirror them back for CORS compliance with credentials
      callback(null, true);
    },
    methods: ["GET", "POST"],
    credentials: true
  },
  pingTimeout: 60000,
  pingInterval: 25000,
  transports: ['websocket', 'polling']
});

// Middleware
const corsOptions = {
  origin: (origin, callback) => {
    // Mirror back the origin to satisfy 'credentials: true'
    callback(null, true);
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: true
};

app.use(cors(corsOptions));
app.use(morgan('dev'));
app.use(bodyParser.json());

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/alumni_app';
mongoose.connect(MONGODB_URI)
  .then(() => console.log('🍃 Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB Connection Error:', err));

// API Routes
app.use('/api/auth/login', loginRoutes);
app.use('/api/auth/signup', signupRoutes);

// Alumni Module Routes
app.use('/api/alumni', alumniProfileRoutes);
app.use('/api/alumni/mentorship', alumniMentorshipRoutes);
app.use('/api/alumni/chats', alumniChatRoutes);

// Student Module Routes
app.use('/api/student', studentProfileRoutes);
app.use('/api/student/mentorship', studentMentorshipRoutes);
app.use('/api/student/chats', studentChatRoutes);
app.use('/api/admin', adminRoutes);

// Root Health Check (Used by OpenShift Readiness/Liveness probes)
app.get('/', (req, res) => {
  res.status(200).send('ALIVE');
});

app.get('/health', (req, res) => {
  res.status(200).send({ status: 'OK' });
});

app.get('/api/health', (req, res) => {
  res.status(200).send({ status: 'OK', version: '1.0.0' });
});

const PORT = process.env.PORT || 3000;

// Version: 1.0.3 - Explicit Wipe Support [2026-04-13]
const rooms = {};

// Maintenance endpoints
app.get('/rooms', (req, res) => res.json(rooms));
app.get('/clear-rooms', (req, res) => {
  const roomIds = Object.keys(rooms);
  roomIds.forEach(id => delete rooms[id]);
  console.log(`[MAINTENANCE] Cleared ${roomIds.length} rooms`);
  res.send(`Cleared ${roomIds.length} rooms. Dashboard will update on next client connect.`);
});

const broadcastRoomList = () => {
  const roomList = Object.keys(rooms).map(id => ({
    id,
    title: rooms[id].title || id,
    isLive: true,
    attendees: rooms[id].students.length,
    startTime: rooms[id].startTime
  }));
  io.emit('room-list', roomList);
};

io.on('connection', (socket) => {
  console.log(`[CONNECT] User: ${socket.id}`);

  // Send initial room list to new connection
  const initialRooms = Object.keys(rooms).map(id => ({
    id,
    title: rooms[id].title || id,
    isLive: true,
    attendees: rooms[id].students.length,
    startTime: rooms[id].startTime
  }));
  socket.emit('room-list', initialRooms);

  // Join Room: { roomId, role: 'mentor' | 'student', title }
  socket.on('join-room', (data) => {
    const roomId = typeof data === 'string' ? data : data.roomId;
    const role = typeof data === 'object' ? data.role : 'mentor';
    const title = typeof data === 'object' ? data.title : roomId;

    socket.join(roomId);
    socket.data.roomId = roomId;
    socket.data.role = role;

    if (!rooms[roomId]) {
      if (role !== 'mentor') {
        console.log(`[ROOM] Denied: Student ${socket.id} attempted to join non-existent room ${roomId}`);
        socket.emit('error', 'Class has not started yet. Please wait for the Alumni/Mentor to join.');
        return;
      }
      rooms[roomId] = {
        mentorSocketId: null,
        students: [],
        title: title,
        startTime: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
    }

    if (data.role === 'mentor') {
      const wasEmpty = !rooms[roomId].mentorSocketId;
      rooms[roomId].mentorSocketId = socket.id;
      
      if (wasEmpty) {
        console.log(`[ROOM] Mentor ${socket.id} started room: ${roomId}`);
        // 1. Notify existing students that mentor is here
        socket.to(roomId).emit('mentor-joined', { 
          mentorId: socket.id, 
          userName: data.userName 
        });

        // 2. Trigger handshake for all waiting students
        rooms[roomId].students.forEach(studentId => {
          socket.emit('user-joined', studentId);
        });
      }
    } else {
      rooms[roomId].students.push(socket.id);
      // If mentor is already here, notify them about the new student
      if (rooms[roomId].mentorSocketId) {
        io.to(rooms[roomId].mentorSocketId).emit('user-joined', socket.id);
      }
    }

    broadcastRoomList();
  });

  // Relay Offer: { target, offer, fromName }
  socket.on('offer', (data) => {
    console.log(`[RTC] Offer from ${socket.id} (${data.fromName}) to ${data.target}`);
    io.to(data.target).emit('offer', {
      offer: data.offer,
      from: socket.id,
      fromName: data.fromName
    });
  });

  // Relay Answer: { target, answer, fromName }
  socket.on('answer', (data) => {
    console.log(`[RTC] Answer from ${socket.id} (${data.fromName}) to ${data.target}`);
    io.to(data.target).emit('answer', {
      answer: data.answer,
      from: socket.id,
      fromName: data.fromName
    });
  });

  // Relay ICE Candidate: { target, candidate, fromName }
  socket.on('ice-candidate', (data) => {
    // Shhh, only log if needed to avoid console spam, 
    // but useful for identifying if ICE exchange is even happening
    // console.log(`[RTC] ICE Candidate from ${socket.id} to ${data.target}`);
    io.to(data.target).emit('ice-candidate', {
      candidate: data.candidate,
      from: socket.id,
      fromName: data.fromName
    });
  });

  // Interaction Events
  socket.on('send-message', (data) => {
    io.to(data.roomId).emit('new-message', data);
  });

  socket.on('send-image', (data) => {
    // Relay image data (base64) to everyone in the room
    io.to(data.roomId).emit('new-message', {
      ...data,
      type: 'image',
      timestamp: new Date().toISOString()
    });
  });

  socket.on('raise-hand', (data) => {
    socket.to(data.roomId).emit('user-raised-hand', data);
  });

  // Explicit Room Leave: { roomId }
  socket.on('leave-room', (data) => {
    const roomId = data.roomId;
    console.log(`[LEAVE] User ${socket.id} leaving room ${roomId}`);
    
    if (rooms[roomId]) {
      if (socket.data.role === 'mentor' && rooms[roomId].mentorSocketId === socket.id) {
        socket.to(roomId).emit('mentor-left');
        delete rooms[roomId];
        console.log(`[ROOM] Session ended and deleted: ${roomId}`);
      } else {
        rooms[roomId].students = rooms[roomId].students.filter(id => id !== socket.id);
        socket.to(roomId).emit('user-left', socket.id);
      }
      broadcastRoomList();
    }
  });

  // Cleanup on disconnect
  socket.on('disconnect', () => {
    console.log(`[DISCONNECT] User: ${socket.id}`);
    const roomId = socket.data.roomId;
    if (roomId && rooms[roomId]) {
      if (socket.data.role === 'mentor' && rooms[roomId].mentorSocketId === socket.id) {
        socket.to(roomId).emit('mentor-left');
        delete rooms[roomId];
      } else {
        rooms[roomId].students = rooms[roomId].students.filter(id => id !== socket.id);
        socket.to(roomId).emit('user-left', socket.id);
      }
      broadcastRoomList();
    }
  });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err);
  if (!res.headersSent) {
    // Ensure CORS headers are included even in error responses
    res.header('Access-Control-Allow-Origin', '*');
    res.status(500).json({ error: 'Internal Server Error', message: err.message });
  }
});

http.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Signaling Server ready on port ${PORT}`);
});

module.exports = { app, rooms, io };
