import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/station.dart';
import '../services/recommendation_service.dart';

// Events
abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecommendationsEvent extends RecommendationEvent {}

class LoadPersonalizedRecommendationsEvent extends RecommendationEvent {
  final int limit;

  const LoadPersonalizedRecommendationsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class LoadMoodRecommendationsEvent extends RecommendationEvent {
  final String mood;

  const LoadMoodRecommendationsEvent(this.mood);

  @override
  List<Object?> get props => [mood];
}

class LoadDiscoveryRecommendationsEvent extends RecommendationEvent {}

class RecordListeningEvent extends RecommendationEvent {
  final String stationId;
  final String category;
  final List<String> tags;
  final int duration;
  final bool wasSkipped;

  const RecordListeningEvent({
    required this.stationId,
    required this.category,
    required this.tags,
    required this.duration,
    this.wasSkipped = false,
  });

  @override
  List<Object?> get props => [stationId, category, tags, duration, wasSkipped];
}

class GetListeningStatsEvent extends RecommendationEvent {}

// States
abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitialState extends RecommendationState {}

class RecommendationLoadingState extends RecommendationState {}

class PersonalizedRecommendationsLoadedState extends RecommendationState {
  final List<Station> recommendations;
  final bool isFromCache;

  const PersonalizedRecommendationsLoadedState({
    required this.recommendations,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [recommendations, isFromCache];
}

class MoodRecommendationsLoadedState extends RecommendationState {
  final List<Station> recommendations;
  final String mood;

  const MoodRecommendationsLoadedState({
    required this.recommendations,
    required this.mood,
  });

  @override
  List<Object?> get props => [recommendations, mood];
}

class DiscoveryRecommendationsLoadedState extends RecommendationState {
  final List<Station> recommendations;

  const DiscoveryRecommendationsLoadedState(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

class ListeningStatsLoadedState extends RecommendationState {
  final Map<String, dynamic> stats;

  const ListeningStatsLoadedState(this.stats);

  @override
  List<Object?> get props => [stats];
}

class RecommendationErrorState extends RecommendationState {
  final String message;

  const RecommendationErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  final RecommendationService _recommendationService;

  RecommendationBloc({
    required RecommendationService recommendationService,
  })  : _recommendationService = recommendationService,
        super(RecommendationInitialState()) {
    on<LoadRecommendationsEvent>(_onLoadRecommendations);
    on<LoadPersonalizedRecommendationsEvent>(_onLoadPersonalizedRecommendations);
    on<LoadMoodRecommendationsEvent>(_onLoadMoodRecommendations);
    on<LoadDiscoveryRecommendationsEvent>(_onLoadDiscoveryRecommendations);
    on<RecordListeningEvent>(_onRecordListening);
    on<GetListeningStatsEvent>(_onGetListeningStats);
  }

  Future<void> _onLoadRecommendations(
    LoadRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoadingState());
    
    try {
      // Load all types of recommendations
      final personalized = await _recommendationService.getPersonalizedRecommendations(
        limit: 10,
      );
      
      emit(PersonalizedRecommendationsLoadedState(
        recommendations: personalized,
      ));
    } catch (e) {
      emit(RecommendationErrorState('Failed to load recommendations: $e'));
    }
  }

  Future<void> _onLoadPersonalizedRecommendations(
    LoadPersonalizedRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoadingState());
    
    try {
      final recommendations = await _recommendationService.getPersonalizedRecommendations(
        limit: event.limit,
      );
      
      emit(PersonalizedRecommendationsLoadedState(
        recommendations: recommendations,
      ));
    } catch (e) {
      emit(RecommendationErrorState('Failed to load personalized recommendations: $e'));
    }
  }

  Future<void> _onLoadMoodRecommendations(
    LoadMoodRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoadingState());
    
    try {
      final recommendations = await _recommendationService.getMoodBasedRecommendations(
        event.mood,
      );
      
      emit(MoodRecommendationsLoadedState(
        recommendations: recommendations,
        mood: event.mood,
      ));
    } catch (e) {
      emit(RecommendationErrorState('Failed to load mood recommendations: $e'));
    }
  }

  Future<void> _onLoadDiscoveryRecommendations(
    LoadDiscoveryRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoadingState());
    
    try {
      final recommendations = await _recommendationService.getDiscoveryRecommendations(
        limit: 5,
      );
      
      emit(DiscoveryRecommendationsLoadedState(recommendations));
    } catch (e) {
      emit(RecommendationErrorState('Failed to load discovery recommendations: $e'));
    }
  }

  Future<void> _onRecordListening(
    RecordListeningEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    // Don't emit loading state for this - it should be background operation
    _recommendationService.recordListening(
      stationId: event.stationId,
      category: event.category,
      tags: event.tags,
      duration: event.duration,
      wasSkipped: event.wasSkipped,
    );
  }

  Future<void> _onGetListeningStats(
    GetListeningStatsEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    try {
      final stats = _recommendationService.getListeningStatistics();
      emit(ListeningStatsLoadedState(stats));
    } catch (e) {
      emit(RecommendationErrorState('Failed to get listening stats: $e'));
    }
  }
}
