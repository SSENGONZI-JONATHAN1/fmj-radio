import prisma from '../lib/prisma.js';

class CategoryService {
  async getAllCategories() {
    const categories = await prisma.category.findMany({
      include: {
        _count: {
          select: { stations: true }
        }
      }
    });

    return categories.map(c => ({
      id: c.id,
      name: c.name,
      iconUrl: c.iconUrl,
      stationCount: c._count.stations
    }));
  }
}

export default new CategoryService();
