/**
 * Quality Gate Test Suite — v3
 * Fixed: correct route paths, mongoose method mocking, jest-junit output
 */
process.env.MONGODB_URI = 'mongodb://localhost:27017/test_alumni_app';
process.env.PORT = '4001';
process.env.NODE_ENV = 'test';

const request = require('supertest');

// ── Mock mongoose BEFORE requiring app ──────────────────────────────────────
const mockUser = {
  findOne: jest.fn(),
  countDocuments: jest.fn().mockResolvedValue(0),
  find: jest.fn().mockResolvedValue([]),
};

jest.mock('mongoose', () => {
  const mockModel = {
    find: jest.fn().mockImplementation(() => mockUser.find()),
    findOne: jest.fn().mockImplementation(() => mockUser.findOne()),
    findOneAndUpdate: jest.fn().mockResolvedValue(null),
    countDocuments: jest.fn().mockImplementation(() => mockUser.countDocuments()),
    populate: jest.fn().mockReturnThis(),
    sort: jest.fn().mockResolvedValue([]),
  };

  function Model(data) {
    Object.assign(this, data);
    this.save = jest.fn().mockImplementation(function() { return Promise.resolve(this); });
    return this;
  }
  Object.assign(Model, mockModel);

  return {
    connect: jest.fn().mockResolvedValue({}),
    connection: { close: jest.fn().mockResolvedValue({}) },
    Schema: class Schema {
      constructor() {}
      static Types = { ObjectId: String, Mixed: Object }
      pre() { return this; }
      index() { return this; }
    },
    model: jest.fn().mockReturnValue(Model),
  };
});

let app;

beforeAll(() => {
  // Ensure we get a fresh require
  jest.isolateModules(() => {
    app = require('../index').app;
  });
});

// ── Health Checks ────────────────────────────────────────────────────────────
describe('Core Health Checks', () => {
  it('GET / should return 200 ALIVE', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.text).toBe('ALIVE');
  });

  it('GET /health should return status OK', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    // Explicitly check body or text if JSON parsing failed
    const body = typeof res.body === 'string' ? JSON.parse(res.body) : res.body;
    expect(body.status).toBe('OK');
  });
});

// ── Authentication & "Handshake" Logic ────────────────────────────────────────
describe('Authentication API', () => {
  it('POST /api/auth/login - should return 400 if email missing', async () => {
    const res = await request(app).post('/api/auth/login').send({ name: 'Test' });
    expect(res.statusCode).toBe(400);
  });

  it('POST /api/auth/login - should return user if found', async () => {
    mockUser.findOne.mockResolvedValueOnce({ email: 'test@test.com', name: 'Existing User' });
    const res = await request(app).post('/api/auth/login').send({ email: 'test@test.com' });
    expect(res.statusCode).toBe(200);
    expect(res.body.email).toBe('test@test.com');
  });

  it('POST /api/auth/login - should auto-register if NOT found', async () => {
    mockUser.findOne.mockResolvedValueOnce(null);
    const res = await request(app).post('/api/auth/login').send({ email: 'new@test.com', name: 'New' });
    expect(res.statusCode).toBe(200);
    expect(res.body.email).toBe('new@test.com');
  });

  it('POST /api/auth/signup - should create new user', async () => {
    const res = await request(app).post('/api/auth/signup').send({ email: 'sign@up.com', name: 'Sign' });
    expect(res.statusCode).toBe(201);
    expect(res.body.email).toBe('sign@up.com');
  });
});

// ── Room & "Class" Logic ─────────────────────────────────────────────────────
describe('Classroom / Room Management', () => {
  it('GET /api/rooms should return current rooms', async () => {
    const res = await request(app).get('/api/rooms');
    expect(res.statusCode).toBe(200);
    expect(typeof res.body).toBe('object');
  });

  it('GET /api/clear-rooms - should wipe sessions', async () => {
    const res = await request(app).get('/api/clear-rooms');
    expect(res.statusCode).toBe(200);
    expect(res.text).toContain('Cleared');
  });
});

// ── Admin Module ─────────────────────────────────────────────────────────────
describe('Admin API', () => {
  it('GET /api/admin/stats - should return stats', async () => {
    const res = await request(app).get('/api/admin/stats');
    expect(res.statusCode).toBe(200);
  });

  it('POST /api/admin/announcements - should accept broadcast', async () => {
    const res = await request(app)
      .post('/api/admin/announcements')
      .send({ title: 'Alert', message: 'Hello', target: 'all' });
    expect(res.statusCode).toBe(200);
  });
});
