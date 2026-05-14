import { Router } from 'express';
import stationController from '../controllers/StationController.js';

const router = Router();

// Define Station routes
router.get('/', stationController.getAllStations);
router.get('/featured', stationController.getFeaturedStations);
router.get('/trending', stationController.getTrendingStations);
router.get('/:id', stationController.getStationById);
router.get('/:id/similar', stationController.getSimilarStations);

export default router;
