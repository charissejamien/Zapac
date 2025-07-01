import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationSearchPage extends StatefulWidget {
  final String apiKey;

  const LocationSearchPage({super.key, required this.apiKey});

  @override
  _LocationSearchPageState createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];

  Future<void> _getPredictions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.apiKey}';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _predictions = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter a location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _predictions = [];
                    });
                  },
                ),
              ),
              onChanged: _getPredictions,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_predictions[index]['description']),
                  onTap: () {
                    Navigator.pop(context, _predictions[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}