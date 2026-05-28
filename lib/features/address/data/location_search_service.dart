import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSuggestion {
  final String displayName;
  final LatLng latLng;

  LocationSuggestion({required this.displayName, required this.latLng});
}

class LocationSearchService {
  final Dio _dio = Dio();

  // Nepal bounding box: lon_west,lat_south,lon_east,lat_north
  static const _nepalBbox = '80.058,26.347,88.201,30.447';

  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final response = await _dio.get(
        'https://photon.komoot.io/api',
        queryParameters: {
          'q': query.trim(),
          'limit': 8,
          'lang': 'en',
          'bbox': _nepalBbox,
        },
        options: Options(
          headers: {'User-Agent': 'LetsVhandarApp/1.0'},
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200) {
        final features = response.data['features'] as List? ?? [];
        final seen = <String>{};
        final results = <LocationSuggestion>[];

        for (final f in features) {
          final props = f['properties'] as Map<String, dynamic>? ?? {};
          final coords = (f['geometry']['coordinates'] as List);
          final lat = (coords[1] as num).toDouble();
          final lon = (coords[0] as num).toDouble();

          final label = _buildLabel(props);
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
      debugPrint('Photon search error: $e');
    }
    return [];
  }

  static String _buildLabel(Map<String, dynamic> props) {
    final parts = <String>[];
    for (final key in ['name', 'street', 'district', 'city', 'state', 'country']) {
      final v = props[key] as String?;
      if (v != null && v.isNotEmpty && !parts.contains(v)) parts.add(v);
      if (parts.length >= 4) break;
    }
    return parts.join(', ');
  }
}
