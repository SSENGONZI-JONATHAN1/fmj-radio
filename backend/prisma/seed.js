import { PrismaClient } from '@prisma/client';
import fetch from 'node-fetch';
const prisma = new PrismaClient();
async function main() {
    console.log('--- Starting Seed Process ---');
    // 1. Seed App Configuration
    console.log('Seeding AppConfig...');
    await prisma.appConfig.upsert({
        where: { id: 'default-config' },
        update: {},
        create: {
            id: 'default-config',
            globalStationName: 'FMJ Radio Global',
            defaultLogoUrl: 'https://i.imgur.com/JfmLogo.png',
            primaryColorHex: '#FF5722',
            secondaryColorHex: '#2196F3',
            maintenanceMode: false,
            minimumAppVersion: '1.0.0',
            socialMediaLinks: {
                facebook: 'https://facebook.com/fmjradio',
                twitter: 'https://twitter.com/fmjradio',
                instagram: 'https://instagram.com/fmjradio',
                website: 'https://fmjradio.com'
            }
        },
    });
    // 2. Seed Announcements
    console.log('Seeding Announcements...');
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 7); // Expires in a week
    await prisma.announcement.upsert({
        where: { id: 'welcome-announcement' },
        update: {},
        create: {
            id: 'welcome-announcement',
            title: 'Welcome to FMJ Radio! 🎧',
            message: 'Explore over 40,000 live stations from around the world. High quality streaming, zero cost.',
            priority: 'Normal',
            expiryDate: tomorrow,
        },
    });
    // 3. Fetch and Seed Stations
    console.log('Fetching stations from Radio Browser API...');
    const response = await fetch('https://de1.api.radio-browser.info/json/stations/topclick/30');
    const stations = await response.json();
    console.log(`Found ${stations.length} stations. Processing...`);
    for (let i = 0; i < stations.length; i++) {
        const s = stations[i];
        const categoryName = s.tags.split(',')[0] || 'General';
        const category = await prisma.category.upsert({
            where: { name: categoryName },
            update: {},
            create: { name: categoryName },
        });
        await prisma.station.upsert({
            where: { slug: s.stationuuid },
            update: {},
            create: {
                id: s.stationuuid,
                slug: s.stationuuid,
                name: s.name,
                description: `Language: ${s.language}, Country: ${s.country}. ${s.tags}`,
                logoUrl: s.favicon || 'https://i.imgur.com/JfmLogo.png',
                country: s.country,
                language: s.language,
                status: 'Active',
                categoryId: category.id,
                // Mark first 5 as featured, next 5 as trending
                isFeatured: i < 5,
                isTrending: i >= 5 && i < 10,
                streams: {
                    create: {
                        url: s.url_resolved || s.url,
                        bitrate: s.bitrate,
                        quality: 'Medium',
                    }
                }
            },
        });
    }
    console.log('✅ Database fully seeded!');
}
main()
    .catch((e) => {
    console.error(e);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map