const ChatSession = require('../../core/models/ChatSession');
const ChatMessage = require('../../core/models/ChatMessage');
const { v4: uuidv4 } = require('uuid');

exports.createOrGetSession = async (req, res) => {
  try {
    const { id, mentor, mentee } = req.body;
    const sessionId = id || (mentor && mentee ? `${mentor.id || mentor}_${mentee.id || mentee}` : uuidv4());
    let session = await ChatSession.findById(sessionId);
    if (!session) {
      session = new ChatSession({
        _id: sessionId,
        mentor: mentor || { id: 'unknown-mentor', name: 'Mentor' },
        mentee: mentee || { id: 'unknown-student', name: 'Student' }
      });
      await session.save();
    }
    res.status(200).json(session);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getUserSessions = async (req, res) => {
  try {
    const { userId } = req.params;
    const sessions = await ChatSession.find({
      $or: [{ 'mentor.id': userId }, { 'mentee.id': userId }]
    });
    res.status(200).json(sessions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.sendMessage = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { senderId, text, timestamp } = req.body;
    
    const message = new ChatMessage({
      sessionId,
      senderId,
      text,
      timestamp: timestamp || new Date()
    });
    
    await message.save();
    res.status(200).json(message);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const messages = await ChatMessage.find({ sessionId }).sort({ timestamp: 1 });
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
