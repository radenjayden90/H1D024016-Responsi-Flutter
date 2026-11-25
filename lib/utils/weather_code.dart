import 'package:flutter/material.dart';

/// Informasi tampilan cuaca hasil pemetaan kode WMO Open-Meteo.
class WeatherCodeInfo {
  final String description;
  final IconData icon;
  final Color color;

  const WeatherCodeInfo({
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Memetakan kode cuaca WMO (World Meteorological Organization)
/// menjadi deskripsi bahasa Indonesia dan ikon Material yang sesuai.
WeatherCodeInfo mapWeatherCode(int code) {
  switch (code) {
    case 0:
      return const WeatherCodeInfo(
        description: 'Cerah',
        icon: Icons.wb_sunny_rounded,
        color: Color(0xFFFFB300),
      );
    case 1:
      return const WeatherCodeInfo(
        description: 'Sebagian Besar Cerah',
        icon: Icons.wb_sunny_outlined,
        color: Color(0xFFFFC107),
      );
    case 2:
      return const WeatherCodeInfo(
        description: 'Berawan Sebagian',
        icon: Icons.wb_cloudy_rounded,
        color: Color(0xFF4FC3F7),
      );
    case 3:
      return const WeatherCodeInfo(
        description: 'Mendung',
        icon: Icons.cloud_rounded,
        color: Color(0xFF78909C),
      );
    case 45:
    case 48:
      return const WeatherCodeInfo(
        description: 'Berkabut',
        icon: Icons.foggy,
        color: Color(0xFF90A4AE),
      );
    case 51:
      return const WeatherCodeInfo(
        description: 'Gerimis Ringan',
        icon: Icons.grain_rounded,
        color: Color(0xFF29B6F6),
      );
    case 53:
      return const WeatherCodeInfo(
        description: 'Gerimis Sedang',
        icon: Icons.grain_rounded,
        color: Color(0xFF039BE5),
      );
    case 55:
      return const WeatherCodeInfo(
        description: 'Gerimis Lebat',
        icon: Icons.grain_rounded,
        color: Color(0xFF0277BD),
      );
    case 56:
    case 57:
      return const WeatherCodeInfo(
        description: 'Gerimis Beku',
        icon: Icons.ac_unit_rounded,
        color: Color(0xFF4DD0E1),
      );
    case 61:
      return const WeatherCodeInfo(
        description: 'Hujan Ringan',
        icon: Icons.umbrella_rounded,
        color: Color(0xFF29B6F6),
      );
    case 63:
      return const WeatherCodeInfo(
        description: 'Hujan Sedang',
        icon: Icons.water_drop_rounded,
        color: Color(0xFF0288D1),
      );
    case 65:
      return const WeatherCodeInfo(
        description: 'Hujan Lebat',
        icon: Icons.water_drop_rounded,
        color: Color(0xFF01579B),
      );
    case 66:
    case 67:
      return const WeatherCodeInfo(
        description: 'Hujan Beku',
        icon: Icons.ac_unit_rounded,
        color: Color(0xFF26C6DA),
      );
    case 71:
    case 73:
    case 75:
    case 77:
      return const WeatherCodeInfo(
        description: 'Turun Salju',
        icon: Icons.ac_unit_rounded,
        color: Color(0xFF80DEEA),
      );
    case 80:
      return const WeatherCodeInfo(
        description: 'Hujan Lokal Ringan',
        icon: Icons.beach_access_rounded,
        color: Color(0xFF29B6F6),
      );
    case 81:
      return const WeatherCodeInfo(
        description: 'Hujan Lokal Sedang',
        icon: Icons.umbrella_rounded,
        color: Color(0xFF0288D1),
      );
    case 82:
      return const WeatherCodeInfo(
        description: 'Hujan Lokal Deras',
        icon: Icons.thunderstorm_rounded,
        color: Color(0xFF01579B),
      );
    case 85:
    case 86:
      return const WeatherCodeInfo(
        description: 'Hujan Salju',
        icon: Icons.ac_unit_rounded,
        color: Color(0xFF80DEEA),
      );
    case 95:
      return const WeatherCodeInfo(
        description: 'Badai Petir',
        icon: Icons.thunderstorm_rounded,
        color: Color(0xFF5C6BC0),
      );
    case 96:
    case 99:
      return const WeatherCodeInfo(
        description: 'Badai Petir & Hujan Es',
        icon: Icons.thunderstorm_rounded,
        color: Color(0xFF3949AB),
      );
    default:
      return const WeatherCodeInfo(
        description: 'Cuaca Tidak Diketahui',
        icon: Icons.cloud_queue_rounded,
        color: Color(0xFF78909C),
      );
  }
}

const List<String> _hariPendek = [
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

const List<String> _bulanPendek = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Memformat tanggal menjadi label hari bahasa Indonesia (contoh: "Hari Ini", "Besok", "Kam, 27 Nov").
String formatIndonesianForecastDay(DateTime date, {bool isFirst = false}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;

  if (isFirst || diff == 0) {
    return 'Hari Ini';
  }
  if (diff == 1) {
    return 'Besok';
  }
  final dayName = _hariPendek[date.weekday - 1];
  final monthName = _bulanPendek[date.month - 1];
  return '$dayName, ${date.day} $monthName';
}
