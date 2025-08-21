  
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../gemini_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController activitiesController = TextEditingController();
  String mealPreference = '';

  final List<String> dietaryPreferences = [
    'None',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Pescatarian',
    'Keto',
    'Halal',
    'Kosher',
    'Paleo',
    'Low-Carb',
    'Local Dishes',
  ];
  late final String apiKey;
    String itinerary = '';
    bool isLoading = false;
    
  int numberOfDays = 1;

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  // Wide screen: logo and title on same line
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'resources/TravelEZ-logo.jpg',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'TravelEZ Itinerary Planner',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  );
                } else {
                  // Narrow screen: logo centered above title
                  return Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'resources/TravelEZ-logo.jpg',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'TravelEZ Itinerary Planner',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: activitiesController,
              decoration: InputDecoration(labelText: 'Activities (comma separated)'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: numberOfDays,
              decoration: InputDecoration(labelText: 'Number of Days'),
              items: List.generate(10, (i) => i + 1)
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() { numberOfDays = value ?? 1; });
              },
            ),
            SizedBox(height: 10),
            Text('Meal Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: mealPreference.isEmpty ? null : mealPreference,
              decoration: InputDecoration(labelText: 'Meal Preference (applies to all meals)'),
              items: dietaryPreferences.map((pref) => DropdownMenuItem(
                value: pref,
                child: Text(pref),
              )).toList(),
              onChanged: (value) {
                setState(() { mealPreference = value ?? ''; });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setState(() { isLoading = true; itinerary = ''; });
                final location = locationController.text.trim();
                final activities = activitiesController.text.trim();
                final breakfast = mealPreference;
                final lunch = mealPreference;
                final dinner = mealPreference;
                final snacks = mealPreference;
                try {
                  final gemini = GeminiService(apiKey);
                  final result = await gemini.getItinerary(
                    location: location,
                    activities: activities,
                    breakfast: breakfast,
                    lunch: lunch,
                    dinner: dinner,
                    snacks: snacks,
                    days: numberOfDays,
                  );
                  setState(() { itinerary = result; });
                } catch (e) {
                  setState(() { itinerary = 'Error: $e'; });
                }
                setState(() { isLoading = false; });
              },
              child: isLoading ? CircularProgressIndicator() : Text('Generate Itinerary'),
            ),
            SizedBox(height: 20),
            if (itinerary.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itinerary),
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.copy),
                          label: Text('Copy'),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: itinerary));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Itinerary copied to clipboard!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
