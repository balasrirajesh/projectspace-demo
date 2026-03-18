const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
  cors: { origin: "*" }
});
const nms = require('./media_server');

const PORT = process.env.PORT || 3000;

// Start Node Media Server for Streaming
nms.run();

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // --- Room-based Signaling (Interactive Classroom) ---
  socket.on('join-room', (roomId) => {
    socket.join(roomId);
    console.log(`User ${socket.id} joined room ${roomId}`);
    socket.to(roomId).emit('user-joined', socket.id);
  });

  socket.on('offer', (data) => {
    // data: { offer: sdp, roomId: string, to: socketId }
    if (data.to) {
      socket.to(data.to).emit('offer', { offer: data.offer, from: socket.id });
    }
  });

  socket.on('answer', (data) => {
    // data: { answer: sdp, to: socketId }
    socket.to(data.to).emit('answer', { answer: data.answer, from: socket.id });
  });

  socket.on('ice-candidate', (data) => {
    // data: { candidate: obj, to: socketId }
    socket.to(data.to).emit('ice-candidate', { candidate: data.candidate, from: socket.id });
  });

  // --- General Interaction (Chat & Reactions) ---
  socket.on('send-message', (data) => {
    // data: { text: string, roomId: string, userName: string }
    io.to(data.roomId).emit('new-message', data);
  });

  socket.on('send-heart', (roomId) => {
    socket.to(roomId).emit('receive-heart');
  });

  socket.on('disconnecting', () => {
    for (const room of socket.rooms) {
      if (room !== socket.id) {
        socket.to(room).emit('user-left', socket.id);
      }
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

http.listen(PORT, () => {
  console.log(`Signaling & Chat server listening on port ${PORT}`);
});
