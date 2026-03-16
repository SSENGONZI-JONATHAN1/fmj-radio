import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import '../models/station.dart';


/// Audio Player Service
/// 
/// Manages audio playback using just_audio and audio_service packages.
/// Handles streaming, metadata extraction, and background playback.
class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Streams for UI updates
  final BehaviorSubject<Station?> _currentStationController = BehaviorSubject<Station?>.seeded(null);
  final BehaviorSubject<NowPlayingInfo> _nowPlayingController = BehaviorSubject<NowPlayingInfo>.seeded(NowPlayingInfo.empty());
  final BehaviorSubject<bool> _isPlayingController = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<Duration> _positionController = BehaviorSubject<Duration>.seeded(Duration.zero);
  final BehaviorSubject<Duration?> _durationController = BehaviorSubject<Duration?>.seeded(null);
  final BehaviorSubject<double> _volumeController = BehaviorSubject<double>.seeded(1.0);

  // Getters for streams
  Stream<Station?> get currentStationStream => _currentStationController.stream;
  Stream<NowPlayingInfo> get nowPlayingStream => _nowPlayingController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<double> get volumeStream => _volumeController.stream;

  // Current values
  Station? get currentStation => _currentStationController.value;
  NowPlayingInfo get nowPlayingInfo => _nowPlayingController.value;
  bool get isPlaying => _isPlayingController.value;
  Duration get position => _positionController.value;
  Duration? get duration => _durationController.value;
  double get volume => _volumeController.value;

  AudioPlayerService() {
    _init();
  }

  /// Initialize the audio player
  Future<void> _init() async {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlayingController.add(playerState.playing);
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      _durationController.add(duration);
    });

    // Listen to metadata changes (ICY metadata from stream)
    _audioPlayer.icyMetadataStream.listen((icyMetadata) {
      if (icyMetadata != null) {
        final info = NowPlayingInfo.fromIcyMetadata(icyMetadata.info?.title ?? '');
        _nowPlayingController.add(info);
      }
    });

    // Set initial volume
    _volumeController.add(_audioPlayer.volume);
  }

  /// Play a radio station with enhanced error handling and retry logic
  Future<void> playStation(Station station, {int retryCount = 0}) async {
    try {
      // Validate URL before attempting playback
      final validationResult = await _validateStreamUrl(station.streamUrl);
      if (!validationResult.isValid) {
        throw AudioPlayerException(
          'Invalid stream URL: ${validationResult.errorMessage}',
          station: station,
          originalError: validationResult.errorMessage,
        );
      }

      // Update current station
      _currentStationController.add(station);

      // Log attempt
      _log('Attempting to play station: ${station.name}');
      _log('Stream URL: ${station.streamUrl}');

      // Create audio source with metadata for background playback
      // Add headers for streams that require User-Agent
      final audioSource = AudioSource.uri(
        Uri.parse(station.streamUrl),
        tag: MediaItem(
          id: station.id,
          album: station.category ?? 'Online Radio',
          title: station.name,
          artist: station.description ?? 'Internet Radio',
          artUri: station.logoUrl != null ? Uri.parse(station.logoUrl!) : null,
        ),
        headers: {
          'User-Agent': 'OnlineRadioApp/1.0 (Flutter; Android)',
          'Icy-Metadata': '1',
        },
      );

      // Set the audio source with timeout
      await _audioPlayer.setAudioSource(audioSource).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw AudioPlayerException(
            'Connection timeout - stream took too long to respond',
            station: station,
          );
        },
      );

      // Attempt to play
      await _audioPlayer.play();

      // Update last played time on success
      final updatedStation = station.copyWith(lastPlayed: DateTime.now());
      _currentStationController.add(updatedStation);
      
      _log('Successfully started playback: ${station.name}');

    } on AudioPlayerException {
      rethrow;
    } catch (e, stackTrace) {
      _log('Error playing station ${station.name}: $e');
      _log('Stack trace: $stackTrace');
      
      // Provide more specific error messages based on error type
      String errorMessage = _getDetailedErrorMessage(e, station);
      
      // Retry logic for transient errors (max 2 retries)
      if (retryCount < 2 && _isRetryableError(e)) {
        _log('Retrying playback (attempt ${retryCount + 1}/2)...');
        await Future.delayed(Duration(seconds: retryCount + 1));
        return playStation(station, retryCount: retryCount + 1);
      }
      
      throw AudioPlayerException(
        errorMessage,
        station: station,
        originalError: e.toString(),
      );
    }
  }

  /// Validate stream URL before attempting playback
  Future<UrlValidationResult> _validateStreamUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Check if URL is valid
      if (!uri.isAbsolute) {
        return UrlValidationResult.invalid('URL is not absolute: $url');
      }
      
      // Check scheme (prefer HTTPS)
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return UrlValidationResult.invalid('Invalid URL scheme: ${uri.scheme}');
      }
      
      // For HTTP URLs, warn but allow (Android cleartext is enabled)
      if (uri.scheme == 'http') {
        _log('Warning: HTTP URL detected (not HTTPS): $url');
      }
      
      // Basic DNS lookup check - just verify the host is resolvable
      try {
        final host = uri.host;
        if (host.isEmpty) {
          return UrlValidationResult.invalid('URL has no host: $url');
        }
        
        // Try to resolve the host
        final addresses = await InternetAddress.lookup(host).timeout(
          const Duration(seconds: 5),
        );
        
        if (addresses.isEmpty) {
          return UrlValidationResult.invalid(
            'Cannot resolve host: $host',
          );
        }
        
        _log('Host $host resolved to ${addresses.first.address}');
      } on SocketException catch (e) {
        return UrlValidationResult.invalid(
          'Cannot resolve server address: ${e.message}',
        );
      } on TimeoutException {
        return UrlValidationResult.invalid(
          'DNS lookup timeout - check your internet connection',
        );
      } catch (e) {
        _log('DNS lookup warning: $e');
        // Continue anyway - DNS might work on the device
      }
      
      // Skip HEAD request check - many radio servers don't support it
      // The actual audio player will handle connection errors
      
      return UrlValidationResult.valid();
    } on FormatException catch (e) {
      return UrlValidationResult.invalid('Malformed URL: $e');
    } catch (e) {
      return UrlValidationResult.invalid('URL validation error: $e');
    }
  }


  /// Get detailed error message based on error type
  String _getDetailedErrorMessage(dynamic error, Station station) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socket') || errorString.contains('connection')) {
      return 'Network connection failed. Please check your internet connection and try again.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Connection timed out. The station may be temporarily unavailable.';
    }
    
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Station stream not found (404). The URL may be outdated.';
    }
    
    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Access denied (403). This station may require authentication or be geo-blocked.';
    }
    
    if (errorString.contains('500') || errorString.contains('502') || errorString.contains('503')) {
      return 'Server error. The station server is experiencing issues.';
    }
    
    if (errorString.contains('source') || errorString.contains('load')) {
      return 'Failed to load audio stream. The station may be offline or the URL has changed.';
    }
    
    if (errorString.contains('ssl') || errorString.contains('certificate') || errorString.contains('handshake')) {
      return 'SSL/TLS error. There may be a security issue with the station server.';
    }
    
    if (errorString.contains('http') && errorString.contains('cleartext')) {
      return 'HTTP connection blocked. This station uses an insecure connection that Android has blocked.';
    }
    
    return 'Failed to play station: ${station.name}. Please try another station.';
  }

  /// Check if error is retryable
  bool _isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
           errorString.contains('socket') ||
           errorString.contains('connection') ||
           errorString.contains('temporarily');
  }

  /// Log messages for debugging
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] AudioPlayerService: $message');
  }


  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resume playback
  Future<void> play() async {
    await _audioPlayer.play();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentStationController.add(null);
    _nowPlayingController.add(NowPlayingInfo.empty());
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(clampedVolume);
    _volumeController.add(clampedVolume);
  }

  /// Seek to position (for recorded content)
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _currentStationController.close();
    await _nowPlayingController.close();
    await _isPlayingController.close();
    await _positionController.close();
    await _durationController.close();
    await _volumeController.close();
  }
}

/// Custom exception for audio player errors with station context
class AudioPlayerException implements Exception {
  final String message;
  final Station? station;
  final String? originalError;

  AudioPlayerException(
    this.message, {
    this.station,
    this.originalError,
  });

  @override
  String toString() {
    if (station != null) {
      return 'AudioPlayerException: $message (Station: ${station!.name})';
    }
    return 'AudioPlayerException: $message';
  }
}

/// Result of URL validation
class UrlValidationResult {
  final bool isValid;
  final String? errorMessage;

  UrlValidationResult._(this.isValid, this.errorMessage);

  factory UrlValidationResult.valid() => UrlValidationResult._(true, null);

  factory UrlValidationResult.invalid(String message) => 
      UrlValidationResult._(false, message);
}
