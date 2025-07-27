import 'package:flutter/material.dart';
import 'package:zapac/data/favorite_routes_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'map_utils.dart';

class SearchDestinationPage extends StatefulWidget {
  final String? initialSearchText;

  const SearchDestinationPage({super.key, this.initialSearchText});

  @override
  _SearchDestinationPageState createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  final String apiKey = "AIzaSyAJP6e_5eBGz1j8b6DEKqLT-vest54Atkc";
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];

  final List<Map<String, dynamic>> _recentLocations = [
    {'description': 'House ni Gorgeous', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'House sa Gwapa', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'House ni Pretty', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'SM J Mall', 'place_id': 'ChIJb_MjLwtwqTMReyS2tJz13ic'},
    {'description': 'House ni Lim', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'iAcademy Cebu', 'place_id': 'ChIJ155n0wtwqTMRsP82-fG436Y'},
    {'description': 'Ayala Malls Central Bloc', 'place_id': 'ChIJ-c52xgtwqTMR_F098xGvXD4'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchText != null) {
      _searchController.text = widget.initialSearchText!;
      _getPredictions(widget.initialSearchText!);
    }
  }

  Future<void> _getPredictions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onPrimary),
        title: Text(
          'Search Destination',
          style: TextStyle(
            color: cs.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: ShapeDecoration(
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(70),
                ),
                shadows: [
                  BoxShadow(
                    color: (isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.12)),
                    blurRadius: 6.8,
                    offset: const Offset(2, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _getPredictions,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Where to?',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(Icons.search, color: cs.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    route.routeName,
                    style: TextStyle(color: cs.onPrimary),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 32, color: cs.primary.withOpacity(0.4)),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListView.builder(
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        return Card(
          color: theme.cardColor,
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            leading: Icon(Icons.location_on_outlined, color: cs.primary),
            title: Text(
              _predictions[index]['description'],
              style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface),
            ),
            onTap: () {
              Navigator.pop(context, {'place': _predictions[index]});
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentList() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final headerColor = theme.brightness == Brightness.dark ? cs.onSurface.withOpacity(0.92) : cs.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Text(
            "Recent",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentLocations.length,
            itemBuilder: (context, index) {
              return Card(
                color: theme.cardColor,
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  leading: Icon(Icons.history, color: cs.primary),
                  title: Text(
                    _recentLocations[index]['description'],
                    style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                  onTap: () => Navigator.pop(context, {'place': _recentLocations[index]}),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}