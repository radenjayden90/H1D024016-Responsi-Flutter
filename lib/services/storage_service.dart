import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';

/// Service penyimpanan lokal menggunakan `shared_preferences`.
/// Menyimpan daftar lokasi favorit, riwayat pencarian (maks 10),
/// dan lokasi terakhir yang dipilih agar tetap ada saat aplikasi dibuka ulang.
class StorageService {
  static const String _favoritesKey = 'skyora_favorites';
  static const String _historyKey = 'skyora_history';
  static const String _lastLocationKey = 'skyora_last_location';

  SharedPreferences? _prefs;

  /// Menginisialisasi instance SharedPreferences.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// Membaca daftar lokasi favorit dari penyimpanan lokal.
  Future<List<Location>> getFavorites() async {
    try {
      final prefs = await _ensurePrefs();
      final rawList = prefs.getStringList(_favoritesKey) ?? [];
      return _decodeLocationList(rawList);
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan daftar lokasi favorit ke penyimpanan lokal.
  Future<void> saveFavorites(List<Location> favorites) async {
    final prefs = await _ensurePrefs();
    final encoded = favorites.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  /// Membaca riwayat pencarian kota dari penyimpanan lokal.
  Future<List<Location>> getHistory() async {
    try {
      final prefs = await _ensurePrefs();
      final rawList = prefs.getStringList(_historyKey) ?? [];
      return _decodeLocationList(rawList);
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan riwayat pencarian kota ke penyimpanan lokal.
  Future<void> saveHistory(List<Location> history) async {
    final prefs = await _ensurePrefs();
    final encoded = history.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  /// Membaca lokasi terakhir yang dipilih pengguna.
  Future<Location?> getLastLocation() async {
    try {
      final prefs = await _ensurePrefs();
      final raw = prefs.getString(_lastLocationKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return Location.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan lokasi terakhir yang dipilih pengguna.
  Future<void> saveLastLocation(Location? location) async {
    final prefs = await _ensurePrefs();
    if (location == null) {
      await prefs.remove(_lastLocationKey);
      return;
    }
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  List<Location> _decodeLocationList(List<String> rawList) {
    final result = <Location>[];
    for (final item in rawList) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          result.add(Location.fromJson(decoded));
        }
      } catch (_) {
        // Abaikan item yang rusak agar tidak mengganggu data lain.
      }
    }
    return result;
  }
}
