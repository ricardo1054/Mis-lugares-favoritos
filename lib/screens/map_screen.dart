import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/country_detector.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'favorites_screen.dart';
import '../widgets/profile_button.dart';
import 'favorite_location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<FavoriteLocation> _favorites = [];
  final MapController _mapController = MapController();
  final ImagePicker _imagePicker = ImagePicker();
  LatLng? _selectedPosition;

  // Configuración del proveedor de mapas
  static const _mapTiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _attributionText = '© OpenStreetMap contributors';

  void _handleMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });

    showDialog(
      context: context,
      builder: (context) => _buildPositionDialog(position),
    );
  }

  Widget _buildPositionDialog(LatLng position) {
    final alreadyFavorite = _favorites.any((fav) => fav.position == position);

    return AlertDialog(
      title: const Text('Ubicación seleccionada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Latitud: ${position.latitude.toStringAsFixed(6)}'),
          Text('Longitud: ${position.longitude.toStringAsFixed(6)}'),
          Text('País: ${CountryDetector.getCountryFromCoordinates(position)}'),
          const SizedBox(height: 16),
          if (alreadyFavorite)
            const Text('⭐ Ya está en tus favoritos')
          else
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _addFavorite(position);
              },
              child: const Text('Agregar a favoritos'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Future<void> _addFavorite(LatLng position) async {
    if (_favorites.any((fav) => fav.position == position)) return;

    final image = await _getImage(context);

    setState(() {
      _favorites.add(FavoriteLocation(
        position: position,
        image: image,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ubicación agregada a favoritos')),
    );
  }

  Future<File?> _getImage(BuildContext context) async {
    final action = await showDialog<ImageAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir foto al favorito'),
        content: const Text('¿Quieres asociar una foto a esta ubicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageAction.skip),
            child: const Text('Saltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageAction.camera),
            child: const Text('Tomar foto'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageAction.gallery),
            child: const Text('Elegir de galería'),
          ),
        ],
      ),
    );

    if (action == null || action == ImageAction.skip) return null;

    final pickedFile = await _imagePicker.pickImage(
      source: action == ImageAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }

  void _removeFavorite(LatLng position) {
    setState(() {
      _favorites.removeWhere((fav) => fav.position == position);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ubicación eliminada de favoritos')),
    );
  }

  void _centerOnPosition(LatLng position) {
    _mapController.move(position, 15.0);
    setState(() {
      _selectedPosition = position;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Centrado en: ${CountryDetector.getCountryFromCoordinates(position)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis luagres favoritos'),
        actions: [
          IconButton(
            icon: _favorites.isNotEmpty
                ? const Icon(Icons.star, color: Colors.amber)
                : const Icon(Icons.star_border),
            onPressed: () => _navigateToFavorites(),
          ),
          const ProfileButton(),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center:
              const LatLng(4.6097, -74.0817), // Bogotá como ubicación inicial
          zoom: 13.0,
          onTap: (_, position) => _handleMapTap(position),
        ),
        children: [
          TileLayer(
            urlTemplate: _mapTiles,
            userAgentPackageName: 'com.example.mapa_favoritos',
            subdomains: const ['a', 'b', 'c'], // Para balancear carga
            retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
          ),
          MarkerLayer(
            markers: [
              if (_selectedPosition != null)
                Marker(
                  point: _selectedPosition!,
                  builder: (ctx) => const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ..._favorites.map((fav) => Marker(
                    point: fav.position,
                    builder: (ctx) => GestureDetector(
                      onTap: () => _centerOnPosition(fav.position),
                      child: fav.image != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(fav.image!),
                              radius: 20,
                            )
                          : const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 30,
                            ),
                    ),
                  )),
            ],
          ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                _attributionText,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _selectedPosition != null
          ? FloatingActionButton(
              tooltip: 'Centrar en ubicación seleccionada',
              child: const Icon(Icons.my_location),
              onPressed: () => _centerOnPosition(_selectedPosition!),
            )
          : null,
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favorites: _favorites,
          onItemTap: _centerOnPosition,
          onItemDelete: _removeFavorite,
        ),
      ),
    );
  }
}

enum ImageAction { skip, camera, gallery }
