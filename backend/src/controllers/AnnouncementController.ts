import { type Request, type Response } from 'express';
import announcementService from '../services/AnnouncementService.js';
import { successResponse } from '../utils/response.js';
import { asyncHandler } from '../utils/asyncHandler.js';

class AnnouncementController {
  getAnnouncements = asyncHandler(async (req: Request, res: Response) => {
    const announcements = await announcementService.getActiveAnnouncements();
    res.json(successResponse(announcements));
  });
}

export default new AnnouncementController();
