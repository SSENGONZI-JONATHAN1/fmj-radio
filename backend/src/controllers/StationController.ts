import { type Request, type Response } from 'express';
import stationService from '../services/StationService.js';

class StationController {
  async getAllStations(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const category = req.query.category as string;
      const country = req.query.country as string;
      const language = req.query.language as string;
      const search = req.query.search as string;

      const result = await stationService.getAllStations({
        page,
        limit,
        category,
        country,
        language,
        search
      });

      res.json(result);
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Failed to fetch stations' });
    }
  }

  async getStationById(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const station = await stationService.getStationById(id!);

      if (station) {
        res.json({ data: station });
      } else {
        res.status(404).json({ status: 'error', message: 'Station not found' });
      }
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Internal server error' });
    }
  }

  async getFeaturedStations(req: Request, res: Response) {
    try {
      const stations = await stationService.getFeaturedStations();
      res.json({ data: stations });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Failed to fetch featured stations' });
    }
  }

  async getTrendingStations(req: Request, res: Response) {
    try {
      const stations = await stationService.getTrendingStations();
      res.json({ data: stations });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Failed to fetch trending stations' });
    }
  }
}

export default new StationController();
