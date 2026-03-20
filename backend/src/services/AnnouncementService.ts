import prisma from '../lib/prisma.js';

class AnnouncementService {
  async getActiveAnnouncements() {
    const announcements = await prisma.announcement.findMany({
      where: {
        expiryDate: {
          gt: new Date()
        }
      },
      orderBy: {
        priority: 'desc'
      }
    });

    // Fallback for development if no data in DB
    if (announcements.length === 0) {
      return [
        {
          id: 'dev-1',
          title: 'Welcome to Jfm Radio',
          message: 'Enjoy our premium streaming experience!',
          priority: 'Normal',
          createdAt: new Date(),
          expiryDate: new Date(Date.now() + 86400000)
        }
      ];
    }

    return announcements;
  }
}

export default new AnnouncementService();
