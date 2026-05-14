import { Router } from 'express';
import announcementController from '../controllers/AnnouncementController.js';

const router = Router();

router.get('/', announcementController.getAnnouncements);

export default router;
