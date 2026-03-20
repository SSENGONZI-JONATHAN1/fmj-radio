import { type Request, type Response } from 'express';
import appConfigService from '../services/AppConfigService.js';
import { successResponse } from '../utils/response.js';
import { asyncHandler } from '../utils/asyncHandler.js';

class AppConfigController {
  getConfig = asyncHandler(async (req: Request, res: Response) => {
    const config = await appConfigService.getConfig();
    res.json(successResponse(config));
  });
}

export default new AppConfigController();
