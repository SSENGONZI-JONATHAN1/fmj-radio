import 'package:equatable/equatable.dart';

/// Announcement Model
/// 
/// Represents announcements/banners that can be displayed in the app
/// Priority levels: low, normal, high, urgent
class Announcement extends Equatable {
  final String id;
  final String title;
  final String message;
  final AnnouncementPriority priority;
  final DateTime? expiryTime;
  final bool sendPushNotification;
  final String? actionUrl;
  final String? actionLabel;
  final DateTime createdAt;
  final bool isActive;

  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.priority = AnnouncementPriority.normal,
    this.expiryTime,
    this.sendPushNotification = false,
    this.actionUrl,
    this.actionLabel,
    required this.createdAt,
    this.isActive = true,
  });

  /// Create Announcement from JSON
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      priority: AnnouncementPriority.fromString(
        json['priority'] as String? ?? 'normal',
      ),
      expiryTime: json['expiryTime'] != null
          ? DateTime.parse(json['expiryTime'] as String)
          : null,
      sendPushNotification: json['sendPushNotification'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      actionLabel: json['actionLabel'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert Announcement to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'priority': priority.value,
      'expiryTime': expiryTime?.toIso8601String(),
      'sendPushNotification': sendPushNotification,
      'actionUrl': actionUrl,
      'actionLabel': actionLabel,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Check if announcement is expired
  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  /// Check if announcement should be shown
  bool get shouldShow => isActive && !isExpired;

  /// Get color based on priority
  AnnouncementColors get colors {
    switch (priority) {
      case AnnouncementPriority.low:
        return const AnnouncementColors(
          background: '#3B82F6',
          text: '#FFFFFF',
          accent: '#60A5FA',
        );
      case AnnouncementPriority.normal:
        return const AnnouncementColors(
          background: '#10B981',
          text: '#FFFFFF',
          accent: '#34D399',
        );
      case AnnouncementPriority.high:
        return const AnnouncementColors(
          background: '#F59E0B',
          text: '#FFFFFF',
          accent: '#FBBF24',
        );
      case AnnouncementPriority.urgent:
        return const AnnouncementColors(
          background: '#EF4444',
          text: '#FFFFFF',
          accent: '#F87171',
        );
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        priority,
        expiryTime,
        sendPushNotification,
        actionUrl,
        actionLabel,
        createdAt,
        isActive,
      ];

  @override
  String toString() => 'Announcement(id: $id, title: $title, priority: $priority)';
}

/// Announcement Priority Levels
enum AnnouncementPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  final String value;
  const AnnouncementPriority(this.value);

  factory AnnouncementPriority.fromString(String value) {
    return AnnouncementPriority.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => AnnouncementPriority.normal,
    );
  }
}

/// Announcement Color Scheme
class AnnouncementColors extends Equatable {
  final String background;
  final String text;
  final String accent;

  const AnnouncementColors({
    required this.background,
    required this.text,
    required this.accent,
  });

  @override
  List<Object?> get props => [background, text, accent];
}

/// Announcement Response from API
class AnnouncementResponse extends Equatable {
  final List<Announcement> announcements;
  final int totalCount;
  final bool hasMore;

  const AnnouncementResponse({
    required this.announcements,
    required this.totalCount,
    this.hasMore = false,
  });

  factory AnnouncementResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
    return AnnouncementResponse(
      announcements: data
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  /// Get only active and non-expired announcements
  List<Announcement> get activeAnnouncements {
    return announcements.where((a) => a.shouldShow).toList();
  }

  /// Get highest priority announcement
  Announcement? get highestPriority {
    final active = activeAnnouncements;
    if (active.isEmpty) return null;
    
    return active.reduce((curr, next) {
      if (curr.priority.index > next.priority.index) return curr;
      return next;
    });
  }

  @override
  List<Object?> get props => [announcements, totalCount, hasMore];
}
