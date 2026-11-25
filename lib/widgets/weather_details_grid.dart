import 'package:flutter/material.dart';

import '../models/weather.dart';

/// Grid responsif untuk menampilkan informasi tambahan cuaca terkini:
/// kelembapan udara, kecepatan angin, curah hujan, dan kemungkinan hujan.
class WeatherDetailsGrid extends StatelessWidget {
  final Weather weather;

  const WeatherDetailsGrid({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;

    final items = [
      _DetailItemData(
        icon: Icons.water_drop_outlined,
        label: 'Kelembapan',
        value: '${current.humidity}%',
      ),
      _DetailItemData(
        icon: Icons.air_rounded,
        label: 'Kecepatan Angin',
        value: '${current.windSpeed.toStringAsFixed(1)} km/h',
      ),
      _DetailItemData(
        icon: Icons.grain_rounded,
        label: 'Curah Hujan',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
      ),
      _DetailItemData(
        icon: Icons.umbrella_rounded,
        label: 'Peluang Hujan',
        value: '${weather.todayPrecipitationProbability}%',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        const spacing = 12.0;
        final columns = isWide ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _DetailTile(data: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DetailItemData {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItemData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _DetailTile extends StatelessWidget {
  final _DetailItemData data;

  const _DetailTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
