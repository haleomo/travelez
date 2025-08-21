import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  final String endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  GeminiService(this.apiKey);

  Future<String> getItinerary({
    required String location,
    required String activities,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snacks,
    required int days,
  }) async {
    final prompt = 'Plan a $days-day itinerary for $location. Activities: $activities. Meals: Breakfast - $breakfast, Lunch - $lunch, Dinner - $dinner, Snacks - $snacks.';
    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': [{'text': prompt}]}
        ]
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No itinerary found.';
    } else {
      return 'Error: ${response.statusCode} - ${response.body}';
    }
  }
}
