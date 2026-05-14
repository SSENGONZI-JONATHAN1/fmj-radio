import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/player_bloc.dart';
import '../blocs/station_bloc.dart';
import '../models/station.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Implement sorting
            },
          ),
        ],
      ),
      body: BlocBuilder<StationBloc, StationState>(
        builder: (context, state) {
          if (state is StationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesLoaded) {
            final favorites = state.favorites;

            if (favorites.isEmpty) {
              return _buildEmptyState(context);
            }

            return _buildFavoritesList(context, favorites);
          }

          if (state is StationError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          // Initial state - load favorites
          context.read<StationBloc>().add(LoadFavorites());
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add stations to your favorites\nto access them quickly',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to discover screen
              Navigator.pushNamed(context, '/discover');
            },
            child: const Text('Discover Stations'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, List<Station> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final station = favorites[index];
        return _buildFavoriteCard(context, station);
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Station station) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: station.logoUrl != null
              ? Image.network(
                  station.logoUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.radio, color: Colors.white),
                    );
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.radio, color: Colors.white),
                ),
        ),
        title: Text(
          station.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              station.category ?? 'Internet Radio',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (station.country != null) ...[
              const SizedBox(height: 2),
              Text(
                station.country!,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play button
            IconButton(
              icon: const Icon(Icons.play_circle_fill),
              color: Theme.of(context).colorScheme.primary,
              iconSize: 40,
              onPressed: () {
                // Play the station
                context.read<PlayerBloc>().add(PlayStation(station));
                // Navigate to player screen
                Navigator.pushNamed(context, '/player');
              },
            ),
            // Remove from favorites
            IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.red,
              onPressed: () {
                // Remove from favorites
                context.read<StationBloc>().add(ToggleStationFavorite(station));
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${station.name} removed from favorites'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        context.read<StationBloc>().add(ToggleStationFavorite(station));
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          // Play the station
          context.read<PlayerBloc>().add(PlayStation(station));
          Navigator.pushNamed(context, '/player');
        },
      ),
    );
  }
}
