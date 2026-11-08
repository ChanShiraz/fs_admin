import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_prediction.dart';

class PlacesService {
  final http.Client _client;

  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  static const String _nominatimUrl =
      'https://nominatim.openstreetmap.org/search';
  static const String _countryCode = 'sg';

  final Map<String, PlaceDetails> _detailsCache = {};

  Future<List<PlacePrediction>> searchPredictions(String input) async {
    final query = input.trim();
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_nominatimUrl?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&countrycodes=$_countryCode&limit=6',
      );

      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'AtmosphereAdmin/1.0'},
      );

      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List<dynamic>? ?? [];
        final predictions = <PlacePrediction>[];

        for (final item in list) {
          final map = item as Map<String, dynamic>;
          final placeId = (map['place_id'] ?? '').toString();
          final displayName = map['display_name'] as String? ?? '';
          final name = map['name'] as String? ?? '';
          final lat = double.tryParse(map['lat']?.toString() ?? '') ?? 1.2847;
          final lon = double.tryParse(map['lon']?.toString() ?? '') ?? 103.8610;

          final mainText = name.isNotEmpty
              ? name
              : displayName.split(',').first.trim();
          final secondaryParts = displayName
              .split(',')
              .skip(1)
              .join(',')
              .trim();

          final prediction = PlacePrediction(
            placeId: placeId,
            description: displayName,
            mainText: mainText,
            secondaryText: secondaryParts.isNotEmpty ? secondaryParts : null,
          );

          predictions.add(prediction);

          _detailsCache[placeId] = PlaceDetails(
            placeId: placeId,
            name: mainText,
            formattedAddress: displayName,
            latitude: lat,
            longitude: lon,
          );
        }

        if (predictions.isNotEmpty) {
          return predictions;
        }
      }
    } catch (_) {}

    return _searchFallbackLocations(query);
  }

  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    if (_detailsCache.containsKey(placeId)) {
      return _detailsCache[placeId];
    }

    return _findFallbackDetails(placeId);
  }

  static const List<Map<String, dynamic>> _fallbackHubs = [
    {
      'id': 'sg_marina_bay',
      'name': 'Marina Bay Sands',
      'address': '10 Bayfront Ave, Singapore 018956',
      'lat': 1.2837,
      'lng': 103.8607,
    },
    {
      'id': 'sg_everton_park',
      'name': 'Nylon Coffee Roasters',
      'address': '4 Everton Park, #01-40, Singapore 080004',
      'lat': 1.2778,
      'lng': 103.8398,
    },
    {
      'id': 'sg_national_gallery',
      'name': 'National Gallery Singapore',
      'address': '1 St Andrew\'s Rd, Singapore 178957',
      'lat': 1.2903,
      'lng': 103.8519,
    },
    {
      'id': 'sg_haji_lane',
      'name': 'Haji Lane Courtyard',
      'address': '21A Haji Lane, Kampong Glam, Singapore 189214',
      'lat': 1.3009,
      'lng': 103.8587,
    },
    {
      'id': 'sg_tiong_bahru',
      'name': 'Tiong Bahru Community Trail',
      'address': '58 Seng Poh Rd, Singapore 160058',
      'lat': 1.2852,
      'lng': 103.8335,
    },
    {
      'id': 'sg_gardens_by_the_bay',
      'name': 'Gardens by the Bay',
      'address': '18 Marina Gardens Dr, Singapore 018953',
      'lat': 1.2816,
      'lng': 103.8636,
    },
  ];

  List<PlacePrediction> _searchFallbackLocations(String query) {
    final lower = query.toLowerCase();
    return _fallbackHubs
        .where(
          (hub) =>
              (hub['name'] as String).toLowerCase().contains(lower) ||
              (hub['address'] as String).toLowerCase().contains(lower),
        )
        .map(
          (hub) => PlacePrediction(
            placeId: hub['id'] as String,
            description: '${hub['name']}, ${hub['address']}',
            mainText: hub['name'] as String,
            secondaryText: hub['address'] as String,
          ),
        )
        .toList();
  }

  PlaceDetails? _findFallbackDetails(String placeId) {
    for (final hub in _fallbackHubs) {
      if (hub['id'] == placeId) {
        return PlaceDetails(
          placeId: hub['id'] as String,
          name: hub['name'] as String,
          formattedAddress: hub['address'] as String,
          latitude: hub['lat'] as double,
          longitude: hub['lng'] as double,
        );
      }
    }
    return null;
  }
}
