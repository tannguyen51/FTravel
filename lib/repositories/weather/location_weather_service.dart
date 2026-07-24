import 'package:location/location.dart';
import 'weather_repo.dart';

/// Service để lấy vị trí người dùng và thời tiết hiện tại
class LocationWeatherService {
  final Location _location = Location();

  /// Lấy vị trí hiện tại của người dùng
  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Kiểm tra dịch vụ vị trí có được bật không
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Kiểm tra quyền truy cập vị trí
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Lấy vị trí hiện tại
    return await _location.getLocation();
  }

  /// Lấy thông tin thời tiết tại vị trí hiện tại
  Future<Map<String, dynamic>?> getCurrentWeather() async {
    try {
      final location = await getCurrentLocation();
      if (location == null) {
        return null;
      }

      final repo = weatherRepo(
        lat: location.latitude ?? 0.0,
        lng: location.longitude ?? 0.0,
      );

      return await repo.findWeather();
    } catch (e) {
      print('Error getting current weather: $e');
      return null;
    }
  }
}
