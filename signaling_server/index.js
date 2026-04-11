// WebRTC signaling server with role-based room management
const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
  cors: { origin: "*" }
});

const PORT = process.env.PORT || 3000;

// Only run Media Server locally if FFMPEG is available or explicitly requested
// For Render free tier, we focus strictly on P2P signaling to stay within limits
if (process.env.START_MEDIA_SERVER === 'true') {
  try {
    const nms = require('./media_server');
    nms.run();
    console.log('📺 Node Media Server started');
  } catch (err) {
    console.error('⚠️ Could not start Media Server:', err.message);
  }
}

// Track rooms: { roomId: { mentorSocketId, students: [socketId] } }
const rooms = {};

io.on('connection', (socket) => {
  console.log(`[CONNECT] User: ${socket.id}`);

  // Join Room: { roomId, role: 'mentor' | 'student' }
  socket.on('join-room', (data) => {
    const roomId = typeof data === 'string' ? data : data.roomId;
    const role   = typeof data === 'object' ? data.role : 'mentor';

    socket.join(roomId);
    socket.data.roomId = roomId;
    socket.data.role   = role;

    if (!rooms[roomId]) {
      rooms[roomId] = { mentorSocketId: null, students: [] };
    }

    if (role === 'mentor') {
      rooms[roomId].mentorSocketId = socket.id;
      console.log(`[ROOM] Mentor (${socket.id}) created: ${roomId}`);
    } else {
      if (!rooms[roomId].mentorSocketId) {
        socket.emit('error', { message: 'Mentor not in room yet' });
        return;
      }
      if (!rooms[roomId].students.includes(socket.id)) {
        rooms[roomId].students.push(socket.id);
      }
      console.log(`[ROOM] Student (${socket.id}) joined: ${roomId}`);

      // Notify mentor that a student joined
      io.to(rooms[roomId].mentorSocketId).emit('user-joined', socket.id);
    }
  });

  // Relay Offer: { target, offer }
  socket.on('offer', (data) => {
    io.to(data.target).emit('offer', { 
      offer: data.offer, 
      from: socket.id 
    });
  });

  // Relay Answer: { target, answer }
  socket.on('answer', (data) => {
    io.to(data.target).emit('answer', { 
      answer: data.answer, 
      from: socket.id 
    });
  });

  // Relay ICE Candidate: { target, candidate }
  socket.on('ice-candidate', (data) => {
    io.to(data.target).emit('ice-candidate', { 
      candidate: data.candidate, 
      from: socket.id 
    });
  });

  // Interaction Events
  socket.on('send-message', (data) => {
    io.to(data.roomId).emit('new-message', data);
  });

  socket.on('send-comment', (data) => {
    io.to(data.roomId).emit('new-comment', data);
  });

  socket.on('raise-hand', (data) => {
    socket.to(data.roomId).emit('user-raised-hand', data);
  });

  // Cleanup on disconnect
  socket.on('disconnecting', () => {
    const roomId = socket.data.roomId;
    if (roomId && rooms[roomId]) {
      if (socket.data.role === 'mentor') {
        socket.to(roomId).emit('mentor-left');
        delete rooms[roomId];
      } else {
        rooms[roomId].students = rooms[roomId].students.filter(id => id !== socket.id);
        socket.to(roomId).emit('user-left', socket.id);
      }
    }
  });
});

http.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Signaling Server ready on port ${PORT}`);
});

