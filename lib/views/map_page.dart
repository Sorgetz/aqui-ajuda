import 'dart:async';

import 'package:aqui_ajuda_app/viewmodel/map_point_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class Map extends StatefulWidget {
  final MapPointDTO? mapPointDTO;
  const Map({super.key, this.mapPointDTO});

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

  //map point
  late TextEditingController _mapTypeController;
  late TextEditingController _mapLatitudadeController;
  late TextEditingController _mapLongitudeController;

  final PopupController _popupLayerController = PopupController();
  // final TextEditingController _mapSearchController = TextEditingController();

  @override
  void initState() {
    _getUserLocation();
    _markerPosition = null;
    _mapTypeController = TextEditingController(
      text: widget.mapPointDTO?.type ?? '',
    );
    _mapLatitudadeController = TextEditingController(
      text: widget.mapPointDTO?.latitude.toString() ?? '',
    );
    _mapLongitudeController = TextEditingController(
      text: widget.mapPointDTO?.longitude.toString() ?? '',
    );
    super.initState();
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
    final vm = Provider.of<MapPointViewModel>(context);
    final apiKey = dotenv.env['MAPTILER_API_KEY'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          if (_loading) const Center(child: CircularProgressIndicator()),

          if (!_loading && _userPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _userPosition!,
                zoom: 16,
                onMapReady: () {
                  _mapController.move(_userPosition!, 16);
                },
                onTap: (tapPosition, point) {
                  setState(() {
                    _markerPosition = point;
                    _mapLatitudadeController.text = point.latitude.toString();
                    _mapLongitudeController.text = point.longitude.toString();
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey',
                  userAgentPackageName: 'com.example.aqui_ajuda',
                ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markers: [
                      if (_userPosition != null)
                        Marker(
                          point: _userPosition!,
                          width: 40,
                          height: 40,
                          builder: (_) => const Icon(
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
                          builder: (_) => const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      if (vm.mapPoints.isNotEmpty)
                        ...vm.mapPoints.map(
                          (point) => Marker(
                            point: LatLng(point.latitude, point.longitude),
                            width: 60,
                            height: 60,
                            builder: (_) => Icon(
                              _getIconFor(point.type),
                              color: const Color.fromARGB(255, 101, 66, 255),
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        // acha o ponto correspondente ao marcador
                        final point = vm.mapPoints.firstWhere(
                          (p) =>
                              p.latitude == marker.point.latitude &&
                              p.longitude == marker.point.longitude,
                        );

                        return SizedBox(
                          width: 200,
                          child: Card(
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getIconFor(point.type),
                                        color: Colors.pinkAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        point.type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pinkAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    point.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    point.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
        onPressed: () async {
          final selectedType = await showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            builder: (context) {
              String? selectedOption;
              return StatefulBuilder(
                builder: (context, setState) {
                  void select(String option) {
                    setState(() {
                      selectedOption = option;
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cabeçalho com título e botão de fechar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 40),
                            const Text(
                              'Categorize o ponto',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black54,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (selectedOption == null) ...[
                          // Primeira linha
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _OptionButton(
                                icon: Icons.lunch_dining_rounded,
                                label: 'Alimento',
                                selected: selectedOption == 'Alimento',
                                onTap: () => select('Alimento'),
                              ),
                              _OptionButton(
                                icon: Icons.house_rounded,
                                label: 'Abrigo',
                                selected: selectedOption == 'Abrigo',
                                onTap: () => select('Abrigo'),
                              ),
                              _OptionButton(
                                icon: Icons.checkroom_rounded,
                                label: 'Roupas',
                                selected: selectedOption == 'Roupas',
                                onTap: () => select('Roupas'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Segunda linha
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _OptionButton(
                                icon: Icons.child_friendly_rounded,
                                label: 'Bebê',
                                selected: selectedOption == 'Bebê',
                                onTap: () => select('Bebê'),
                              ),
                              _OptionButton(
                                icon: Icons.pets_rounded,
                                label: 'Abrigo Pet',
                                selected: selectedOption == 'Abrigo Pet',
                                onTap: () => select('Abrigo Pet'),
                              ),
                              _OptionButton(
                                icon: Icons.keyboard_control,
                                label: 'Outro',
                                selected: selectedOption == 'Outro',
                                onTap: () => select('Outro'),
                              ),
                            ],
                          ),
                        ],
                        if (selectedOption != null) ...[
                          const SizedBox(height: 16),
                          Icon(
                            _getIconFor(
                              selectedOption!,
                            ), // ícone correspondente
                            color: Colors.pinkAccent,
                            size: 60,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            '$selectedOption',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => setState(() {
                                  selectedOption = null;
                                }),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context, selectedOption);
                                },
                                child: const Text('Confirmar'),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
          );
          // Se o usuário confirmou o tipo e clicou em algum ponto do mapa
          if (selectedType != null && _markerPosition != null) {
            _mapTypeController.text = selectedType;

            // Crie seu DTO para salvar
            final mapPoint = MapPointDTO(
              title: 'Teste',
              description: 'AAAAAAAAAAAAAAA',
              type: selectedType,
              latitude: _markerPosition!.latitude,
              longitude: _markerPosition!.longitude,
              createdAt: Timestamp.now(),
              active: true,
            );

            // Aqui você pode salvar no ViewModel, Firestore, etc
            print(
              'Salvando ponto: ${mapPoint.type} - '
              '${mapPoint.latitude}, ${mapPoint.longitude}',
            );

            vm.addMapPoint(dto: mapPoint);

            setState(() {
              _markerPosition = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selecione um ponto e uma categoria.'),
              ),
            );
          }
        },
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

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color pinkMain = Colors.pinkAccent;
    final Color pinkLight = Colors.pink.shade50;
    final Color pinkBorder = Colors.pink.shade200;
    final Color pinkText = Colors.pinkAccent;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? pinkLight : Colors.grey.shade200,
              border: selected ? Border.all(color: pinkBorder, width: 2) : null,
            ),
            child: Icon(
              icon,
              color: selected ? pinkMain : Colors.grey.shade600,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: selected ? pinkText : Colors.grey.shade800,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _getIconFor(String label) {
  switch (label) {
    case 'Alimento':
      return Icons.lunch_dining_rounded;
    case 'Abrigo':
      return Icons.house_rounded;
    case 'Roupas':
      return Icons.checkroom_rounded;
    case 'Bebê':
      return Icons.child_friendly_rounded;
    case 'Abrigo Pet':
      return Icons.pets_rounded;
    default:
      return Icons.keyboard_control;
  }
}
