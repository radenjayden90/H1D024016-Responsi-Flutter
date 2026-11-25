import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_item.dart';
import '../widgets/state_views.dart';
import '../widgets/weather_details_grid.dart';
import 'search_screen.dart';

/// View utama aplikasi Skyora (View dalam arsitektur MVVM).
/// Menampilkan informasi cuaca terkini dan prakiraan 7 hari dari [WeatherViewModel],
/// tanpa memanggil service atau storage secara langsung.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openSearch(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final searchVm = context.watch<SearchViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Skyora',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (weatherVm.selectedLocation != null)
            IconButton(
              onPressed: weatherVm.state == WeatherLoadState.loading
                  ? null
                  : () => weatherVm.refresh(),
              tooltip: 'Muat ulang cuaca',
              icon: const Icon(Icons.refresh_rounded),
            ),
          IconButton(
            onPressed: () => _openSearch(context),
            tooltip: 'Cari kota',
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    colorScheme.primaryContainer.withValues(alpha: 0.35),
                    colorScheme.surface,
                  ]
                : [
                    const Color(0xFFE1F5FE),
                    const Color(0xFFF3FAFF),
                    colorScheme.surface,
                  ],
          ),
        ),
        child: SafeArea(
          child: _buildBody(context, weatherVm, searchVm),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel weatherVm,
    SearchViewModel searchVm,
  ) {
    switch (weatherVm.state) {
      case WeatherLoadState.initial:
      case WeatherLoadState.loading:
        return const LoadingStateView(
          message: 'Mengambil data cuaca terkini...',
        );

      case WeatherLoadState.empty:
        return EmptyStateView(
          icon: Icons.wb_sunny_rounded,
          title: 'Selamat Datang di Skyora',
          subtitle: 'Cari kota untuk melihat cuaca terkini dan prakiraan 7 hari.',
          actionLabel: 'Cari Kota',
          onAction: () => _openSearch(context),
        );

      case WeatherLoadState.error:
        return ErrorStateView(
          message: weatherVm.errorMessage ?? 'Gagal memuat data cuaca.',
          onRetry: () => weatherVm.refresh(),
        );

      case WeatherLoadState.success:
        final location = weatherVm.selectedLocation;
        final weather = weatherVm.weather;
        if (location == null || weather == null) {
          return EmptyStateView(
            icon: Icons.location_searching_rounded,
            title: 'Lokasi Belum Dipilih',
            subtitle: 'Cari kota untuk melihat cuaca.',
            actionLabel: 'Cari Kota',
            onAction: () => _openSearch(context),
          );
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isFav = searchVm.isFavorite(location);
        final updatedTime =
            '${weather.fetchedAt.hour.toString().padLeft(2, '0')}:${weather.fetchedAt.minute.toString().padLeft(2, '0')}';

        return RefreshIndicator(
          onRefresh: weatherVm.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              CurrentWeatherCard(
                location: location,
                current: weather.current,
                isFavorite: isFav,
                onToggleFavorite: () => searchVm.toggleFavorite(location),
              ),
              const SizedBox(height: 16),
              WeatherDetailsGrid(weather: weather),
              const SizedBox(height: 20),
              Text(
                'Prakiraan 7 Hari',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                color: colorScheme.surface.withValues(alpha: 0.88),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weather.daily.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                  itemBuilder: (context, index) {
                    return DailyForecastItem(
                      forecast: weather.daily[index],
                      isFirst: index == 0,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Data Open-Meteo • Diperbarui pukul $updatedTime',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
    }
  }
}
