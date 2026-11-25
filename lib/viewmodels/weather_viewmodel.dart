import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../models/weather.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// Status pemuatan data cuaca pada Home Screen.
enum WeatherLoadState {
  initial,
  loading,
  success,
  empty,
  error,
}

/// ViewModel untuk Home / Weather Screen (ViewModel dalam arsitektur MVVM).
/// Mengelola lokasi terpilih, data cuaca dari [WeatherService],
/// serta penyimpanan lokasi terakhir di [StorageService].
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  Location? _selectedLocation;
  Weather? _weather;
  WeatherLoadState _state = WeatherLoadState.initial;
  String? _errorMessage;

  WeatherViewModel({
    required this._weatherService,
    required this._storageService,
  });

  Location? get selectedLocation => _selectedLocation;
  Weather? get weather => _weather;
  WeatherLoadState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Menginisialisasi layar utama dengan memuat lokasi terakhir dari storage,
  /// atau favorit pertama jika lokasi terakhir belum ada.
  Future<void> init() async {
    try {
      Location? location = await _storageService.getLastLocation();
      if (location == null) {
        final favorites = await _storageService.getFavorites();
        if (favorites.isNotEmpty) {
          location = favorites.first;
        }
      }

      if (location == null) {
        _state = WeatherLoadState.empty;
        notifyListeners();
        return;
      }

      _selectedLocation = location;
      await fetchWeather();
    } catch (_) {
      _state = WeatherLoadState.empty;
      notifyListeners();
    }
  }

  /// Memilih lokasi baru, menyimpannya ke local storage, lalu mengambil cuacanya.
  Future<void> selectLocation(Location location) async {
    _selectedLocation = location;
    await _storageService.saveLastLocation(location);
    await fetchWeather();
  }

  /// Mengambil data cuaca terkini dan prakiraan 7 hari dari Open-Meteo.
  Future<void> fetchWeather() async {
    final location = _selectedLocation;
    if (location == null) {
      _state = WeatherLoadState.empty;
      notifyListeners();
      return;
    }

    _state = WeatherLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _weather = result;
      _state = WeatherLoadState.success;
    } on WeatherServiceException catch (e) {
      _errorMessage = e.message;
      _state = WeatherLoadState.error;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat memuat data cuaca.';
      _state = WeatherLoadState.error;
    }

    notifyListeners();
  }

  /// Memuat ulang data cuaca (digunakan oleh RefreshIndicator dan tombol refresh).
  Future<void> refresh() => fetchWeather();
}
