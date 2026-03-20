import { Router } from 'express';
import analyticsController from '../controllers/AnalyticsController.js';

const router = Router();

router.post('/listening', analyticsController.reportListening);

export default router;
