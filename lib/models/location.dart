/// Model data lokasi (Model dalam arsitektur MVVM).
/// Merepresentasikan kota/wilayah dari hasil pencarian Geocoding API
/// maupun data yang disimpan di penyimpanan lokal.
class Location {
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const Location({
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  /// Subjudul lokasi berupa provinsi/wilayah dan negara.
  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.trim().isNotEmpty) admin1!.trim(),
      if (country.trim().isNotEmpty) country.trim(),
    ];
    return parts.join(', ');
  }

  /// Nama lengkap lokasi untuk ditampilkan di header.
  String get fullName {
    final sub = subtitle;
    return sub.isNotEmpty ? '$name, $sub' : name;
  }

  /// Membuat objek Location dari JSON (Open-Meteo Geocoding API / local storage).
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: (json['name'] as String?)?.trim() ?? 'Tidak diketahui',
      country: (json['country'] as String?)?.trim() ?? '',
      admin1: (json['admin1'] as String?)?.trim(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Mengubah objek Location menjadi Map JSON untuk disimpan di SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Membandingkan lokasi berdasarkan koordinat (toleransi presisi) dan nama
  /// agar pengecekan favorit dan riwayat akurat.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.name == name &&
        (other.latitude - latitude).abs() < 0.0001 &&
        (other.longitude - longitude).abs() < 0.0001;
  }

  @override
  int get hashCode => Object.hash(
        name,
        latitude.toStringAsFixed(4),
        longitude.toStringAsFixed(4),
      );
}
