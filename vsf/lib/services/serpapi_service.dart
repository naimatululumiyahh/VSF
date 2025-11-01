import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple SerpApi wrapper for place autocomplete / details.
///
/// NOTE: This expects you to provide the key in `lib/config/secrets.dart` as
/// `const String SERPAPI_KEY = 'your_key_here';` (see `secrets_example.dart`).
class SerpApiService {
  SerpApiService._();
  static final SerpApiService instance = SerpApiService._();

  /// Autocomplete suggestions.
  /// Returns a list of maps with keys: "description", possibly "place_id",
  /// and possibly "lat","lng" if SerpApi returned geometry.
  Future<List<Map<String, dynamic>>> autocomplete(String input, String apiKey) async {
    if (input.trim().isEmpty) return [];

    final params = {
      'engine': 'google_places_autocomplete',
      'input': input,
      'api_key': apiKey,
      'language': 'id',
    };

    final uri = Uri.https('serpapi.com', '/search.json', params);

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('SerpApi error: ${res.statusCode}');
    }

    final jsonBody = jsonDecode(res.body) as Map<String, dynamic>;

    // SerpApi may return predictions under different keys depending on engine.
    final results = <Map<String, dynamic>>[];

    // common keys: 'predictions', 'autocomplete', 'results'
    final candidates = jsonBody['predictions'] ?? jsonBody['autocomplete'] ?? jsonBody['results'] ?? jsonBody['places_results'];
    if (candidates is List) {
      for (final item in candidates) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          // try to normalize coordinates
          if (m['geometry'] != null && m['geometry']['location'] != null) {
            final loc = m['geometry']['location'];
            if (loc['lat'] != null && loc['lng'] != null) {
              m['lat'] = loc['lat'];
              m['lng'] = loc['lng'];
            }
          }
          results.add(m);
        }
      }
    }

    // Fallback: SerpApi sometimes returns a top-level 'search_metadata'/'places_results' structures.
    return results;
  }

  /// Place details by place_id or by query (depends on engine). Returns raw JSON.
  Future<Map<String, dynamic>?> placeDetails({required String placeId, required String apiKey}) async {
    final params = {
      'engine': 'google_places',
      'place_id': placeId,
      'api_key': apiKey,
      'language': 'id',
    };

    final uri = Uri.https('serpapi.com', '/search.json', params);
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final jsonBody = jsonDecode(res.body) as Map<String, dynamic>;
    return jsonBody;
  }
}
