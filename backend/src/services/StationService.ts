import { MOCK_STATIONS } from '../data/mockData.js';
import { Station } from '../models/Station.js';

class StationService {
  async getAllStations(filters: {
    category?: string;
    country?: string;
    language?: string;
    search?: string;
    page: number;
    limit: number;
  }) {
    let stations = [...MOCK_STATIONS];

    // Apply filters
    if (filters.category) {
      stations = stations.filter(s => s.category?.toLowerCase() === filters.category?.toLowerCase());
    }

    if (filters.country) {
      stations = stations.filter(s => s.country?.toLowerCase() === filters.country?.toLowerCase());
    }

    if (filters.language) {
      stations = stations.filter(s => s.language?.toLowerCase() === filters.language?.toLowerCase());
    }

    if (filters.search) {
      const query = filters.search.toLowerCase();
      stations = stations.filter(s => 
        s.name.toLowerCase().includes(query) || 
        s.description?.toLowerCase().includes(query) ||
        s.tags.some(tag => tag.toLowerCase().includes(query))
      );
    }

    // Pagination
    const startIndex = (filters.page - 1) * filters.limit;
    const paginatedStations = stations.slice(startIndex, startIndex + filters.limit);

    return {
      data: paginatedStations,
      totalCount: stations.length,
      page: filters.page,
      limit: filters.limit,
      hasMore: startIndex + filters.limit < stations.length
    };
  }

  async getStationById(id: string) {
    return MOCK_STATIONS.find(s => s.id === id);
  }

  async getFeaturedStations() {
    // For now, return first 2 as featured
    return MOCK_STATIONS.slice(0, 2);
  }

  async getTrendingStations() {
    // Return last 2 as trending
    return MOCK_STATIONS.slice(-2);
  }
}

export default new StationService();
