import 'package:flutter/material.dart';
import 'package:zapac/data/favorite_routes_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  _SearchDestinationPageState createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  final String apiKey = "AIzaSyAJP6e_5eBGz1j8b6DEKqLT-vest54Atkc";
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  
  // Placeholder for recent locations
  final List<Map<String, dynamic>> _recentLocations = [
    {'description': 'House ni Gorgeous', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'House sa Gwapa', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'House ni Pretty', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'SM J Mall', 'place_id': 'ChIJb_MjLwtwqTMReyS2tJz13ic'},
    {'description': 'House ni Lim', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'iAcademy Cebu', 'place_id': 'ChIJ155n0wtwqTMRsP82-fG436Y'},
    {'description': 'Ayala Malls Central Bloc', 'place_id': 'ChIJ-c52xgtwqTMR_F098xGvXD4'},
  ];

  Future<void> _getPredictions(String input) async {
    // ... (same prediction logic as before)
    if (input.isEmpty) { setState(() => _predictions = []); return; }
    const location = "10.3157,123.8854";
    const radius = "30000";
    const components = "country:ph";
    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&location=$location&radius=$radius&strictbounds=true&components=$components';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 && mounted) {
      setState(() => _predictions = json.decode(response.body)['predictions']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ZAPAC APP"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.content_copy), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _getPredictions,
              decoration: InputDecoration(
                hintText: 'Where to?',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          // Favorite Routes Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: favoriteRoutes.map((route) {
                return ElevatedButton(
                  onPressed: () => Navigator.pop(context, {'route': route}),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6CA89A)),
                  child: Text(route.routeName, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 32),
          // Predictions or Recent List
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildRecentList()
                : _buildPredictionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionList() {
    return ListView.builder(
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(_predictions[index]['description']),
          onTap: () => Navigator.pop(context, {'place': _predictions[index]}),
        );
      },
    );
  }

  Widget _buildRecentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("Recent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentLocations.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(_recentLocations[index]['description']),
                onTap: () => Navigator.pop(context, {'place': _recentLocations[index]}),
              );
            },
          ),
        ),
      ],
    );
  }
}