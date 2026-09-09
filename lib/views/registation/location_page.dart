import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'distance_preference_page.dart';

import '../../services/db_service.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentLocation = LatLng(37.7749, -122.4194); // Default (San Francisco)
  MapController _mapController = MapController();

  /// Convert Address to Coordinates Using OpenStreetMap API
  void _searchLocation() async {
    String address = _searchController.text.trim();
    if (address.isEmpty) {
      _showErrorDialog("Please enter a location.");
      return;
    }

    try {
      String url = "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Flutter-App', // Required for OpenStreetMap requests
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]["lat"]);
          double lon = double.parse(data[0]["lon"]);

          setState(() {
            _currentLocation = LatLng(lat, lon);
          });

          _mapController.move(_currentLocation, 14.0); // Move map to new location
        } else {
          _showErrorDialog("Location not found. Try another search.");
        }
      } else {
        _showErrorDialog("Failed to get location. Please check your connection.");
      }
    } catch (e) {
      _showErrorDialog("Network error. Please try again.");
    }
  }

  void _validateAndNavigate() {
    // Check if the user has moved the pin from the default location
    if (_currentLocation.latitude == 37.7749 && _currentLocation.longitude == -122.4194) {
      _showErrorDialog("Please pin your location on the map before proceeding.");
      return;
    }

    _updateStat("self", "registration", "6");

    _updateProfile("latitude", _currentLocation.latitude.toStringAsFixed(6));
    _updateProfile("longitude", _currentLocation.longitude.toStringAsFixed(6));

    // If a location is selected, proceed to the next page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DistancePreferencePage()),
    );
  }

  void _updateProfile(String field, String value) async {
    Map<String, String> response = await DBService.updateProfileField(field, value);

    _checkError(response);
  }

  void _updateStat(String userId, String key, String value) async {
    Map<String, String> response = await DBService.updateStat(userId, key, value);

    _checkError(response);
  }

  void _checkError(Map<String, String> response) {
    if (response["status"] == "ERROR") {
      _showErrorDialog(response["error"] ?? "An unknown error occurred.");
    } else if (response["status"] == "UNKNOWN") {
      _showErrorDialog("An unknown error occurred.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pin your location",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Enter your address",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.teal),
                  onPressed: _searchLocation, // Call search function
                ),
              ],
            ),
            SizedBox(height: 16),

            // OpenStreetMap Widget
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController, // Use map controller
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 14.0,
                    onTap: (tapPosition, latLng) {
                      setState(() {
                        _currentLocation = latLng; // Update pin location
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            Text(
              "Move the pin on the map to set your exact location",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _validateAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C8585),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
