import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSuggestion {
  final String displayName;

  /// Google Places `place_id`. Coordinates are resolved lazily via
  /// [LocationSearchService.getPlaceLatLng] when the suggestion is tapped.
  final String? placeId;

  /// May be null for Google Places predictions until resolved.
  final LatLng? latLng;

  LocationSuggestion({
    required this.displayName,
    this.placeId,
    this.latLng,
  });
}

/// Address search backed by the Google Places API (same data source as the
/// website), restricted to Nepal. Autocomplete returns predictions with a
/// `place_id`; coordinates are fetched on demand via Place Details.
class LocationSearchService {
  final Dio _dio = Dio();

  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Billing-efficient session: one token spans the autocomplete keystrokes +
  // the final details call, then is reset.
  String? _sessionToken;

  String _newSessionToken() {
    final rnd = Random();
    return List.generate(16, (_) => rnd.nextInt(16).toRadixString(16)).join();
  }

  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final key = _apiKey;
    if (key.isEmpty) {
      debugPrint(
          'Places search: GOOGLE_MAPS_API_KEY is empty (.env not loaded?)');
      return [];
    }

    _sessionToken ??= _newSessionToken();

    try {
      final response = await _dio.get(
        _autocompleteUrl,
        queryParameters: {
          'input': q,
          'components': 'country:np',
          'language': 'en',
          'key': key,
          'sessiontoken': _sessionToken,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final status = data['status'] as String?;

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        debugPrint(
            'Places autocomplete error: $status — ${data['error_message']}');
        return [];
      }

      final predictions = data['predictions'] as List? ?? [];
      final results = <LocationSuggestion>[];
      for (final p in predictions) {
        final description = p['description'] as String? ?? '';
        final placeId = p['place_id'] as String?;
        if (description.isEmpty || placeId == null) continue;
        results.add(LocationSuggestion(
          displayName: description,
          placeId: placeId,
        ));
      }
      return results;
    } catch (e) {
      debugPrint('Places autocomplete exception: $e');
      return [];
    }
  }

  /// Resolves the coordinates for a tapped prediction. Ends the billing session.
  Future<LatLng?> getPlaceLatLng(String placeId) async {
    final key = _apiKey;
    if (key.isEmpty) return null;

    try {
      final response = await _dio.get(
        _detailsUrl,
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry/location',
          'language': 'en',
          'key': key,
          if (_sessionToken != null) 'sessiontoken': _sessionToken,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // Session consumed — reset so the next search starts a new one.
      _sessionToken = null;

      final data = response.data as Map<String, dynamic>? ?? {};
      if (data['status'] != 'OK') {
        debugPrint(
            'Place details error: ${data['status']} — ${data['error_message']}');
        return null;
      }

      final loc = data['result']?['geometry']?['location'];
      final lat = (loc?['lat'] as num?)?.toDouble();
      final lng = (loc?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (e) {
      debugPrint('Place details exception: $e');
      return null;
    }
  }
}
