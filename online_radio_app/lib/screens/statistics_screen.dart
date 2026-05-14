import 'package:flutter/material.dart';

/// Listening Statistics Screen
/// 
/// Track listening habits and preferences
/// Shows: total listening time, favorite categories, top stations, listening streaks
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share statistics
              _shareStatistics(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            _buildSummaryCards(context),
            
            const SizedBox(height: 24),
            
            // Listening time chart
            _buildListeningTimeSection(context),
            
            const SizedBox(height: 24),
            
            // Top categories
            _buildTopCategoriesSection(context),
            
            const SizedBox(height: 24),
            
            // Top stations
            _buildTopStationsSection(context),
            
            const SizedBox(height: 24),
            
            // Listening streak
            _buildStreakSection(context),
            
            const SizedBox(height: 24),
            
            // Achievements
            _buildAchievementsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    // TODO: Replace with real data from backend/local storage
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            value: '127',
            label: 'Hours Listened',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.radio,
            value: '45',
            label: 'Stations',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department,
            value: '12',
            label: 'Day Streak',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListeningTimeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Listening Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                DropdownButton<String>(
                  value: 'This Week',
                  items: ['Today', 'This Week', 'This Month', 'All Time']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    // TODO: Update time range
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Simple bar chart
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Mon', 0.3, Colors.blue),
                  _buildBar('Tue', 0.5, Colors.blue),
                  _buildBar('Wed', 0.7, Colors.blue),
                  _buildBar('Thu', 0.4, Colors.blue),
                  _buildBar('Fri', 0.8, Colors.blue),
                  _buildBar('Sat', 0.9, Colors.blue),
                  _buildBar('Sun', 0.6, Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: 18.5 hours this week',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String day, double height, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 100 * height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesSection(BuildContext context) {
    // TODO: Replace with real data
    final categories = [
      {'name': 'Pop', 'percentage': 35, 'color': Colors.pink},
      {'name': 'Rock', 'percentage': 25, 'color': Colors.red},
      {'name': 'Jazz', 'percentage': 20, 'color': Colors.blue},
      {'name': 'Classical', 'percentage': 15, 'color': Colors.purple},
      {'name': 'Electronic', 'percentage': 5, 'color': Colors.teal},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat['name'] as String),
                        Text('${cat['percentage']}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (cat['percentage'] as int) / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        cat['color'] as Color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStationsSection(BuildContext context) {
    // TODO: Replace with real data
    final stations = [
      {'name': 'Pop Radio FM', 'hours': 24, 'category': 'Pop'},
      {'name': 'Classic Rock', 'hours': 18, 'category': 'Rock'},
      {'name': 'Smooth Jazz', 'hours': 12, 'category': 'Jazz'},
      {'name': 'EDM Radio', 'hours': 8, 'category': 'Electronic'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Stations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...stations.asMap().entries.map((entry) {
              final index = entry.key;
              final station = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: Text('${index + 1}'),
                ),
                title: Text(station['name'] as String),
                subtitle: Text(station['category'] as String),
                trailing: Text(
                  '${station['hours']}h',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange.shade700,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12 Day Streak! 🔥',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      Text(
                        'You\'ve listened to radio for 12 days in a row',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final isActive = index < 5; // First 5 days active
                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(days[index]),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    final achievements = [
      {
        'icon': Icons.star,
        'title': 'First Listen',
        'description': 'Played your first station',
        'unlocked': true,
        'color': Colors.yellow,
      },
      {
        'icon': Icons.favorite,
        'title': 'Collector',
        'description': 'Added 10 stations to favorites',
        'unlocked': true,
        'color': Colors.red,
      },
      {
        'icon': Icons.timer,
        'title': 'Marathon Listener',
        'description': 'Listened for 100 hours total',
        'unlocked': true,
        'color': Colors.blue,
      },
      {
        'icon': Icons.nightlight_round,
        'title': 'Night Owl',
        'description': 'Listened after midnight',
        'unlocked': false,
        'color': Colors.purple,
      },
      {
        'icon': Icons.public,
        'title': 'World Traveler',
        'description': 'Listened to stations from 5 countries',
        'unlocked': false,
        'color': Colors.green,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievements.map((achievement) {
                final unlocked = achievement['unlocked'] as bool;
                return Opacity(
                  opacity: unlocked ? 1.0 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (achievement['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (achievement['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          achievement['icon'] as IconData,
                          color: achievement['color'] as Color,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          achievement['description'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (unlocked)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _shareStatistics(BuildContext context) {
    // TODO: Implement sharing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Statistics'),
        content: const Text(
          'I\'ve listened to 127 hours of radio on Online Radio App! '
          'Can you beat my streak? 🔥',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statistics shared!')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
