import { type Request, type Response } from 'express';
import lyricsService from '../services/LyricsService.js';

class LyricsController {
  async getLyrics(req: Request, res: Response) {
    try {
      const title = req.query.title as string;
      const artist = req.query.artist as string;
      
      if (!title || !artist) {
        return res.status(400).json({ status: 'error', message: 'Title and Artist are required' });
      }

      const result = await lyricsService.getLyrics(title, artist);
      res.json({ data: result });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Failed to fetch lyrics' });
    }
  }
}

export default new LyricsController();
