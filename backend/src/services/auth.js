import bcryptjs from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User, License } from '../models.js';

const JWT_SECRET = process.env.JWT_SECRET || 'saqr-secret-key';

export function hashPassword(password) {
  return bcryptjs.hashSync(password, 10);
}

export function verifyPassword(password, hash) {
  return bcryptjs.compareSync(password, hash);
}

export function generateToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: '24h' });
}

export function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    return null;
  }
}

export function authenticateUser(username, password) {
  const user = User.getByUsername(username);
  if (!user) return null;
  
  if (!verifyPassword(password, user.password_hash)) {
    return null;
  }
  
  return user;
}

export function checkLicenseValidity() {
  return !License.isExpired();
}

export default {
  hashPassword,
  verifyPassword,
  generateToken,
  verifyToken,
  authenticateUser,
  checkLicenseValidity
};
