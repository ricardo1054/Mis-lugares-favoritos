import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/country_detector.dart';
import 'package:flutter_application_1/screens/favorite_location.dart';
import 'package:latlong2/latlong.dart';

class FavoritesScreen extends StatelessWidget {
  final List<FavoriteLocation> favorites;
  final Function(LatLng)? onItemTap;
  final Function(LatLng)? onItemDelete;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    this.onItemTap,
    this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Lugares Favoritos'),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _showClearAllDialog(context),
              tooltip: 'Eliminar todos',
            ),
        ],
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildFavoriteItem(
                context,
                favorites[index],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_camera, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'No tienes lugares favoritos aún',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca en el mapa para agregar ubicaciones',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            'Puedes añadir fotos a cada ubicación',
            style:
                TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, FavoriteLocation favorite) {
    final country =
        CountryDetector.getCountryFromCoordinates(favorite.position);
    final dateStr =
        '${favorite.addedDate.day}/${favorite.addedDate.month}/${favorite.addedDate.year}';

    return Dismissible(
      key: Key('${favorite.position.latitude}_${favorite.position.longitude}'),
      background: Container(color: Colors.red),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar favorito'),
            content:
                const Text('¿Quieres eliminar este lugar de tus favoritos?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onItemDelete?.call(favorite.position),
      child: InkWell(
        onTap: () {
          onItemTap?.call(favorite.position);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              _buildImagePreview(favorite),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${favorite.position.latitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Lng: ${favorite.position.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Agregado: $dateStr',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.near_me, color: Colors.blue),
                onPressed: () {
                  onItemTap?.call(favorite.position);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(FavoriteLocation favorite) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: favorite.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                favorite.image!,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
              ),
            )
          : const Center(
              child: Icon(Icons.star, color: Colors.amber, size: 30),
            ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todos los favoritos'),
        content: const Text(
            '¿Estás seguro de que quieres borrar todos tus lugares favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Eliminar todos los favoritos
              for (var i = favorites.length - 1; i >= 0; i--) {
                onItemDelete?.call(favorites[i].position);
              }
            },
            child: const Text('Eliminar todos',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
