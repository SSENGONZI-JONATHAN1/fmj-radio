import { Router } from 'express';
import stationController from '../controllers/StationController.js';

const router = Router();

router.get('/', stationController.search);

export default router;
