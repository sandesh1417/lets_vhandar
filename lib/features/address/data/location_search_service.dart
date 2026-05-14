import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSuggestion {
  final String displayName;
  final LatLng latLng;

  LocationSuggestion({required this.displayName, required this.latLng});

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'],
      latLng: LatLng(
        double.parse(json['lat']),
        double.parse(json['lon']),
      ),
    );
  }
}

class LocationSearchService {
  final Dio _dio = Dio();

  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'LetsVhandarApp/1.0', // Important for OSM policy
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => LocationSuggestion.fromJson(item)).toList();
      }
    } catch (e) {
      print('OSM Search error: $e');
    }
    return [];
  }
}
