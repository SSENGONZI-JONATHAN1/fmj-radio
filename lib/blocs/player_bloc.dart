import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/station.dart';
import '../services/audio_player_service.dart';


// Events
abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayStation extends PlayerEvent {
  final Station station;

  const PlayStation(this.station);

  @override
  List<Object?> get props => [station];
}

class PausePlayback extends PlayerEvent {}

class ResumePlayback extends PlayerEvent {}

class StopPlayback extends PlayerEvent {}

class TogglePlayPause extends PlayerEvent {}

class UpdateVolume extends PlayerEvent {
  final double volume;

  const UpdateVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class UpdateNowPlaying extends PlayerEvent {
  final NowPlayingInfo info;

  const UpdateNowPlaying(this.info);

  @override
  List<Object?> get props => [info];
}

class TogglePlayerFavorite extends PlayerEvent {
  final Station? station;

  const TogglePlayerFavorite([this.station]);

  @override
  List<Object?> get props => [station];
}

class SetSleepTimer extends PlayerEvent {
  final Duration duration;

  const SetSleepTimer(this.duration);

  @override
  List<Object?> get props => [duration];
}

class CancelSleepTimer extends PlayerEvent {}

// States

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerPlaying extends PlayerState {
  final Station station;
  final NowPlayingInfo nowPlaying;
  final double volume;
  final bool isFavorite;

  const PlayerPlaying({
    required this.station,
    required this.nowPlaying,
    this.volume = 1.0,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [station, nowPlaying, volume, isFavorite];

  PlayerPlaying copyWith({
    Station? station,
    NowPlayingInfo? nowPlaying,
    double? volume,
    bool? isFavorite,
  }) {
    return PlayerPlaying(
      station: station ?? this.station,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      volume: volume ?? this.volume,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class PlayerPaused extends PlayerState {
  final Station station;
  final NowPlayingInfo nowPlaying;
  final double volume;
  final bool isFavorite;

  const PlayerPaused({
    required this.station,
    required this.nowPlaying,
    this.volume = 1.0,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [station, nowPlaying, volume, isFavorite];
}

class PlayerError extends PlayerState {
  final String message;

  const PlayerError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerService _audioPlayerService;
  StreamSubscription? _nowPlayingSubscription;
  StreamSubscription? _isPlayingSubscription;
  Timer? _sleepTimer;

  PlayerBloc({required AudioPlayerService audioPlayerService})
      : _audioPlayerService = audioPlayerService,
        super(PlayerInitial()) {

    on<PlayStation>(_onPlayStation);
    on<PausePlayback>(_onPausePlayback);
    on<ResumePlayback>(_onResumePlayback);
    on<StopPlayback>(_onStopPlayback);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<UpdateVolume>(_onUpdateVolume);
    on<UpdateNowPlaying>(_onUpdateNowPlaying);
    on<TogglePlayerFavorite>(_onTogglePlayerFavorite);
    on<SetSleepTimer>(_onSetSleepTimer);
    on<CancelSleepTimer>(_onCancelSleepTimer);

    // Listen to now playing updates

    _nowPlayingSubscription = _audioPlayerService.nowPlayingStream.listen((info) {
      add(UpdateNowPlaying(info));
    });

    // Listen to playing state
    _isPlayingSubscription = _audioPlayerService.isPlayingStream.listen((isPlaying) {
      if (state is PlayerPlaying && !isPlaying) {
        final currentState = state as PlayerPlaying;
        emit(PlayerPaused(
          station: currentState.station,
          nowPlaying: currentState.nowPlaying,
          volume: currentState.volume,
          isFavorite: currentState.isFavorite,
        ));
      } else if (state is PlayerPaused && isPlaying) {
        final currentState = state as PlayerPaused;
        emit(PlayerPlaying(
          station: currentState.station,
          nowPlaying: currentState.nowPlaying,
          volume: currentState.volume,
          isFavorite: currentState.isFavorite,
        ));
      }
    });
  }

  Future<void> _onPlayStation(PlayStation event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());
    try {
      await _audioPlayerService.playStation(event.station);
      emit(PlayerPlaying(
        station: event.station,
        nowPlaying: _audioPlayerService.nowPlayingInfo,
        volume: _audioPlayerService.volume,
      ));
    } on AudioPlayerException catch (e) {
      // Handle custom audio player exceptions with detailed messages
      emit(PlayerError(e.message));
    } catch (e) {
      // Handle generic errors
      final errorMessage = _getUserFriendlyErrorMessage(e);
      emit(PlayerError(errorMessage));
    }
  }

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Check for common error patterns
    if (errorString.contains('source error') || errorString.contains('(0)')) {
      return 'Unable to connect to this radio station. The stream may be offline or the URL has changed. Please try another station.';
    }
    
    if (errorString.contains('network') || errorString.contains('socket') || errorString.contains('connection')) {
      return 'Network connection issue. Please check your internet connection and try again.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Connection timed out. The station may be temporarily unavailable.';
    }
    
    if (errorString.contains('http') || errorString.contains('ssl') || errorString.contains('certificate')) {
      return 'Security connection issue. The station may have an invalid security certificate.';
    }
    
    // Default message
    return 'Failed to play station. Please try again or select a different station.';
  }


  Future<void> _onPausePlayback(PausePlayback event, Emitter<PlayerState> emit) async {
    if (state is PlayerPlaying) {
      await _audioPlayerService.pause();
      final currentState = state as PlayerPlaying;
      emit(PlayerPaused(
        station: currentState.station,
        nowPlaying: currentState.nowPlaying,
        volume: currentState.volume,
        isFavorite: currentState.isFavorite,
      ));
    }
  }

  Future<void> _onResumePlayback(ResumePlayback event, Emitter<PlayerState> emit) async {
    if (state is PlayerPaused) {
      await _audioPlayerService.play();
      final currentState = state as PlayerPaused;
      emit(PlayerPlaying(
        station: currentState.station,
        nowPlaying: currentState.nowPlaying,
        volume: currentState.volume,
        isFavorite: currentState.isFavorite,
      ));
    }
  }

  Future<void> _onStopPlayback(StopPlayback event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.stop();
    emit(PlayerInitial());
  }

  Future<void> _onTogglePlayPause(TogglePlayPause event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.togglePlayPause();
  }

  Future<void> _onUpdateVolume(UpdateVolume event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.setVolume(event.volume);
    if (state is PlayerPlaying) {
      final currentState = state as PlayerPlaying;
      emit(currentState.copyWith(volume: event.volume));
    } else if (state is PlayerPaused) {
      final currentState = state as PlayerPaused;
      emit(PlayerPaused(
        station: currentState.station,
        nowPlaying: currentState.nowPlaying,
        volume: event.volume,
        isFavorite: currentState.isFavorite,
      ));
    }
  }

  Future<void> _onUpdateNowPlaying(UpdateNowPlaying event, Emitter<PlayerState> emit) async {
    if (state is PlayerPlaying) {
      final currentState = state as PlayerPlaying;
      emit(currentState.copyWith(nowPlaying: event.info));
    } else if (state is PlayerPaused) {
      final currentState = state as PlayerPaused;
      emit(PlayerPaused(
        station: currentState.station,
        nowPlaying: event.info,
        volume: currentState.volume,
        isFavorite: currentState.isFavorite,
      ));
    }
  }

  Future<void> _onTogglePlayerFavorite(TogglePlayerFavorite event, Emitter<PlayerState> emit) async {
    // Handle favorite toggle in player
    if (state is PlayerPlaying) {
      final currentState = state as PlayerPlaying;
      emit(currentState.copyWith(isFavorite: !currentState.isFavorite));
    } else if (state is PlayerPaused) {
      final currentState = state as PlayerPaused;
      emit(PlayerPaused(
        station: currentState.station,
        nowPlaying: currentState.nowPlaying,
        volume: currentState.volume,
        isFavorite: !currentState.isFavorite,
      ));
    }
  }

  Future<void> _onSetSleepTimer(SetSleepTimer event, Emitter<PlayerState> emit) async {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(event.duration, () async {
      await _audioPlayerService.stop();
      emit(PlayerInitial());
    });
  }

  Future<void> _onCancelSleepTimer(CancelSleepTimer event, Emitter<PlayerState> emit) async {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  @override
  Future<void> close() {
    _nowPlayingSubscription?.cancel();
    _isPlayingSubscription?.cancel();
    _sleepTimer?.cancel();
    return super.close();
  }
}
