class LyricsService {
  async getLyrics(title: string, artist: string) {
    // Mock lyrics response
    return {
      title,
      artist,
      lyrics: `This is a mock lyrics for ${title} by ${artist}.\nEnjoy the music on Jfm Radio!`
    };
  }
}

export default new LyricsService();
