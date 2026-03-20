import { type Response, type NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { type AuthRequest } from './authMiddleware.js';

export const optionalAuth = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;

  if (authHeader?.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
      const decoded = jwt.verify(token!, env.JWT_SECRET) as { userId: string };
      req.user = { userId: decoded.userId };
    } catch (error) {
      // Ignore invalid tokens for optional auth
    }
  }
  next();
};
