/// Model cuaca terkini (Model dalam arsitektur MVVM).
/// Menyimpan data cuaca saat ini yang sudah dikonversi dari Open-Meteo.
class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final DateTime? time;

  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    this.time,
  });
}

/// Model perkiraan cuaca harian (Model dalam arsitektur MVVM).
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbabilityMax,
  });
}

/// Model gabungan cuaca terkini dan perkiraan harian untuk 7 hari.
class Weather {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  const Weather({
    required this.current,
    required this.daily,
    required this.fetchedAt,
  });

  /// Mengambil peluang hujan hari ini dari data daily indeks pertama,
  /// karena Open-Meteo `current` tidak menyediakan peluang hujan.
  int get todayPrecipitationProbability =>
      daily.isNotEmpty ? daily.first.precipitationProbabilityMax : 0;
}
