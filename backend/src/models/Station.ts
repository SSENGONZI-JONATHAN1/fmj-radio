export interface Station {
  id: string;
  name: string;
  streamUrl: string;
  logoUrl?: string;
  description?: string;
  category?: string;
  country?: string;
  language?: string;
  tags: string[];
  isFavorite: boolean;
  lastPlayed?: string; // ISO Date string
  metadata?: Record<string, any>;
}

export interface NowPlayingInfo {
  title: string;
  artist: string;
  album?: string;
  artworkUrl?: string;
  timestamp: string;
}
