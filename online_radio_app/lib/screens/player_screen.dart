import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/player_bloc.dart';


import '../blocs/station_bloc.dart';
import '../models/station.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/sleep_timer_dialog.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state is PlayerInitial) {
            return const Center(child: Text('Select a station to play'));
          }

          if (state is PlayerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlayerError) {
            return Center(child: Text('Error: ${(state as PlayerError).message}'));
          }

          if (state is PlayerPlaying || state is PlayerPaused) {
            final isPlaying = state is PlayerPlaying;
            final station = isPlaying
                ? (state as PlayerPlaying).station
                : (state as PlayerPaused).station;
            final nowPlaying = isPlaying
                ? (state as PlayerPlaying).nowPlaying
                : (state as PlayerPaused).nowPlaying;
            final volume = isPlaying
                ? (state as PlayerPlaying).volume
                : (state as PlayerPaused).volume;
            final isFavorite = isPlaying
                ? (state as PlayerPlaying).isFavorite
                : (state as PlayerPaused).isFavorite;

            return _buildPlayerUI(
              context,
              station: station,
              nowPlaying: nowPlaying,
              isPlaying: isPlaying,
              volume: volume,
              isFavorite: isFavorite,
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildPlayerUI(
    BuildContext context, {
    required Station station,
    required NowPlayingInfo nowPlaying,
    required bool isPlaying,
    required double volume,
    required bool isFavorite,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context, station),

            // Station Artwork
            _buildArtwork(context, station),

            // Audio Visualizer
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: AudioVisualizer(
                isPlaying: isPlaying,
                visualizerType: VisualizerType.wave,
              ),
            ),



            // Now Playing Info
            const SizedBox(height: 30),
            _buildNowPlayingInfo(context, nowPlaying),

            // Controls
            const SizedBox(height: 40),
            _buildControls(
              context,
              isPlaying: isPlaying,
              volume: volume,
              isFavorite: isFavorite,
              station: station,
            ),

            // Bottom Actions
            const Spacer(),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Station station) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Now Playing',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(BuildContext context, Station station) {
    return Container(
      width: 250,
      height: 250,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: station.logoUrl != null
            ? Image.network(
                station.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.radio,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              )
            : Container(
                color: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.radio,
                  size: 80,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildNowPlayingInfo(BuildContext context, NowPlayingInfo nowPlaying) {
    return Column(
      children: [
        Text(
          nowPlaying.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          nowPlaying.artist,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildControls(
    BuildContext context, {
    required bool isPlaying,
    required double volume,
    required bool isFavorite,
    required Station station,
  }) {
    return Column(
      children: [
        // Play/Pause Button
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              context.read<PlayerBloc>().add(TogglePlayPause());
            },
          ),
        ),

        const SizedBox(height: 30),

        // Volume Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              const Icon(Icons.volume_mute, size: 20),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: (value) {
                    context.read<PlayerBloc>().add(UpdateVolume(value));
                  },
                ),
              ),
              const Icon(Icons.volume_up, size: 20),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Favorite Button
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
                size: 30,
              ),
              onPressed: () {
                // Toggle favorite in player
                context.read<PlayerBloc>().add(TogglePlayerFavorite(station));
                // Also toggle in station bloc for persistence
                context.read<StationBloc>().add(ToggleStationFavorite(station));
              },
            ),

            const SizedBox(width: 40),

            // Sleep Timer Button
            IconButton(
              icon: const Icon(Icons.timer, size: 30),
              onPressed: () => _showSleepTimerDialog(context),
            ),

            const SizedBox(width: 40),

            // Share Button
            IconButton(
              icon: const Icon(Icons.share, size: 30),
              onPressed: () => _shareStation(context, station),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            icon: Icons.playlist_add,
            label: 'Add to Playlist',
            onTap: () {},
          ),
          _buildActionButton(
            context,
            icon: Icons.record_voice_over,
            label: 'Record',
            onTap: () {},
          ),
          _buildActionButton(
            context,
            icon: Icons.lyrics,
            label: 'Lyrics',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Station Info'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Issue'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SleepTimerDialog(),
    );
  }

  void _shareStation(BuildContext context, Station station) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${station.name}')),
    );
  }
}
