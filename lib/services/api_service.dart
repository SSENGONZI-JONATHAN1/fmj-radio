import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/station.dart';

export '../models/station.dart' show Category;


class ApiService {
  late Dio _dio;
  final String baseUrl;
  
  // Cache for offline support
  final Map<String, dynamic> _cache = {};

  ApiService({this.baseUrl = 'https://api.onlineradio.com/v1'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // Helper method to safely extract list from response
  List<dynamic> _extractListFromResponse(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    } else if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        // Handle nested data structure
        final nestedData = data['data'];
        if (nestedData is List) {
          return nestedData;
        }
      }
    }
    return [];
  }

  // Check internet connectivity
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get all radio stations
  Future<List<Station>> getStations({
    String? category,
    String? country,
    String? language,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        if (category != null) 'category': category,
        if (country != null) 'country': country,
        if (language != null) 'language': language,
        if (searchQuery != null) 'search': searchQuery,
        'page': page,
        'limit': limit,
      };

      final response = await _dio.get('/stations', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractListFromResponse(response.data);
        final stations = data.map((json) => Station.fromJson(json)).toList();
        
        // Cache the results
        _cache['stations_${category}_${country}_${page}'] = stations;
        
        return stations;
      } else {
        throw Exception('Failed to load stations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Return cached data if available
      final cacheKey = 'stations_${category}_${country}_${page}';
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<Station>;
      }
      
      throw Exception('Network error: ${e.message}');
    }
  }

  // Get station categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractListFromResponse(response.data);
        final categories = data.map((json) => Category.fromJson(json)).toList();
        
        // Cache the results
        _cache['categories'] = categories;
        
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } on DioException catch (e) {
      // Return cached categories if available
      if (_cache.containsKey('categories')) {
        return _cache['categories'] as List<Category>;
      }
      
      // Return default categories
      return _getDefaultCategories();
    }
  }

  // Get stations by category
  Future<List<Station>> getStationsByCategory(String category) async {
    try {
      final response = await _dio.get('/stations', queryParameters: {
        'category': category,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractListFromResponse(response.data);
        return data.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stations by category');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Get featured/popular stations
  Future<List<Station>> getFeaturedStations() async {
    try {
      final response = await _dio.get('/stations/featured');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractListFromResponse(response.data);
        return data.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load featured stations');
      }
    } on DioException catch (e) {
      if (_cache.containsKey('featured_stations')) {
        return _cache['featured_stations'] as List<Station>;
      }
      return [];
    }
  }

  // Get trending stations
  Future<List<Station>> getTrendingStations() async {
    try {
      final response = await _dio.get('/stations/trending');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractListFromResponse(response.data);
        return data.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending stations');
      }
    } on DioException catch (e) {
      if (_cache.containsKey('trending_stations')) {
        return _cache['trending_stations'] as List<Station>;
      }
      return [];
    }
  }

  // Get station details
  Future<Station> getStationDetails(String stationId) async {
    try {
      final response = await _dio.get('/stations/$stationId');
      
      if (response.statusCode == 200) {
        final dynamic data = response.data is Map<String, dynamic> 
            ? response.data['data'] ?? response.data 
            : response.data;
        return Station.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load station details');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Report listening analytics
  Future<void> reportListening({
    required String stationId,
    required int duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dio.post('/analytics/listening', data: {
        'stationId': stationId,
        'duration': duration,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata,
      });
    } catch (e) {
      // Silently fail for analytics - don't interrupt user experience
      print('Failed to report analytics: $e');
    }
  }

  // Get lyrics for current song
  Future<Map<String, dynamic>?> getLyrics({
    required String title,
    required String artist,
  }) async {
    try {
      final response = await _dio.get('/lyrics', queryParameters: {
        'title': title,
        'artist': artist,
      });
      
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Failed to fetch lyrics: $e');
      return null;
    }
  }

  // Get similar stations based on current listening
  Future<List<Station>> getSimilarStations(String stationId) async {
    try {
      final response = await _dio.get('/stations/$stationId/similar');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractListFromResponse(response.data);
        return data.map((json) => Station.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to get similar stations: $e');
      return [];
    }
  }

  // Search stations
  Future<List<Station>> searchStations(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _dio.get('/search', queryParameters: {
        'q': query,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractListFromResponse(response.data);
        return data.map((json) => Station.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Search failed: $e');
      return [];
    }
  }

  // Get countries list
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await _dio.get('/countries');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get languages list
  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await _dio.get('/languages');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Clear cache
  void clearCache() {
    _cache.clear();
  }

  // Default categories for offline mode
  List<Category> _getDefaultCategories() {
    return [
      const Category(id: 'pop', name: 'Pop', stationCount: 150),
      const Category(id: 'rock', name: 'Rock', stationCount: 120),
      const Category(id: 'jazz', name: 'Jazz', stationCount: 80),
      const Category(id: 'classical', name: 'Classical', stationCount: 60),
      const Category(id: 'news', name: 'News & Talk', stationCount: 90),
      const Category(id: 'sports', name: 'Sports', stationCount: 70),
      const Category(id: 'electronic', name: 'Electronic', stationCount: 100),
      const Category(id: 'hiphop', name: 'Hip Hop', stationCount: 110),
      const Category(id: 'country', name: 'Country', stationCount: 85),
      const Category(id: 'world', name: 'World Music', stationCount: 95),
    ];
  }
}
