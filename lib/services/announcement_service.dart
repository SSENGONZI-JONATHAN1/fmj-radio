import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement.dart';

/// Announcement Service
/// 
/// Manages fetching, caching, and displaying announcements.
/// Provides banner and popup announcements with priority levels.
class AnnouncementService {
  static const String _cacheKey = 'announcements_cache';
  static const String _lastFetchKey = 'announcements_last_fetch';
  static const String _dismissedKey = 'announcements_dismissed';
  static const Duration _cacheDuration = Duration(minutes: 15);

  static final AnnouncementService _instance = AnnouncementService._internal();
  factory AnnouncementService() => _instance;
  AnnouncementService._internal();

  List<Announcement> _announcements = [];
  List<String> _dismissedIds = [];

  /// Initialize service
  Future<void> initialize() async {
    await _loadDismissedIds();
    await _loadCachedAnnouncements();
  }

  /// Fetch announcements from API
  /// Endpoint: GET /announcements
  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      // Check if we should use cached version
      if (await _isCacheValid()) {
        return _getActiveAnnouncements();
      }

      // TODO: Replace with actual API call
      // final response = await dio.get('/announcements');
      // final responseData = AnnouncementResponse.fromJson(response.data);
      
      // For demo, create sample announcements
      final sampleAnnouncements = _getSampleAnnouncements();
      
      // Cache and store
      _announcements = sampleAnnouncements;
      await _cacheAnnouncements();
      
      return _getActiveAnnouncements();
    } catch (e) {
      print('Error fetching announcements: $e');
      return _getActiveAnnouncements();
    }
  }

  /// Get sample announcements for demo
  List<Announcement> _getSampleAnnouncements() {
    return [
      Announcement(
        id: '1',
        title: 'LIVE NOW',
        message: 'Morning Show is live! Tune in now ☀️',
        priority: AnnouncementPriority.high,
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Announcement(
        id: '2',
        title: 'New Feature',
        message: 'Check out our new theme selector in settings!',
        priority: AnnouncementPriority.normal,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
      ),
    ];
  }

  /// Get active announcements (not expired, not dismissed)
  List<Announcement> _getActiveAnnouncements() {
    return _announcements.where((a) {
      return a.shouldShow && !_dismissedIds.contains(a.id);
    }).toList();
  }

  /// Get highest priority announcement for banner
  Announcement? get bannerAnnouncement {
    final active = _getActiveAnnouncements();
    if (active.isEmpty) return null;
    
    return active.reduce((curr, next) {
      if (curr.priority.index > next.priority.index) return curr;
      return next;
    });
  }

  /// Get all active announcements
  List<Announcement> get allActiveAnnouncements => _getActiveAnnouncements();

  /// Dismiss an announcement
  Future<void> dismissAnnouncement(String id) async {
    if (!_dismissedIds.contains(id)) {
      _dismissedIds.add(id);
      await _saveDismissedIds();
    }
  }

  /// Clear all dismissed announcements
  Future<void> clearDismissed() async {
    _dismissedIds.clear();
    await _saveDismissedIds();
  }

  /// Load cached announcements
  Future<void> _loadCachedAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      
      if (cachedJson != null) {
        final List<dynamic> jsonList = jsonDecode(cachedJson) as List<dynamic>;
        _announcements = jsonList
            .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading cached announcements: $e');
    }
  }

  /// Cache announcements
  Future<void> _cacheAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _announcements.map((a) => a.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
      await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching announcements: $e');
    }
  }

  /// Load dismissed announcement IDs
  Future<void> _loadDismissedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dismissedIds = prefs.getStringList(_dismissedKey) ?? [];
    } catch (e) {
      print('Error loading dismissed IDs: $e');
    }
  }

  /// Save dismissed announcement IDs
  Future<void> _saveDismissedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_dismissedKey, _dismissedIds);
    } catch (e) {
      print('Error saving dismissed IDs: $e');
    }
  }

  /// Check if cache is valid
  Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt(_lastFetchKey);
      
      if (lastFetch == null) return false;
      
      final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
      return DateTime.now().difference(lastFetchTime) < _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// Force refresh announcements
  Future<List<Announcement>> forceRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastFetchKey);
    return fetchAnnouncements();
  }

  /// Create a new announcement (for admin/dashboard)
  Future<void> createAnnouncement(Announcement announcement) async {
    _announcements.add(announcement);
    await _cacheAnnouncements();
  }

  /// Delete an announcement
  Future<void> deleteAnnouncement(String id) async {
    _announcements.removeWhere((a) => a.id == id);
    await _cacheAnnouncements();
  }

  /// Stream of announcements for real-time updates
  Stream<List<Announcement>> get announcementsStream async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      yield await fetchAnnouncements();
    }
  }
}
