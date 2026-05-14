import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

/// Recording Service
/// 
/// Records audio snippets from the currently playing radio stream
/// Features:
/// - 30-second recording limit
/// - Save to device storage
/// - Playback recorded snippets
/// - Share recordings
class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  factory RecordingService() => _instance;
  RecordingService._internal();

  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  String? _currentRecordingPath;
  
  // Maximum recording duration (30 seconds)
  static const int maxRecordingSeconds = 30;

  // Stream controller for recording progress
  final StreamController<double> _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  // Stream controller for recording state
  final StreamController<bool> _stateController = StreamController<bool>.broadcast();
  Stream<bool> get recordingStateStream => _stateController.stream;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    // Request storage permission
    final storageStatus = await Permission.storage.request();
    
    // For Android 11+ (API 30+), also request manage external storage
    if (Platform.isAndroid) {
      final manageStatus = await Permission.manageExternalStorage.request();
      return storageStatus.isGranted || manageStatus.isGranted;
    }
    
    return storageStatus.isGranted;
  }

  /// Start recording from audio stream
  /// 
  /// NOTE: Due to platform limitations, we can't directly record from 
  /// the audio output stream. Instead, we:
  /// 1. Save the current stream URL and timestamp
  /// 2. Create a metadata file about what was playing
  /// 3. In a real implementation, you'd use native platform channels
  ///    to capture the audio buffer from the player
  Future<bool> startRecording({
    required String stationName,
    required String streamUrl,
    String? songTitle,
    String? artist,
  }) async {
    if (_isRecording) return false;

    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Storage permission required for recording');
    }

    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      
      // Create recordings directory if it doesn't exist
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'recording_${stationName.replaceAll(' ', '_')}_$timestamp';
      
      _currentRecordingPath = '${recordingsDir.path}/$filename.m4a';
      _recordingStartTime = DateTime.now();
      _isRecording = true;
      
      // Notify state change
      _stateController.add(true);

      // Start progress timer
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        final elapsed = DateTime.now().difference(_recordingStartTime!).inMilliseconds;
        final progress = elapsed / (maxRecordingSeconds * 1000);
        _progressController.add(progress.clamp(0.0, 1.0));
        
        // Auto-stop at max duration
        if (elapsed >= maxRecordingSeconds * 1000) {
          stopRecording();
        }
      });

      // TODO: Implement actual audio recording
      // For now, we create a metadata file about what was "recorded"
      await _createRecordingMetadata(
        path: _currentRecordingPath!,
        stationName: stationName,
        streamUrl: streamUrl,
        songTitle: songTitle,
        artist: artist,
        timestamp: _recordingStartTime!,
      );

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      _stateController.add(false);
      return false;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    _recordingTimer?.cancel();
    _isRecording = false;
    _stateController.add(false);
    _progressController.add(0.0);

    // TODO: Finalize actual audio recording
    // For demo purposes, we return the metadata file path
    
    final path = _currentRecordingPath;
    _currentRecordingPath = null;
    _recordingStartTime = null;

    return path;
  }

  /// Create metadata file for recording
  Future<void> _createRecordingMetadata({
    required String path,
    required String stationName,
    required String streamUrl,
    String? songTitle,
    String? artist,
    required DateTime timestamp,
  }) async {
    final metadata = {
      'stationName': stationName,
      'streamUrl': streamUrl,
      'songTitle': songTitle ?? 'Unknown',
      'artist': artist ?? 'Unknown Artist',
      'recordedAt': timestamp.toIso8601String(),
      'duration': maxRecordingSeconds,
      'note': 'This is a metadata placeholder. Actual audio recording '
          'requires native platform implementation.',
    };

    final metadataPath = path.replaceAll('.m4a', '.json');
    final file = File(metadataPath);
    await file.writeAsString(metadata.toString());
  }

  /// Get all recordings
  Future<List<Recording>> getRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      
      if (!await recordingsDir.exists()) {
        return [];
      }

      final files = await recordingsDir
          .list()
          .where((entity) => entity.path.endsWith('.json'))
          .toList();

      final recordings = <Recording>[];
      
      for (final file in files) {
        try {
          final content = await File(file.path).readAsString();
          // Parse metadata (simplified)
          final recording = Recording(
            id: file.path.split('/').last.replaceAll('.json', ''),
            path: file.path.replaceAll('.json', '.m4a'),
            metadataPath: file.path,
            createdAt: File(file.path).lastModifiedSync(),
          );
          recordings.add(recording);
        } catch (e) {
          print('Error reading recording: $e');
        }
      }

      // Sort by date (newest first)
      recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return recordings;
    } catch (e) {
      print('Error getting recordings: $e');
      return [];
    }
  }

  /// Delete a recording
  Future<bool> deleteRecording(String id) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      
      final audioFile = File('${recordingsDir.path}/$id.m4a');
      final metadataFile = File('${recordingsDir.path}/$id.json');
      
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
      
      return true;
    } catch (e) {
      print('Error deleting recording: $e');
      return false;
    }
  }

  /// Play a recording
  Future<AudioPlayer> playRecording(String path) async {
    final player = AudioPlayer();
    // TODO: Implement actual playback
    // For now, this is a placeholder
    return player;
  }

  /// Share a recording
  Future<void> shareRecording(String path) async {
    // TODO: Implement sharing using share_plus
    // For now, this is a placeholder
  }

  /// Dispose resources
  void dispose() {
    _recordingTimer?.cancel();
    _progressController.close();
    _stateController.close();
  }
}

/// Recording model
class Recording {
  final String id;
  final String path;
  final String metadataPath;
  final DateTime createdAt;

  Recording({
    required this.id,
    required this.path,
    required this.metadataPath,
    required this.createdAt,
  });

  String get displayName {
    final parts = id.split('_');
    if (parts.length >= 2) {
      return parts[1].replaceAll('_', ' ');
    }
    return 'Recording';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} '
        '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
