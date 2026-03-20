import prisma from '../lib/prisma.js';

class AppConfigService {
  async getConfig() {
    let config = await prisma.appConfig.findFirst();

    // If no config exists, return a default one (matching Flutter model)
    if (!config) {
      return {
        id: 'default',
        globalStationName: 'Jfm Radio',
        defaultLogoUrl: 'https://i.imgur.com/JfmLogo.png',
        primaryColorHex: '#FF5722',
        secondaryColorHex: '#2196F3',
        maintenanceMode: false,
        minimumAppVersion: '1.0.0',
        socialMediaLinks: {
          facebook: 'https://facebook.com/jfmradio',
          twitter: 'https://twitter.com/jfmradio',
          instagram: 'https://instagram.com/jfmradio'
        }
      };
    }

    return config;
  }
}

export default new AppConfigService();
