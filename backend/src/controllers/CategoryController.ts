import { type Request, type Response } from 'express';
import categoryService from '../services/CategoryService.js';
import { successResponse } from '../utils/response.js';
import { asyncHandler } from '../utils/asyncHandler.js';

class CategoryController {
  getAllCategories = asyncHandler(async (req: Request, res: Response) => {
    const categories = await categoryService.getAllCategories();
    res.json(successResponse(categories));
  });
}

export default new CategoryController();
