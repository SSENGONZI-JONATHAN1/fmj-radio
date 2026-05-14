import { type Response } from 'express';
import { type AuthRequest } from '../middleware/authMiddleware.js';
import favoriteService from '../services/FavoriteService.js';
import { successResponse } from '../utils/response.js';
import { asyncHandler } from '../utils/asyncHandler.js';

class FavoriteController {
  getFavorites = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user!.userId;
    const favorites = await favoriteService.getUserFavorites(userId);
    res.json(successResponse(favorites));
  });

  toggle = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user!.userId;
    const { stationId } = req.params;
    const result = await favoriteService.toggleFavorite(userId, stationId as string);
    res.json(successResponse(result));
  });
}

export default new FavoriteController();
