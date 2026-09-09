import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  File? _profileImage;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jobController = TextEditingController();
  final _allergyController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  double _budget = 2400;
  LatLng _location = LatLng(37.7749, -122.4194); // San Francisco default
  String _locationAddress = "Tap to select";

  @override
  void initState() {
    super.initState();
    // Immediately resolve address for the default location
    _resolveAddress(_location);
  }

  // Pick profile image from gallery
  Future<void> _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  // Open date picker for birth date
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  // Display either "Age" or "XX years old"
  String get ageText {
    if (_selectedBirthDate == null) return 'Age';
    final now = DateTime.now();
    int age = now.year - _selectedBirthDate!.year;
    if (_selectedBirthDate!.month > now.month ||
        (_selectedBirthDate!.month == now.month &&
            _selectedBirthDate!.day > now.day)) {
      age--;
    }
    return "$age years old";
  }

  // Convert LatLng to a readable address
  Future<void> _resolveAddress(LatLng loc) async {
    try {
      final placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _locationAddress = "${p.street}, ${p.locality}, ${p.country}";
        });
      }
    } catch (e) {
      setState(() => _locationAddress = "Unable to get address");
    }
  }

  // Opens a bottom sheet slider to edit budget
  void _showBudgetEditor() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        double tempBudget = _budget;
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Your Budget",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    showValueIndicator: ShowValueIndicator.always,
                    activeTrackColor: Color(0xFF1C8585),
                    thumbColor: Color(0xFF1C8585),
                    valueIndicatorColor: Color(0xFF1C8585),
                  ),
                  child: Slider(
                    value: tempBudget,
                    min: 100,
                    max: 5000,
                    label: "\$${tempBudget.toInt()}",
                    onChanged: (double value) {
                      setModalState(() => tempBudget = value);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _budget = tempBudget);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1C8585),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Opens a map + search bar bottom sheet to pick location
  void _showLocationPicker() {
    LatLng currentLoc = _location; // <- Must be declared outside StatefulBuilder to persist

    final mapController = MapController();
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setModalState) {
            void _searchAndMove(String query) async {
              if (query.trim().isEmpty) return;

              final url = "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1";
              final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'Flutter-App'});

              if (response.statusCode == 200) {
                final results = json.decode(response.body);
                if (results.isNotEmpty) {
                  final lat = double.parse(results[0]['lat']);
                  final lon = double.parse(results[0]['lon']);
                  final newLoc = LatLng(lat, lon);

                  setModalState(() {
                    currentLoc = newLoc;
                  });

                  // 👇 Move map center to the searched location
                  mapController.move(newLoc, 14.0);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No results found')),
                  );
                }
              }
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Pin your location", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Search Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => _searchAndMove(value),
                          decoration: InputDecoration(
                            hintText: "Search address...",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.teal),
                        onPressed: () => _searchAndMove(searchController.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // The Map
                  SizedBox(
                    height: 300,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: currentLoc,
                        initialZoom: 14.0,
                        onTap: (tapPosition, latLng) {
                          setModalState(() {
                            currentLoc = latLng;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: currentLoc,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _location = currentLoc;
                          _resolveAddress(currentLoc);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C8585),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget for a rounded container around child
  Widget _buildRoundedField({required Widget child}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }

  // Final confirm action
  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Profile details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // PROFILE IMAGE
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFF0F7F7),
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF1C8585),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // NAME FIELDS
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'First name',
                        filled: true,
                        fillColor: const Color(0xFFF0F7F7),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Last name',
                        filled: true,
                        fillColor: const Color(0xFFF0F7F7),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AGE PICKER
              GestureDetector(
                onTap: _selectDate,
                child: _buildRoundedField(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                      const SizedBox(width: 12),
                      Text(ageText, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // GENDER DROPDOWN
              _buildRoundedField(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    hint: const Text("Select Gender"),
                    items: ['Male', 'Female'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // JOB
              _buildRoundedField(
                child: TextField(
                  controller: _jobController,
                  decoration: const InputDecoration.collapsed(hintText: 'Job'),
                ),
              ),
              const SizedBox(height: 16),

              // ALLERGIES
              _buildRoundedField(
                child: TextField(
                  controller: _allergyController,
                  decoration: const InputDecoration.collapsed(hintText: 'Allergies'),
                ),
              ),
              const SizedBox(height: 16),

              // BUDGET
              GestureDetector(
                onTap: _showBudgetEditor,
                child: _buildRoundedField(
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.teal),
                      const SizedBox(width: 12),
                      Text("${_budget.toInt()}", style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      const Icon(Icons.edit, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // LOCATION
              GestureDetector(
                onTap: _showLocationPicker,
                child: _buildRoundedField(
                  child: Row(
                    children: [
                      const Icon(Icons.location_pin, color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_locationAddress, style: const TextStyle(fontSize: 14))),
                      const Icon(Icons.edit_location_alt, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // CONFIRM BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C8585),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
