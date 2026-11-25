import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/geocoding_service.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

/// Entry point aplikasi Skyora.
/// Menginisialisasi local storage, mendaftarkan Provider (MVVM),
/// dan mengonfigurasi tema Material Design 3 bernuansa biru langit.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  try {
    await storageService.init();
  } catch (_) {
    // Penanganan fallback: tetap jalankan aplikasi meski storage gagal diinisialisasi.
  }

  runApp(
    SkyoraApp(
      storageService: storageService,
      weatherService: WeatherService(),
      geocodingService: GeocodingService(),
    ),
  );
}

class SkyoraApp extends StatelessWidget {
  final StorageService storageService;
  final WeatherService weatherService;
  final GeocodingService geocodingService;

  const SkyoraApp({
    super.key,
    required this.storageService,
    required this.weatherService,
    required this.geocodingService,
  });

  static const Color _skyBlueSeed = Color(0xFF4FC3F7);

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _skyBlueSeed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(fontSize: 15),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            weatherService: weatherService,
            storageService: storageService,
          )..init(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            geocodingService: geocodingService,
            storageService: storageService,
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Skyora',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const HomeScreen(),
      ),
    );
  }
}
