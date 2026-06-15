import { hashPassword, verifyPassword, generateToken, verifyToken } from '../src/services/auth.js';
import { describe, it, expect } from '@jest/globals';

describe('Authentication Service Tests', () => {
  it('should hash password correctly', () => {
    const password = 'test123';
    const hash = hashPassword(password);
    expect(hash).not.toBe(password);
  });

  it('should verify password correctly', () => {
    const password = 'test123';
    const hash = hashPassword(password);
    expect(verifyPassword(password, hash)).toBe(true);
  });

  it('should fail to verify wrong password', () => {
    const password = 'test123';
    const hash = hashPassword(password);
    expect(verifyPassword('wrong', hash)).toBe(false);
  });

  it('should generate valid token', () => {
    const token = generateToken(1);
    expect(token).toBeDefined();
  });

  it('should verify valid token', () => {
    const userId = 1;
    const token = generateToken(userId);
    const decoded = verifyToken(token);
    expect(decoded.id).toBe(userId);
  });

  it('should fail to verify invalid token', () => {
    const decoded = verifyToken('invalid.token.here');
    expect(decoded).toBe(null);
  });
});
