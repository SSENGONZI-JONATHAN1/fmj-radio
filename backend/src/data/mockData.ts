import type { Station } from '../models/Station.js';
import type { Category } from '../models/Category.js';

export const MOCK_STATIONS: Station[] = [
  {
    id: 'jfm-1',
    name: 'Jfm Radio - Hits',
    streamUrl: 'https://stream.zeno.fm/0r0xapr5mceuv',
    logoUrl: 'https://i.imgur.com/JfmLogo.png',
    description: 'The best of contemporary pop and chart-topping hits.',
    category: 'pop',
    country: 'International',
    language: 'English',
    tags: ['Pop', 'Hits', 'Contemporary'],
    isFavorite: false,
    metadata: { bitrate: '128kbps', format: 'mp3' }
  },
  {
    id: 'jfm-2',
    name: 'Jfm Radio - Jazz & Chill',
    streamUrl: 'https://stream.zeno.fm/0r0xapr5mceuv', // Using same for demo
    logoUrl: 'https://i.imgur.com/JfmLogo.png',
    description: 'Smooth jazz and relaxing chillout tunes.',
    category: 'jazz',
    country: 'International',
    language: 'English',
    tags: ['Jazz', 'Chillout', 'Relaxing'],
    isFavorite: false,
    metadata: { bitrate: '128kbps', format: 'mp3' }
  },
  {
    id: 'jfm-3',
    name: 'Jfm Radio - Rock Classics',
    streamUrl: 'https://stream.zeno.fm/0r0xapr5mceuv',
    logoUrl: 'https://i.imgur.com/JfmLogo.png',
    description: 'Legendary rock tracks from all decades.',
    category: 'rock',
    country: 'USA',
    language: 'English',
    tags: ['Rock', 'Classics', 'Legendary'],
    isFavorite: false,
    metadata: { bitrate: '128kbps', format: 'mp3' }
  },
  {
    id: 'jfm-4',
    name: 'Jfm Radio - News & Talk',
    streamUrl: 'https://stream.zeno.fm/0r0xapr5mceuv',
    logoUrl: 'https://i.imgur.com/JfmLogo.png',
    description: 'Latest news, interviews, and talk shows.',
    category: 'news',
    country: 'International',
    language: 'English',
    tags: ['News', 'Talk', 'Information'],
    isFavorite: false,
    metadata: { bitrate: '128kbps', format: 'mp3' }
  },
  {
    id: 'jfm-5',
    name: 'Jfm Radio - Top 40',
    streamUrl: 'https://stream.zeno.fm/0r0xapr5mceuv',
    logoUrl: 'https://i.imgur.com/JfmLogo.png',
    description: 'The absolute best of today\'s music.',
    category: 'pop',
    country: 'International',
    language: 'English',
    tags: ['Pop', 'Top40', 'Hits'],
    isFavorite: false,
    metadata: { bitrate: '128kbps', format: 'mp3' }
  },
  {
    id: 'jfm-6',
    name: 'Jfm Radio - Soft Pop',
    streamUrl: 'https://stream.zeno.fm/0r0xapr5mceuv',
    logoUrl: 'https://i.imgur.com/JfmLogo.png',
    description: 'Mellow pop tracks for a relaxing afternoon.',
    category: 'pop',
    country: 'International',
    language: 'English',
    tags: ['Pop', 'Soft', 'Relax'],
    isFavorite: false,
    metadata: { bitrate: '128kbps', format: 'mp3' }
  }
];

export const MOCK_CATEGORIES: Category[] = [
  { id: 'pop', name: 'Pop', stationCount: 150 },
  { id: 'rock', name: 'Rock', stationCount: 120 },
  { id: 'jazz', name: 'Jazz', stationCount: 80 },
  { id: 'news', name: 'News & Talk', stationCount: 90 },
  { id: 'sports', name: 'Sports', stationCount: 70 },
  { id: 'classical', name: 'Classical', stationCount: 60 }
];

export const MOCK_COUNTRIES = [
  { id: 'international', name: 'International' },
  { id: 'usa', name: 'USA' },
  { id: 'uk', name: 'UK' },
  { id: 'canada', name: 'Canada' },
  { id: 'germany', name: 'Germany' },
  { id: 'france', name: 'France' }
];

export const MOCK_LANGUAGES = [
  { id: 'english', name: 'English' },
  { id: 'spanish', name: 'Spanish' },
  { id: 'french', name: 'French' },
  { id: 'german', name: 'German' },
  { id: 'italian', name: 'Italian' }
];
