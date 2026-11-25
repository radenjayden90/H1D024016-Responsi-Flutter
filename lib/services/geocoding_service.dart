import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location.dart';

/// Exception khusus untuk kesalahan pada layanan pencarian lokasi.
class GeocodingServiceException implements Exception {
  final String message;
  const GeocodingServiceException(this.message);

  @override
  String toString() => message;
}

/// Service untuk mencari lokasi berdasarkan nama kota menggunakan
/// Open-Meteo Geocoding API (HTTP GET + JSON decoding ke model `Location`).
class GeocodingService {
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Mencari daftar kota yang cocok dengan [query].
  /// Mengembalikan list kosong jika tidak ada hasil (`results` tidak ditemukan).
  Future<List<Location>> searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': trimmed,
        'count': '10',
        'language': 'id',
      },
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw GeocodingServiceException(
          'Gagal mencari kota (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const GeocodingServiceException(
          'Format respons pencarian tidak valid.',
        );
      }

      if (decoded['error'] == true) {
        final reason = decoded['reason'] as String? ?? 'Permintaan tidak valid.';
        throw GeocodingServiceException(reason);
      }

      final results = decoded['results'];
      if (results == null) {
        return [];
      }
      if (results is! List) {
        throw const GeocodingServiceException(
          'Format daftar lokasi tidak valid.',
        );
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(Location.fromJson)
          .toList();
    } on GeocodingServiceException {
      rethrow;
    } on SocketException {
      throw const GeocodingServiceException(
        'Tidak dapat terhubung ke internet. Periksa koneksi Anda.',
      );
    } on TimeoutException {
      throw const GeocodingServiceException(
        'Pencarian kota habis waktu. Silakan coba lagi.',
      );
    } on FormatException {
      throw const GeocodingServiceException(
        'Gagal membaca respons JSON dari server.',
      );
    } catch (_) {
      throw const GeocodingServiceException(
        'Terjadi kesalahan saat mencari lokasi.',
      );
    }
  }
}
