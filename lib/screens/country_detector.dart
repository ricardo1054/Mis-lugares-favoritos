import 'package:latlong2/latlong.dart';

class CountryDetector {
  static String getCountryFromCoordinates(LatLng position) {
    // América del Norte
    if (position.latitude >= 14.0 &&
        position.latitude <= 83.0 &&
        position.longitude >= -172.0 &&
        position.longitude <= -52.0) {
      if (position.latitude >= 24.0 &&
          position.latitude <= 83.0 &&
          position.longitude >= -125.0 &&
          position.longitude <= -66.0) {
        return "Estados Unidos";
      }
      if (position.latitude >= 41.0 && position.longitude >= -141.0) {
        return "Canadá";
      }
      return "México";
    }

    // América Central
    if (position.latitude >= 7.0 &&
        position.latitude <= 23.0 &&
        position.longitude >= -92.0 &&
        position.longitude <= -77.0) {
      return "Centroamérica";
    }

    // América del Sur
    if (position.latitude >= -56.0 &&
        position.latitude <= 13.0 &&
        position.longitude >= -82.0 &&
        position.longitude <= -34.0) {
      if (position.latitude >= -56.0 && position.latitude <= -21.0) {
        return "Argentina";
      }
      if (position.latitude >= -22.0 &&
          position.latitude <= 5.0 &&
          position.longitude >= -79.0 &&
          position.longitude <= -66.0) {
        return "Perú";
      }
      return "Brasil";
    }

    // Europa
    if (position.latitude >= 35.0 &&
        position.latitude <= 71.0 &&
        position.longitude >= -25.0 &&
        position.longitude <= 65.0) {
      if (position.latitude >= 40.0 &&
          position.latitude <= 54.0 &&
          position.longitude >= -10.0 &&
          position.longitude <= 3.0) {
        return "España";
      }
      if (position.latitude >= 41.0 &&
          position.latitude <= 51.0 &&
          position.longitude >= -5.0 &&
          position.longitude <= 10.0) {
        return "Francia";
      }
      return "Europa";
    }

    // África
    if (position.latitude >= -35.0 &&
        position.latitude <= 38.0 &&
        position.longitude >= -26.0 &&
        position.longitude <= 60.0) {
      return "África";
    }

    // Asia
    if (position.latitude >= 10.0 &&
        position.latitude <= 75.0 &&
        position.longitude >= 25.0 &&
        position.longitude <= 180.0) {
      return "Asia";
    }

    // Oceanía
    if (position.latitude >= -50.0 &&
        position.latitude <= 0.0 &&
        position.longitude >= 110.0 &&
        position.longitude <= 180.0) {
      return "Australia";
    }

    return "Desconocido";
  }
}
