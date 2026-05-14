import { type Response } from 'express';
import { type AuthRequest } from '../middleware/authMiddleware.js';
import stationService from '../services/StationService.js';
import { successResponse } from '../utils/response.js';
import { asyncHandler } from '../utils/asyncHandler.js';

class StationController {
  getAllStations = asyncHandler(async (req: AuthRequest, res: Response) => {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const category = req.query.category as string;
    const country = req.query.country as string;
    const language = req.query.language as string;
    const search = req.query.search as string;
    const userId = req.user?.userId;

    const result = await stationService.getAllStations({
      page,
      limit,
      category,
      country,
      language,
      search
    }, userId);

    res.json(successResponse(result.data, {
      total: result.totalCount,
      page: result.page,
      limit: result.limit,
      hasMore: result.hasMore
    }));
  });

  getStationById = asyncHandler(async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const userId = req.user?.userId;
    const station = await stationService.getStationById(id as string, userId);

    if (station) {
      res.json(successResponse(station));
    } else {
      res.status(404).json({ success: false, error: { message: 'Station not found' } });
    }
  });

  getFeaturedStations = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    const stations = await stationService.getFeaturedStations(userId);
    res.json(successResponse(stations));
  });

  getTrendingStations = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    const stations = await stationService.getTrendingStations(userId);
    res.json(successResponse(stations));
  });

  search = asyncHandler(async (req: AuthRequest, res: Response) => {
    const query = (req.query.q || req.query.search) as string;
    const userId = req.user?.userId;
    if (!query) {
      return res.json(successResponse([]));
    }
    const stations = await stationService.searchStations(query, userId);
    res.json(successResponse(stations));
  });

  getSimilarStations = asyncHandler(async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const userId = req.user?.userId;
    const stations = await stationService.getSimilarStations(id as string, userId);
    res.json(successResponse(stations));
  });

  getCountries = asyncHandler(async (req: Request, res: Response) => {
    const countries = await stationService.getCountries();
    res.json(successResponse(countries));
  });

  getLanguages = asyncHandler(async (req: Request, res: Response) => {
    const languages = await stationService.getLanguages();
    res.json(successResponse(languages));
  });
}

export default new StationController();
