import 'package:equatable/equatable.dart';

/// Radio Station Model
/// 
/// Represents a radio station with all its metadata and properties.
/// This model is used throughout the app for station data management.
class Station extends Equatable {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String? description;
  final String? category;
  final String? country;
  final String? language;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? lastPlayed;
  final Map<String, dynamic>? metadata;

  const Station({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.description,
    this.category,
    this.country,
    this.language,
    this.tags = const [],
    this.isFavorite = false,
    this.lastPlayed,
    this.metadata,
  });

  /// Create a Station from JSON
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      streamUrl: json['streamUrl'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      country: json['country'] as String?,
      language: json['language'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Station to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'description': description,
      'category': category,
      'country': country,
      'language': language,
      'tags': tags,
      'isFavorite': isFavorite,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy of this Station with modified fields
  Station copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? description,
    String? category,
    String? country,
    String? language,
    List<String>? tags,
    bool? isFavorite,
    DateTime? lastPlayed,
    Map<String, dynamic>? metadata,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      country: country ?? this.country,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        streamUrl,
        logoUrl,
        description,
        category,
        country,
        language,
        tags,
        isFavorite,
        lastPlayed,
        metadata,
      ];

  @override
  String toString() => 'Station(id: $id, name: $name, category: $category)';
}

/// Now Playing Information
class NowPlayingInfo extends Equatable {
  final String title;
  final String artist;
  final String? album;
  final String? artworkUrl;
  final DateTime timestamp;

  const NowPlayingInfo({
    required this.title,
    required this.artist,
    this.album,
    this.artworkUrl,
    required this.timestamp,
  });

  /// Create NowPlayingInfo from Icy metadata string
  /// Format: "Artist - Title" or just "Title"
  factory NowPlayingInfo.fromIcyMetadata(String metadata) {
    if (metadata.isEmpty) {
      return NowPlayingInfo(
        title: 'Unknown',
        artist: 'Unknown Artist',
        timestamp: DateTime.now(),
      );
    }

    // Try to parse "Artist - Title" format
    final parts = metadata.split(' - ');
    if (parts.length >= 2) {
      return NowPlayingInfo(
        artist: parts[0].trim(),
        title: parts.sublist(1).join(' - ').trim(),
        timestamp: DateTime.now(),
      );
    }

    // If no separator found, assume it's just the title
    return NowPlayingInfo(
      title: metadata.trim(),
      artist: 'Unknown Artist',
      timestamp: DateTime.now(),
    );
  }

  /// Create an empty NowPlayingInfo
  factory NowPlayingInfo.empty() {
    return NowPlayingInfo(
      title: 'Unknown',
      artist: 'Unknown Artist',
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [title, artist, album, artworkUrl, timestamp];

  @override
  String toString() => 'NowPlayingInfo(title: $title, artist: $artist)';
}

/// Station Category (for API compatibility)
class Category extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;
  final int stationCount;

  const Category({
    required this.id,
    required this.name,
    this.iconUrl,
    this.stationCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String?,
      stationCount: json['stationCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'stationCount': stationCount,
    };
  }

  @override
  List<Object?> get props => [id, name, iconUrl, stationCount];
}

/// Station Category (alias for backward compatibility)
typedef StationCategory = Category;
