import { Router } from 'express';
import appConfigController from '../controllers/AppConfigController.js';

const router = Router();

router.get('/', appConfigController.getConfig);

export default router;
