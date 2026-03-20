import { Router } from 'express';
import lyricsController from '../controllers/LyricsController.js';

const router = Router();

router.get('/', lyricsController.getLyrics);

export default router;
