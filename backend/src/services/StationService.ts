import prisma from '../lib/prisma.js';
import { type Prisma } from '@prisma/client';
import { type Station } from '../models/Station.js';

class StationService {
  async getAllStations(filters: {
    category?: string;
    country?: string;
    language?: string;
    search?: string;
    page: number;
    limit: number;
  }, userId?: string): Promise<{ data: Station[], totalCount: number, page: number, limit: number, hasMore: boolean }> {
    const where: Prisma.StationWhereInput = {};

    if (filters.category) {
      where.category = { id: filters.category };
    }
    if (filters.country) {
      where.country = { equals: filters.country, mode: 'insensitive' };
    }
    if (filters.language) {
      where.language = { equals: filters.language, mode: 'insensitive' };
    }
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    const [stations, totalCount] = await Promise.all([
      prisma.station.findMany({
        where,
        include: {
          streams: true,
          category: true,
          favorites: userId ? { where: { userId } } : false,
        },
        skip: (filters.page - 1) * filters.limit,
        take: filters.limit,
      }),
      prisma.station.count({ where }),
    ]);

    const formattedStations = stations.map(s => this.formatStation(s, userId));

    return {
      data: formattedStations,
      totalCount,
      page: filters.page,
      limit: filters.limit,
      hasMore: (filters.page * filters.limit) < totalCount
    };
  }

  async getStationById(id: string, userId?: string) {
    const station = await prisma.station.findUnique({
      where: { id },
      include: {
        streams: true,
        category: true,
        favorites: userId ? { where: { userId } } : false,
      },
    });

    return station ? this.formatStation(station, userId) : null;
  }

  async getFeaturedStations(userId?: string) {
    const stations = await prisma.station.findMany({
      where: { isFeatured: true },
      include: {
        streams: true,
        category: true,
        favorites: userId ? { where: { userId } } : false,
      },
      take: 10,
    });
    return stations.map(s => this.formatStation(s, userId));
  }

  async getTrendingStations(userId?: string) {
    const stations = await prisma.station.findMany({
      where: { isTrending: true },
      include: {
        streams: true,
        category: true,
        favorites: userId ? { where: { userId } } : false,
      },
      take: 10,
    });
    return stations.map(s => this.formatStation(s, userId));
  }

  async searchStations(query: string, userId?: string) {
    const stations = await prisma.station.findMany({
      where: {
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
        ],
      },
      include: {
        streams: true,
        category: true,
        favorites: userId ? { where: { userId } } : false,
      },
      take: 20,
    });
    return stations.map(s => this.formatStation(s, userId));
  }

  async getSimilarStations(id: string, userId?: string) {
    const station = await prisma.station.findUnique({ where: { id } });
    if (!station || !station.categoryId) return [];

    const stations = await prisma.station.findMany({
      where: {
        categoryId: station.categoryId,
        id: { not: id },
      },
      include: {
        streams: true,
        category: true,
        favorites: userId ? { where: { userId } } : false,
      },
      take: 5,
    });
    return stations.map(s => this.formatStation(s, userId));
  }

  async getCountries() {
    const countries = await prisma.station.groupBy({
      by: ['country'],
      _count: { id: true },
      where: { country: { not: null } },
    });
    return countries.map(c => ({ id: c.country!.toLowerCase(), name: c.country }));
  }

  async getLanguages() {
    const languages = await prisma.station.groupBy({
      by: ['language'],
      _count: { id: true },
      where: { language: { not: null } },
    });
    return languages.map(l => ({ id: l.language!.toLowerCase(), name: l.language }));
  }

  // Helper to map DB model to API model expected by Flutter
  private formatStation(s: any, userId?: string) {
    return {
      id: s.id,
      name: s.name,
      streamUrl: s.streams[0]?.url || '',
      logoUrl: s.logoUrl,
      description: s.description,
      category: s.category?.name,
      country: s.country,
      language: s.language,
      tags: [], // Could implement Tag relation if needed
      isFavorite: userId ? s.favorites.length > 0 : false,
      metadata: {
        bitrate: s.streams[0]?.bitrate,
        quality: s.streams[0]?.quality,
      }
    };
  }
}

export default new StationService();
