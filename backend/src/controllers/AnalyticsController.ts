import { type Request, type Response } from 'express';
import analyticsService from '../services/AnalyticsService.js';

class AnalyticsController {
  async reportListening(req: Request, res: Response) {
    try {
      const result = await analyticsService.reportListening(req.body);
      res.json(result);
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Failed to report analytics' });
    }
  }
}

export default new AnalyticsController();
