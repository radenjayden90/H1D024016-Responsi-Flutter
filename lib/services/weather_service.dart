import 'dart:async';
import 'dart:io';

import 'package:open_meteo/open_meteo.dart';

import '../models/weather.dart';

/// Exception khusus untuk kesalahan pada layanan cuaca.
class WeatherServiceException implements Exception {
  final String message;
  const WeatherServiceException(this.message);

  @override
  String toString() => message;
}

/// Service untuk mengambil data prakiraan cuaca dari Open-Meteo
/// menggunakan package `open_meteo` (HTTP GET + FlatBuffers), lalu
/// mengonversinya ke model Dart milik aplikasi (`Weather`).
class WeatherService {
  final WeatherApi _weatherApi;

  WeatherService({WeatherApi? weatherApi})
      : _weatherApi = weatherApi ??
            const WeatherApi(
              userAgent: 'Skyora-Flutter-App',
              temperatureUnit: TemperatureUnit.celsius,
              windspeedUnit: WindspeedUnit.kmh,
              precipitationUnit: PrecipitationUnit.mm,
            );

  /// Mengambil data cuaca terkini dan prakiraan 7 hari berdasarkan koordinat.
  Future<Weather> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _weatherApi.request(
        locations: {
          OpenMeteoLocation(
            latitude: latitude,
            longitude: longitude,
          ),
        },
        current: {
          WeatherCurrent.temperature_2m,
          WeatherCurrent.relative_humidity_2m,
          WeatherCurrent.apparent_temperature,
          WeatherCurrent.precipitation,
          WeatherCurrent.weather_code,
          WeatherCurrent.wind_speed_10m,
        },
        daily: {
          WeatherDaily.weather_code,
          WeatherDaily.temperature_2m_max,
          WeatherDaily.temperature_2m_min,
          WeatherDaily.precipitation_probability_max,
        },
        forecastDays: 7,
      ).timeout(const Duration(seconds: 10));

      if (response.segments.isEmpty) {
        throw const WeatherServiceException(
          'Data cuaca tidak tersedia untuk lokasi ini.',
        );
      }

      final segment = response.segments.first;
      final currentData = segment.currentData;
      final dailyData = segment.dailyData;

      final tempValue = currentData[WeatherCurrent.temperature_2m];
      final humidityValue = currentData[WeatherCurrent.relative_humidity_2m];
      final apparentValue = currentData[WeatherCurrent.apparent_temperature];
      final precipValue = currentData[WeatherCurrent.precipitation];
      final codeValue = currentData[WeatherCurrent.weather_code];
      final windValue = currentData[WeatherCurrent.wind_speed_10m];

      if (tempValue == null ||
          humidityValue == null ||
          apparentValue == null ||
          precipValue == null ||
          codeValue == null ||
          windValue == null) {
        throw const WeatherServiceException(
          'Data cuaca terkini dari server tidak lengkap.',
        );
      }

      final current = CurrentWeather(
        temperature: tempValue.value,
        apparentTemperature: apparentValue.value,
        humidity: humidityValue.value.round(),
        precipitation: precipValue.value,
        weatherCode: codeValue.value.round(),
        windSpeed: windValue.value,
        time: tempValue.time,
      );

      final dailyCodes = dailyData[WeatherDaily.weather_code]?.values ?? {};
      final dailyMax =
          dailyData[WeatherDaily.temperature_2m_max]?.values ?? {};
      final dailyMin =
          dailyData[WeatherDaily.temperature_2m_min]?.values ?? {};
      final dailyRainProb =
          dailyData[WeatherDaily.precipitation_probability_max]?.values ?? {};

      final dates = dailyMax.keys.toList()..sort();
      final dailyList = <DailyForecast>[];
      for (final date in dates) {
        final maxVal = dailyMax[date];
        final minVal = dailyMin[date];
        final codeVal = dailyCodes[date];
        final rainProbVal = dailyRainProb[date];

        if (maxVal == null || minVal == null || codeVal == null) continue;

        dailyList.add(
          DailyForecast(
            date: date,
            weatherCode: codeVal.round(),
            tempMax: maxVal.toDouble(),
            tempMin: minVal.toDouble(),
            precipitationProbabilityMax: rainProbVal?.round() ?? 0,
          ),
        );
      }

      return Weather(
        current: current,
        daily: dailyList,
        fetchedAt: DateTime.now(),
      );
    } on WeatherServiceException {
      rethrow;
    } on SocketException {
      throw const WeatherServiceException(
        'Tidak dapat terhubung ke internet. Periksa koneksi Anda.',
      );
    } on TimeoutException {
      throw const WeatherServiceException(
        'Koneksi ke server cuaca habis waktu. Silakan coba lagi.',
      );
    } on OpenMeteoApiError catch (e) {
      throw WeatherServiceException(
        'Server Open-Meteo mengembalikan kesalahan: ${e.reason}',
      );
    } on FormatException {
      throw const WeatherServiceException(
        'Format respons cuaca dari server tidak valid.',
      );
    } catch (_) {
      throw const WeatherServiceException(
        'Terjadi kesalahan saat mengambil data cuaca.',
      );
    }
  }
}
