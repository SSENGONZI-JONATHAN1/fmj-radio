import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/announcement.dart';

/// AnnouncementService
///
/// Minimal service that provides announcements to the app. It will try
/// to load `assets/announcements.json` if present, otherwise start
/// with an empty list.
class AnnouncementService {
  List<Announcement> _announcements = [];

  AnnouncementService();

  Announcement? get bannerAnnouncement {
    final active = _announcements.where((a) => a.shouldShow).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return active.first;
  }

  /// Initialize the service. Attempts to load `assets/announcements.json`.
  Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('assets/announcements.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = jsonMap['data'] as List<dynamic>? ?? [];
      _announcements = data.map((e) => Announcement.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // No announcements or asset missing — keep empty list
      _announcements = [];
    }
  }

  Future<List<Announcement>> fetchAnnouncements() async {
    return _announcements;
  }
}
