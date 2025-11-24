import 'dart:async';

import 'package:aqui_ajuda_app/viewmodel/feedback_viewmodel.dart';
import 'package:aqui_ajuda_app/viewmodel/map_point_viewmodel.dart';
import 'package:aqui_ajuda_app/views/help_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  final MapPointDTO? mapPointDTO;
  const Maps({super.key, this.mapPointDTO});

  @override
  State<Maps> createState() => _MapState();
}

class _MapState extends State<Maps> {
  int _currentIndex = 1;
  LatLng? _userPosition;
  LatLng? _markerPosition;
  final MapController _mapController = MapController();
  bool _loading = true;
  String? _error;

  final screens = [Maps(), HelpScreen()];

  //map point
  late TextEditingController _mapTypeController;
  late TextEditingController _mapLatitudadeController;
  late TextEditingController _mapLongitudeController;

  final PopupController _popupLayerController = PopupController();
  // final TextEditingController _mapSearchController = TextEditingController();

  String _selectedChip = ''; //pesquisa por categoria

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

  Widget _buildChip(String label, Color color) {
    var selected = _selectedChip == label;
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
        onSelected: (newlySelected) {
          setState(() {
            _selectedChip = newlySelected ? label : '';
          });
        },
      ),
    );
  }

  Future<String?> _showCategoryBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<String>(
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
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Categorize o ponto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (selectedOption == null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _OptionButton(
                        icon: Icons.lunch_dining_rounded,
                        label: 'Comidas',
                        selected: selectedOption == 'Comidas',
                        onTap: () => setState(() => selectedOption = 'Comidas'),
                      ),
                      _OptionButton(
                        icon: Icons.house_rounded,
                        label: 'Abrigo',
                        selected: selectedOption == 'Abrigo',
                        onTap: () => setState(() => selectedOption = 'Abrigo'),
                      ),
                      _OptionButton(
                        icon: Icons.checkroom_rounded,
                        label: 'Roupas',
                        selected: selectedOption == 'Roupas',
                        onTap: () => setState(() => selectedOption = 'Roupas'),
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
                        onTap: () => setState(() => selectedOption = 'Bebê'),
                      ),
                      _OptionButton(
                        icon: Icons.pets_rounded,
                        label: 'Abrigo Pet',
                        selected: selectedOption == 'Abrigo Pet',
                        onTap: () =>
                            setState(() => selectedOption = 'Abrigo Pet'),
                      ),
                      _OptionButton(
                        icon: Icons.keyboard_control,
                        label: 'Outro',
                        selected: selectedOption == 'Outro',
                        onTap: () => setState(() => selectedOption = 'Outro'),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Icon(
                    _getIconFor(selectedOption!),
                    color: Colors.pinkAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedOption!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                        ),
                        onPressed: () => setState(() => selectedOption = null),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context, selectedOption),
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, String>?> _showPointDetailsBottomSheet(
    BuildContext context,
  ) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final contactController = TextEditingController();
    final scheduleController = TextEditingController();

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Descreva o ponto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do ponto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contato (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Horário (ex: 08:00 - 18:00)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Voltar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty) return;
                      Navigator.pop(context, {
                        'title': titleController.text,
                        'description': descController.text,
                        'contact': contactController.text,
                        'schedule': scheduleController.text,
                      });
                    },
                    child: const Text('Avançar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showConfirmationBottomSheet(
    BuildContext context,
    String category,
    Map<String, String> details,
  ) async {
    return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconFor(category),
                    color: Colors.pinkAccent,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    details['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details['description'] ?? '',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (details['contact']?.isNotEmpty ?? false)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 4),
                        Text(details['contact']!),
                      ],
                    ),
                  if (details['schedule']?.isNotEmpty ?? false)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 4),
                        Text(details['schedule']!),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Editar'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Salvar ponto'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  }

  Future<bool> _showInfoBottomSheet(
    BuildContext context,
    MapPointDTO mapPoint,
    UserCredential appUser,
  ) async {
    // Obtém o ViewModel existente
    final feedbackVM = Provider.of<FeedbackViewModel>(context, listen: false);

    // Carrega os feedbacks do ponto atual
    feedbackVM.loadFeedbacks(mapPoint.id!);

    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (context) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Consumer<FeedbackViewModel>(
                    builder: (context, vm, child) {
                      final feedbacks = vm.feedbacks;

                      return ListView(
                        controller: scrollController,
                        children: [
                          // ---------- Cabeçalho ----------
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getIconFor(mapPoint.type),
                                color: Colors.pinkAccent,
                                size: 50,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                mapPoint.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                mapPoint.description,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              if (mapPoint.contact.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.phone, size: 18),
                                    const SizedBox(width: 4),
                                    Text(mapPoint.contact),
                                  ],
                                ),
                              if (mapPoint.openTimes.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.access_time, size: 18),
                                    const SizedBox(width: 4),
                                    Text(mapPoint.openTimes),
                                  ],
                                ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade300,
                                      foregroundColor: Colors.black87,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Sair'),
                                  ),
                                  if (mapPoint.createdBy !=
                                      appUser!.user!.displayName)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pinkAccent,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context, true);
                                        await showFeedbackBottomSheet(
                                          context,
                                          mapPoint,
                                          appUser,
                                        );
                                      },
                                      child: const Text('Feedback'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text(
                                'Feedbacks dos usuários',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),

                          // ---------- Lista de feedbacks ----------
                          if (feedbacks.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Nenhum feedback ainda. Seja o primeiro a avaliar!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          else
                            ...feedbacks.map((f) {
                              double avg =
                                  [
                                        f.efficiency ?? 0,
                                        f.accessibility ?? 0,
                                        f.security ?? 0,
                                        f.organization ?? 0,
                                      ]
                                      .where((n) => n > 0)
                                      .fold<double>(0, (a, b) => a + b) /
                                  ([
                                    f.efficiency,
                                    f.accessibility,
                                    f.security,
                                    f.organization,
                                  ].where((n) => n != null && n > 0).length);

                              IconData icon;
                              if (avg >= 4) {
                                icon = Icons.sentiment_very_satisfied;
                              } else if (avg >= 3) {
                                icon = Icons.sentiment_satisfied;
                              } else if (avg >= 2) {
                                icon = Icons.sentiment_neutral;
                              } else {
                                icon = Icons.sentiment_dissatisfied;
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.pinkAccent,
                                      backgroundImage:
                                          f.createdByProfilePic != null &&
                                              f.createdByProfilePic!.isNotEmpty
                                          ? NetworkImage(f.createdByProfilePic!)
                                          : null,
                                      child:
                                          f.createdByProfilePic == null ||
                                              f.createdByProfilePic!.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                f.createdBy,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                icon,
                                                color: Colors.pinkAccent,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          if (!f.isAvailable)
                                            const Text(
                                              '⚠️ Marcou como ponto inexistente',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          if (f.experience != null &&
                                              f.experience!.isNotEmpty)
                                            Text(
                                              f.experience!,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _formatTimestamp(f.createdAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        ) ??
        false;
  }

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MapPointViewModel>(context);
    vm.loadMapPoints(_selectedChip);
    final apiKey = dotenv.env['MAPTILER_API_KEY'] ?? '';
    final user = ModalRoute.of(context)!.settings.arguments;
    final UserCredential? appUser = user as UserCredential?;

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
                    _popupLayerController.hideAllPopups();
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey',
                  userAgentPackageName: 'com.example.aqui_ajuda',
                ),
                MarkerLayer(
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
                  ],
                ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markers: [
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

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: SizedBox(
                            width: 260,
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
                                    if (point.openTimes != '')
                                      Text(
                                        point.openTimes,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.pinkAccent,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              _popupLayerController
                                                  .hideAllPopups();
                                              if (point.createdBy ==
                                                  appUser!.user!.displayName) {
                                                await showDeactivateDialog(
                                                  context,
                                                  point.title,
                                                  point.id!,
                                                  vm,
                                                );
                                              } else {
                                                await showFeedbackBottomSheet(
                                                  context,
                                                  point,
                                                  appUser,
                                                );
                                              }
                                            },
                                            child: Text(
                                              point.createdBy ==
                                                      appUser!.user!.displayName
                                                  ? 'Desativar'
                                                  : 'Feedback',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.pinkAccent,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              _popupLayerController
                                                  .hideAllPopups();
                                              await _showInfoBottomSheet(
                                                context,
                                                point,
                                                appUser,
                                              );
                                            },
                                            child: Text('Acessar'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                        _buildChip("Comidas", Colors.pink.shade200),
                        _buildChip("Roupas", Colors.red.shade300),
                        _buildChip("Abrigo", Colors.orange.shade300),
                        _buildChip("Abrigo Pet", Colors.purple.shade300),
                        _buildChip("Outro", Colors.green.shade300),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: _markerPosition != null,
        child: FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          onPressed: () async {
            if (_markerPosition == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toque no mapa para selecionar um ponto.'),
                ),
              );
              return;
            }

            String? selectedType;
            Map<String, String>? details;
            bool confirmed = false;

            // 1️⃣ Categoria
            while (selectedType == null) {
              selectedType = await _showCategoryBottomSheet(context);
              if (selectedType == null) return; // cancelou totalmente
            }

            // 2️⃣ Detalhes
            while (details == null) {
              details = await _showPointDetailsBottomSheet(context);
              if (details == null) {
                // clicou em "Voltar" → volta para categoria
                selectedType = await _showCategoryBottomSheet(context);
                if (selectedType == null) return;
              }
            }

            // 3️⃣ Confirmação
            var pointDetails = details;
            while (!confirmed) {
              confirmed = await _showConfirmationBottomSheet(
                context,
                selectedType!,
                pointDetails,
              );
              if (!confirmed) {
                final newDetails = await _showPointDetailsBottomSheet(context);
                if (newDetails == null) return; // cancelou durante edição
                pointDetails = newDetails;
              }
            }

            final mapPoint = MapPointDTO(
              title: details['title'] ?? '',
              description: details['description'] ?? '',
              contact: details['contact'] ?? '',
              openTimes: details['schedule'] ?? '',
              type: selectedType!,
              latitude: _markerPosition!.latitude,
              longitude: _markerPosition!.longitude,
              createdAt: Timestamp.now(),
              createdBy: appUser!.user!.displayName ?? '',
              active: true,
            );

            Provider.of<MapPointViewModel>(
              context,
              listen: false,
            ).addMapPoint(dto: mapPoint);

            setState(() => _markerPosition = null);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ponto adicionado com sucesso!')),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
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

Future<void> showDeactivateDialog(
  BuildContext context,
  String title,
  String pointId,
  MapPointViewModel vm,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, color: Colors.pinkAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                'Desativar ponto',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Deseja realmente desativar "$title"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await vm.deleteMapPoint(pointId);
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ponto desativado com sucesso!'),
                          backgroundColor: Colors.pinkAccent,
                        ),
                      );
                    },
                    child: const Text('Sim, desativar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showFeedbackBottomSheet(
  BuildContext context,
  MapPointDTO point,
  UserCredential appUser,
) async {
  int step = 0;

  // Valores das avaliações
  int efficiency = 0;
  int accessibility = 0;
  int security = 0;
  int organization = 0;
  bool? isAvailable;
  final TextEditingController experienceController = TextEditingController();

  // Define cores e ícones das carinhas
  Color getColorForValue(int value) {
    switch (value) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey.shade300;
    }
  }

  IconData getIconForValue(int value) {
    switch (value) {
      case 1:
        return Icons.sentiment_very_dissatisfied_rounded;
      case 2:
        return Icons.sentiment_dissatisfied_rounded;
      case 3:
        return Icons.sentiment_neutral_rounded;
      case 4:
        return Icons.sentiment_satisfied_rounded;
      case 5:
        return Icons.sentiment_very_satisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  Widget buildRatingRow(
    String label,
    int selected,
    void Function(int) onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;
              final color = getColorForValue(value);
              final isSelected = selected >= value;
              return GestureDetector(
                onTap: () => onSelect(value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    getIconForValue(value),
                    size: 46,
                    color: isSelected ? color : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Etapa 1 — Avaliar categorias
  Widget stepAvaliacoes(StateSetter setState) {
    return Column(
      children: [
        Text(
          'Avalie "${point.title}"',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        buildRatingRow(
          'Eficiência',
          efficiency,
          (v) => setState(() => efficiency = v),
        ),
        buildRatingRow(
          'Acessibilidade',
          accessibility,
          (v) => setState(() => accessibility = v),
        ),
        buildRatingRow(
          'Segurança',
          security,
          (v) => setState(() => security = v),
        ),
        buildRatingRow(
          'Organização',
          organization,
          (v) => setState(() => organization = v),
        ),
      ],
    );
  }

  // Etapa 2 — Ponto ainda existe?
  Widget stepPontoExiste(StateSetter setState) {
    return Column(
      children: [
        const Text(
          'O ponto ainda existe?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => isAvailable = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable == true
                    ? Colors.pinkAccent
                    : Colors.grey.shade200,
                foregroundColor: isAvailable == true
                    ? Colors.white
                    : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(120, 48),
              ),
              child: const Text('Sim'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => setState(
                () => isAvailable = false,
              ), //TO DO: termina a avaliação e salva
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable == false
                    ? Colors.pinkAccent
                    : Colors.grey.shade200,
                foregroundColor: isAvailable == false
                    ? Colors.white
                    : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(120, 48),
              ),
              child: const Text('Não'),
            ),
          ],
        ),
      ],
    );
  }

  // Etapa 3 — Relato de experiência
  Widget stepExperiencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Relate sua experiência',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: experienceController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Conte como foi sua experiência...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pinkAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (step == 0) stepPontoExiste(setState),
                if (step == 1) stepAvaliacoes(setState),
                if (step == 2) stepExperiencia(),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (step < 2 && !!isAvailable!) {
                            setState(() => step++);
                          } else {
                            final dto = FeedbackDTO(
                              efficiency: efficiency,
                              accessibility: accessibility,
                              security: security,
                              organization: organization,
                              isAvailable: isAvailable ?? true,
                              createdBy: appUser!.user!.displayName ?? '',
                              createdByProfilePic:
                                  appUser!.user!.photoURL ?? '',
                              mapPointId: point.id!,
                              createdAt: Timestamp.now(),
                              experience: experienceController.text,
                            );
                            final feedbackVM = Provider.of<FeedbackViewModel>(
                              context,
                              listen: false,
                            );

                            feedbackVM.addFeedback(dto: dto);

                            feedbackVM.loadFeedbacks(point.id!);
                            final uniqueFeedbacksAvaibility = feedbackVM
                                .feedbacks
                                .where((fb) => fb.isAvailable == false)
                                .map((fb) => fb.createdBy)
                                .toSet();

                            if (uniqueFeedbacksAvaibility.length >= 3) {
                              Provider.of<MapPointViewModel>(
                                context,
                                listen: false,
                              ).deleteMapPoint(point.id!);
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feedback enviado com sucesso!'),
                                backgroundColor: Colors.pinkAccent,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(step < 2 ? 'Próximo' : 'Enviar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

IconData _getIconFor(String label) {
  switch (label) {
    case 'Comidas':
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
