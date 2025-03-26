import 'package:latlong2/latlong.dart';
import 'dart:io';

class FavoriteLocation {
  final LatLng position;
  final File? image;
  final DateTime addedDate;

  FavoriteLocation({
    required this.position,
    this.image,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();
}
