const request = require('supertest');
const { app } = require('../index');
const mongoose = require('mongoose');

describe('Signaling Server Quality Gate Tests', () => {
    
    // Health Check Tests
    describe('GET /health', () => {
        it('should return 200 OK', async () => {
            const res = await request(app).get('/health');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('status', 'OK');
        });
    });

    describe('GET /api/health', () => {
        it('should return 200 with version', async () => {
            const res = await request(app).get('/api/health');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('version');
        });
    });

    // Authentication Tests
    describe('POST /api/auth/login', () => {
        it('should auto-register a new user and return user data', async () => {
            const res = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'test_student@stud.com',
                    name: 'Test Student'
                });
            
            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('email', 'test_student@stud.com');
            expect(res.body).toHaveProperty('role', 'student');
        });

        it('should return 400 if email is missing', async () => {
            const res = await request(app)
                .post('/api/auth/login')
                .send({ name: 'No Email' });
            
            expect(res.statusCode).toEqual(400);
        });
    });

    // Admin Tests
    describe('GET /api/admin/stats', () => {
        it('should return admin dashboard statistics', async () => {
            const res = await request(app).get('/api/admin/stats');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('totalStudents');
            expect(res.body).toHaveProperty('activeSessions');
        });
    });

    afterAll(async () => {
        // Cleanup MongoDB connection to allow Jest to exit
        await mongoose.connection.close();
    });
});
