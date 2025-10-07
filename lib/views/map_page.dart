import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  int _currentIndex = 1;
  LatLng? _userPosition;
  LatLng? _markerPosition;
  final MapController _mapController = MapController();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _moveMapWhenReady() {
    if (mounted && _userPosition != null) {
      _mapController.move(_userPosition!, 16);
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Serviço de localização está desligado. Ative o GPS.';
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Permissão negada.';
          _loading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permissão negada permanentemente.';
          _loading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      LatLng userPos = LatLng(position.latitude, position.longitude);

      setState(() {
        _userPosition = userPos;
        _loading = false;
      });
      _moveMapWhenReady();
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter localização: $e';
        _loading = false;
      });
    }
  }

  Widget _buildChip(String label, Color color, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        selected: selected,
        selectedColor: color,
        backgroundColor: color.withOpacity(0.6),
        onSelected: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultCenter = LatLng(-30.6966, -51.5289); // Taquara
    final apiKey = dotenv.env['MAPTILER_API_KEY'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          if (_loading) const Center(child: CircularProgressIndicator()),

          if (!_loading && _userPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userPosition ?? defaultCenter,
                initialZoom: 16,
                onMapReady: () {
                  _moveMapWhenReady();
                },
                onTap: (tapPosition, point) {
                  setState(() {
                    _markerPosition = point;
                    _moveMapWhenReady();
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey',
                  userAgentPackageName: 'com.faccat.aqui_ajuda',
                ),
                MarkerLayer(
                  markers: [
                    if (_userPosition != null)
                      Marker(
                        point: _userPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                    if (_markerPosition != null)
                      Marker(
                        point: _markerPosition!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),

          if (_error != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 150),
                padding: const EdgeInsets.all(8),
                color: Colors.redAccent,
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Pesquisar",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        backgroundImage: AssetImage("assets/avatar.png"),
                        radius: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildChip("Comidas", Colors.pink.shade200, true),
                        _buildChip("Roupas", Colors.red.shade300, false),
                        _buildChip("Abrigo", Colors.orange.shade300, false),
                        _buildChip("Abrigo Pet", Colors.purple.shade300, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Ajuda"),
        ],
      ),
    );
  }
}
