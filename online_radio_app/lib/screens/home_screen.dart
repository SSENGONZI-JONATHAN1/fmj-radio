import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../blocs/player_bloc.dart';
import '../data/working_stations.dart';
import '../models/station.dart';
import '../services/location_service.dart';
import '../widgets/animated_gradient_background.dart';
import 'player_screen.dart';

/// Professional Home Screen with Local/Global tabs
/// Animated gradient background, search functionality, location-based stations
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userCountry = 'Global';
  List<Station> _localStations = [];
  List<Station> _globalStations = [];
  List<Station> _filteredStations = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadLocationAndStations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _filterStations();
      });
    }
  }

  Future<void> _loadLocationAndStations() async {
    setState(() => _isLoading = true);
    
    try {
      // Get user location
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _userCountry = LocationService.getCountryFromPosition(position);
      }
      
      // Load stations based on location
      _localStations = WorkingStations.getLocalStations(_userCountry);
      _globalStations = WorkingStations.getGlobalStations(_userCountry);
      
      // If no local stations found, show all as global
      if (_localStations.isEmpty) {
        _localStations = WorkingStations.africaStations.take(6).toList();
        _globalStations = WorkingStations.allStations
            .where((s) => !_localStations.contains(s))
            .toList();
      }
      
      _filterStations();
    } catch (e) {
      print('Error loading location: $e');
      // Fallback to default stations
      _localStations = WorkingStations.africaStations.take(6).toList();
      _globalStations = WorkingStations.allStations
          .where((s) => !_localStations.contains(s))
          .take(20)
          .toList();
      _filterStations();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterStations() {
    final query = _searchQuery.toLowerCase();
    final currentList = _tabController.index == 0 ? _localStations : _globalStations;
    
    if (query.isEmpty) {
      _filteredStations = currentList;
    } else {
      _filteredStations = currentList.where((station) {
        return station.name.toLowerCase().contains(query) ||
            (station.category?.toLowerCase().contains(query) ?? false) ||
            (station.country?.toLowerCase().contains(query) ?? false) ||
            (station.tags?.any((tag) => tag.toLowerCase().contains(query)) ?? false);
      }).toList();
    }
    setState(() {});
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        drawer: _buildSideMenu(),
        body: _isLoading ? _buildLoadingView() : _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Online Radio',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            _userCountry == 'Global' ? 'Global Stations' : 'Stations in $_userCountry',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: StationSearchDelegate(
                stations: WorkingStations.allStations,
                onStationSelected: (station) {
                  context.read<PlayerBloc>().add(PlayStation(station));
                  Navigator.pushNamed(context, '/player');
                },
              ),
            );
          },
        ),
        // Refresh location
        IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: _loadLocationAndStations,
          tooltip: 'Update location',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Build the side menu drawer with navigation to all screens
  Widget _buildSideMenu() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.8),
                  Colors.blue.withOpacity(0.6),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.radio,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Online Radio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover. Listen. Enjoy.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildMenuItem(
                  icon: Icons.home,
                  title: 'Home',
                  subtitle: 'Browse stations',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  isActive: true,
                ),
                _buildMenuItem(
                  icon: Icons.favorite,
                  title: 'Favorites',
                  subtitle: 'Your saved stations',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/favorites');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.explore,
                  title: 'Discover',
                  subtitle: 'Find new stations',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/discover');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.mood,
                  title: 'Mood Radio',
                  subtitle: 'Stations by mood',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/mood');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.mic,
                  title: 'Recordings',
                  subtitle: 'Your saved recordings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/recordings');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.trending_up,
                  title: 'Statistics',
                  subtitle: 'Your listening stats',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/statistics');
                  },
                ),
                const Divider(color: Colors.white24, height: 20, indent: 20, endIndent: 20),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.cloud,
                  title: 'Backend Hub',
                  subtitle: 'Developer tools',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/backend');
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.purple.withOpacity(0.3) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isActive 
              ? Border.all(color: Colors.purple.withOpacity(0.5)) 
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.purple : Colors.white70,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.purple : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: isActive 
          ? const Icon(Icons.arrow_forward_ios, color: Colors.purple, size: 16)
          : Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 16),
      onTap: onTap,
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true, () {}),
              _buildNavItem(Icons.favorite, 'Favorites', false, () {
                Navigator.pushNamed(context, '/favorites');
              }),
              _buildNavItem(Icons.play_circle_filled, 'Player', false, () {
                Navigator.pushNamed(context, '/player');
              }),
              _buildNavItem(Icons.explore, 'Discover', false, () {
                Navigator.pushNamed(context, '/discover');
              }),
              _buildNavItem(Icons.settings, 'Settings', false, () {
                Navigator.pushNamed(context, '/settings');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? Colors.purple.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.purple : Colors.white.withOpacity(0.6),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.purple : Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Finding radio stations near you...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),
        
        // Tab selector (Local/Global)
        _buildTabSelector(),
        
        // Section title
        _buildSectionTitle(),
        
        // Stations list
        Expanded(
          child: _filteredStations.isEmpty
              ? _buildEmptyState()
              : _buildStationsList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search stations, genres, countries...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.6)),
                    onPressed: () {
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Text('LOCAL (${_localStations.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.public, size: 18),
                  const SizedBox(width: 6),
                  Text('GLOBAL (${_globalStations.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    final isLocal = _tabController.index == 0;
    final title = isLocal ? 'Local Radio Stations' : 'Global Radio Stations';
    final subtitle = isLocal
        ? 'Stations broadcasting from $_userCountry'
        : 'International stations from around the world';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${_filteredStations.length} results for "$_searchQuery"',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredStations.length,
      itemBuilder: (context, index) {
        final station = _filteredStations[index];
        return _buildStationCard(station, index);
      },
    );
  }

  Widget _buildStationCard(Station station, int index) {
    // Check if this station is currently playing
    final playerState = context.watch<PlayerBloc>().state;
    bool isPlaying = false;
    bool isCurrentStation = false;
    
    if (playerState is PlayerPlaying) {
      isCurrentStation = playerState.station.id == station.id;
      isPlaying = isCurrentStation;
    } else if (playerState is PlayerPaused) {
      isCurrentStation = playerState.station.id == station.id;
      isPlaying = false;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying 
              ? Colors.purple.withOpacity(0.5) 
              : Colors.white.withOpacity(0.1),
        ),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Hero(
          tag: 'station_${station.id}',
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.primaries[index % Colors.primaries.length],
                  Colors.primaries[(index + 1) % Colors.primaries.length],
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isPlaying
                  ? const PulsingGlow(
                      color: Colors.green,
                      size: 15,
                      child: Icon(
                        Icons.graphic_eq,
                        color: Colors.white,
                        size: 30,
                      ),
                    )
                  : const Icon(
                      Icons.radio,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
          ),
        ),
        title: Text(
          station.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${station.category ?? 'Radio'} • ${station.country ?? 'International'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            if (station.description != null) ...[
              const SizedBox(height: 2),
              Text(
                station.description!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: isPlaying ? Colors.purple : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              if (isPlaying) {
                context.read<PlayerBloc>().add(PausePlayback());
              } else {
                context.read<PlayerBloc>().add(PlayStation(station));
                Navigator.pushNamed(context, '/player');
              }
            },
          ),
        ),
        onTap: () {
          context.read<PlayerBloc>().add(PlayStation(station));
          Navigator.pushNamed(context, '/player');
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isLocal = _tabController.index == 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLocal ? Icons.location_off : Icons.radio_button_off,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isLocal ? 'No local stations found' : 'No global stations found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLocal
                ? 'Try switching to Global tab or refresh your location'
                : 'Check your internet connection',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (isLocal) {
                _tabController.animateTo(1);
              } else {
                _loadLocationAndStations();
              }
            },
            icon: Icon(isLocal ? Icons.public : Icons.refresh),
            label: Text(isLocal ? 'Browse Global' : 'Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search delegate for station search
class StationSearchDelegate extends SearchDelegate<Station?> {
  final List<Station> stations;
  final Function(Station) onStationSelected;

  StationSearchDelegate({
    required this.stations,
    required this.onStationSelected,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = stations.where((station) {
      return station.name.toLowerCase().contains(query.toLowerCase()) ||
          (station.category?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (station.country?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No stations found for "$query"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final station = results[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.primaries[index % Colors.primaries.length],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.radio, color: Colors.white),
          ),
          title: Text(station.name),
          subtitle: Text('${station.category ?? 'Radio'} • ${station.country ?? 'International'}'),
          onTap: () {
            onStationSelected(station);
            close(context, station);
          },
        );
      },
    );
  }
}
