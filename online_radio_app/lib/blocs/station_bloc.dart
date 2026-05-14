import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/station.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';

// Events
abstract class StationEvent extends Equatable {
  const StationEvent();

  @override
  List<Object?> get props => [];
}

class LoadStations extends StationEvent {}

class LoadStationsByCategory extends StationEvent {
  final String category;

  const LoadStationsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchStations extends StationEvent {
  final String query;

  const SearchStations(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleStationFavorite extends StationEvent {
  final Station station;

  const ToggleStationFavorite(this.station);

  @override
  List<Object?> get props => [station];
}

class LoadFavorites extends StationEvent {}

// States
abstract class StationState extends Equatable {
  const StationState();

  @override
  List<Object?> get props => [];
}

class StationInitial extends StationState {}

class StationLoading extends StationState {}

class StationsLoaded extends StationState {
  final List<Station> stations;
  final String? category;

  const StationsLoaded(this.stations, {this.category});

  @override
  List<Object?> get props => [stations, category];
}

class FavoritesLoaded extends StationState {
  final List<Station> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

class StationError extends StationState {
  final String message;

  const StationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class StationBloc extends Bloc<StationEvent, StationState> {
  final ApiService _apiService;
  final OfflineService _offlineService;

  StationBloc({
    required ApiService apiService,
    required OfflineService offlineService,
  })  : _apiService = apiService,
        _offlineService = offlineService,
        super(StationInitial()) {
    on<LoadStations>(_onLoadStations);
    on<LoadStationsByCategory>(_onLoadStationsByCategory);
    on<SearchStations>(_onSearchStations);
    on<ToggleStationFavorite>(_onToggleStationFavorite);
    on<LoadFavorites>(_onLoadFavorites);
  }

  Future<void> _onLoadStations(LoadStations event, Emitter<StationState> emit) async {
    emit(StationLoading());
    try {
      final stations = await _apiService.getStations();
      emit(StationsLoaded(stations));
    } catch (e) {
      // Try to load from cache if offline
      final cachedStations = _offlineService.getCachedStations();
      if (cachedStations.isNotEmpty) {
        emit(StationsLoaded(cachedStations));
      } else {
        emit(StationError('Failed to load stations: $e'));
      }
    }
  }

  Future<void> _onLoadStationsByCategory(
    LoadStationsByCategory event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoading());
    try {
      final stations = await _apiService.getStationsByCategory(event.category);
      emit(StationsLoaded(stations, category: event.category));
    } catch (e) {
      emit(StationError('Failed to load stations: $e'));
    }
  }

  Future<void> _onSearchStations(SearchStations event, Emitter<StationState> emit) async {
    emit(StationLoading());
    try {
      final stations = await _apiService.searchStations(event.query);
      emit(StationsLoaded(stations));
    } catch (e) {
      emit(StationError('Failed to search stations: $e'));
    }
  }

  Future<void> _onToggleStationFavorite(
    ToggleStationFavorite event,
    Emitter<StationState> emit,
  ) async {
    try {
      // Update local cache
      if (_offlineService.isInFavoritesCache(event.station.id)) {
        await _offlineService.removeFromFavoritesCache(event.station.id);
      } else {
        await _offlineService.addToFavoritesCache(event.station);
      }

      // Reload favorites if currently showing favorites
      if (state is FavoritesLoaded) {
        add(LoadFavorites());
      }

      // Reload current stations to reflect favorite status change
      if (state is StationsLoaded) {
        final currentState = state as StationsLoaded;
        final updatedStations = currentState.stations.map((station) {
          if (station.id == event.station.id) {
            return station.copyWith(isFavorite: !station.isFavorite);
          }
          return station;
        }).toList();
        emit(StationsLoaded(updatedStations, category: currentState.category));
      }
    } catch (e) {
      emit(StationError('Failed to toggle favorite: $e'));
    }
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<StationState> emit) async {
    emit(StationLoading());
    try {
      final favorites = _offlineService.getCachedFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(StationError('Failed to load favorites: $e'));
    }
  }
}
