import { type Request, type Response, type NextFunction } from 'express';
import { ZodError } from 'zod';
import { errorResponse } from '../utils/response.js';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', err);

  if (err instanceof ZodError) {
    return res.status(400).json(
      errorResponse('Validation failed', 'VALIDATION_ERROR', err)
    );
  }

  // Handle JWT errors
  if (err.name === 'UnauthorizedError' || err.name === 'JsonWebTokenError') {
    return res.status(401).json(
      errorResponse('Unauthorized', 'UNAUTHORIZED')
    );
  }

  // Default error
  const statusCode = (err as any).status || 500;
  res.status(statusCode).json(
    errorResponse(err.message || 'Internal Server Error', (err as any).code || 'INTERNAL_ERROR')
  );
};
