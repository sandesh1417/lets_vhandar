import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSuggestion {
  final String displayName;
  final LatLng latLng;

  LocationSuggestion({required this.displayName, required this.latLng});
}

/// Searches for locations within Nepal using Nominatim (OpenStreetMap).
/// `countrycodes=np` strictly limits results to Nepal.
class LocationSearchService {
  final Dio _dio = Dio();

  // Nepal viewbox for Nominatim: left,top,right,bottom
  static const _nepalViewbox = '80.058,30.447,88.201,26.347';

  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query.trim(),
          'countrycodes': 'np',
          'viewbox': _nepalViewbox,
          'bounded': 0,           // soft bound — still shows Nepal results outside viewbox
          'format': 'json',
          'limit': 8,
          'addressdetails': 1,
          'accept-language': 'en',
        },
        options: Options(
          headers: {
            'User-Agent': 'LetsVhandarApp/1.0 (letsvhandar@gmail.com)',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final items = response.data as List? ?? [];
        final seen = <String>{};
        final results = <LocationSuggestion>[];

        for (final item in items) {
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          if (lat == null || lon == null) continue;

          final label = _buildLabel(item);
          if (label.isNotEmpty && seen.add(label)) {
            results.add(LocationSuggestion(
              displayName: label,
              latLng: LatLng(lat, lon),
            ));
          }
        }
        return results;
      }
    } catch (e) {
      debugPrint('Nominatim search error: $e');
    }
    return [];
  }

  static String _buildLabel(Map<String, dynamic> item) {
    final addr = item['address'] as Map<String, dynamic>? ?? {};

    // Build a short, human-readable label:
    // neighbourhood/suburb/town + city/county + state — drop "Nepal" to save space
    final parts = <String>[];

    for (final key in [
      'shop', 'amenity', 'road', 'neighbourhood',
      'suburb', 'village', 'town', 'city_district',
      'city', 'county', 'state_district', 'state',
    ]) {
      final v = addr[key] as String?;
      if (v != null && v.isNotEmpty && !parts.contains(v)) {
        parts.add(v);
      }
      if (parts.length >= 4) break;
    }

    // Fallback to full display_name (trimmed)
    if (parts.isEmpty) {
      final full = item['display_name'] as String? ?? '';
      // Remove trailing ", Nepal" and keep first 3 comma-parts
      final segments = full
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.toLowerCase() != 'nepal')
          .take(3)
          .toList();
      return segments.join(', ');
    }

    return parts.join(', ');
  }
}
