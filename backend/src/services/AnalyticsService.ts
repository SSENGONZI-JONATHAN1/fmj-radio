class AnalyticsService {
  async reportListening(data: any) {
    // Mock analytics reporting
    console.log('Analytics reported:', data);
    return { success: true };
  }
}

export default new AnalyticsService();
