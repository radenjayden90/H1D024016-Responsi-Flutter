import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../services/geocoding_service.dart';
import '../services/storage_service.dart';

/// Status pencarian lokasi pada Search Screen.
enum SearchLoadState {
  initial,
  loading,
  success,
  empty,
  error,
}

/// ViewModel untuk Search / Location Screen (ViewModel dalam arsitektur MVVM).
/// Mengelola query pencarian kota, daftar hasil dari [GeocodingService],
/// serta daftar favorit dan riwayat pencarian di [StorageService].
class SearchViewModel extends ChangeNotifier {
  static const int maxHistoryItems = 10;

  final GeocodingService _geocodingService;
  final StorageService _storageService;

  String _query = '';
  List<Location> _results = [];
  List<Location> _favorites = [];
  List<Location> _history = [];
  SearchLoadState _state = SearchLoadState.initial;
  String? _errorMessage;

  SearchViewModel({
    required this._geocodingService,
    required this._storageService,
  });

  String get query => _query;
  List<Location> get results => List.unmodifiable(_results);
  List<Location> get favorites => List.unmodifiable(_favorites);
  List<Location> get history => List.unmodifiable(_history);
  SearchLoadState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Memuat daftar favorit dan riwayat pencarian dari local storage.
  Future<void> init() async {
    try {
      _favorites = await _storageService.getFavorites();
      _history = await _storageService.getHistory();
    } catch (_) {
      _favorites = [];
      _history = [];
    }
    notifyListeners();
  }

  /// Melakukan pencarian kota ke Geocoding API Open-Meteo.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    _query = trimmed;

    if (trimmed.isEmpty) {
      _results = [];
      _state = SearchLoadState.initial;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _state = SearchLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final locations = await _geocodingService.searchCity(trimmed);
      _results = locations;
      _state =
          locations.isEmpty ? SearchLoadState.empty : SearchLoadState.success;
    } on GeocodingServiceException catch (e) {
      _results = [];
      _errorMessage = e.message;
      _state = SearchLoadState.error;
    } catch (_) {
      _results = [];
      _errorMessage = 'Terjadi kesalahan saat mencari lokasi.';
      _state = SearchLoadState.error;
    }

    notifyListeners();
  }

  /// Mengosongkan query dan hasil pencarian sehingga kembali menampilkan
  /// daftar favorit dan riwayat pencarian.
  void clearSearch() {
    _query = '';
    _results = [];
    _state = SearchLoadState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  /// Mengecek apakah suatu lokasi sudah ditandai sebagai favorit.
  bool isFavorite(Location location) => _favorites.contains(location);

  /// Menambah atau menghapus lokasi dari daftar favorit dan menyimpannya.
  Future<void> toggleFavorite(Location location) async {
    final updated = List<Location>.from(_favorites);
    if (updated.contains(location)) {
      updated.remove(location);
    } else {
      updated.insert(0, location);
    }
    _favorites = updated;
    await _storageService.saveFavorites(_favorites);
    notifyListeners();
  }

  /// Menambahkan lokasi ke riwayat pencarian (maks 10, tanpa duplikat, terbaru di atas).
  Future<void> addToHistory(Location location) async {
    final updated = List<Location>.from(_history)
      ..remove(location)
      ..insert(0, location);
    if (updated.length > maxHistoryItems) {
      _history = updated.sublist(0, maxHistoryItems);
    } else {
      _history = updated;
    }
    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian dari memori dan storage.
  Future<void> clearHistory() async {
    _history = [];
    await _storageService.saveHistory(_history);
    notifyListeners();
  }
}
