import { Router } from 'express';
import favoriteController from '../controllers/FavoriteController.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

const router = Router();

router.use(authMiddleware);

router.get('/', favoriteController.getFavorites);
router.post('/:stationId', favoriteController.toggle);

export default router;
