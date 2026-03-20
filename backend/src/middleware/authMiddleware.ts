import { type Request, type Response, type NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { errorResponse } from '../utils/response.js';

export interface AuthRequest extends Request {
  user?: {
    userId: string;
  };
}

export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;

  // DEVELOPMENT BYPASS: Allow access without token for now
  if (!authHeader?.startsWith('Bearer ')) {
    console.warn('⚠️ Auth Middleware: No token provided. Using default "dev-user" for development.');
    req.user = { userId: 'dev-user-id' };
    return next();
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token!, env.JWT_SECRET) as { userId: string };
    req.user = { userId: decoded.userId };
    next();
  } catch (error) {
    return res.status(401).json(errorResponse('Unauthorized: Invalid token', 'UNAUTHORIZED'));
  }
};
