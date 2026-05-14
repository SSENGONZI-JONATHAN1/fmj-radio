import prisma from '../lib/prisma.js';

class FavoriteService {
  async getUserFavorites(userId: string) {
    const favorites = await prisma.favorite.findMany({
      where: { userId },
      include: {
        station: {
          include: {
            streams: true,
            category: true,
          },
        },
      },
    });

    return favorites.map((f) => ({
      ...f.station,
      isFavorite: true,
    }));
  }

  async toggleFavorite(userId: string, stationId: string) {
    const existing = await prisma.favorite.findUnique({
      where: {
        userId_stationId: {
          userId,
          stationId,
        },
      },
    });

    if (existing) {
      await prisma.favorite.delete({
        where: {
          userId_stationId: {
            userId,
            stationId,
          },
        },
      });
      return { isFavorite: false };
    } else {
      await prisma.favorite.create({
        data: {
          userId,
          stationId,
        },
      });
      return { isFavorite: true };
    }
  }
}

export default new FavoriteService();
