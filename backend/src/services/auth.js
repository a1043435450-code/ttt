import jwt from 'jsonwebtoken';
import bcryptjs from 'bcryptjs';

const JWT_SECRET = process.env.JWT_SECRET || 'saqr-secret-key';

export function hashPassword(password) {
  return bcryptjs.hashSync(password, 10);
}

export function verifyPassword(password, hash) {
  return bcryptjs.compareSync(password, hash);
}

export function generateToken(userId) {
  return jwt.sign({ id: userId }, JWT_SECRET, { expiresIn: '24h' });
}

export function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    return null;
  }
}
