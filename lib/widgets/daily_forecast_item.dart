import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../utils/weather_code.dart';

/// Item baris prakiraan cuaca harian (untuk daftar 7 hari ke depan).
class DailyForecastItem extends StatelessWidget {
  final DailyForecast forecast;
  final bool isFirst;

  const DailyForecastItem({
    super.key,
    required this.forecast,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final info = mapWeatherCode(forecast.weatherCode);
    final dayLabel = formatIndonesianForecastDay(
      forecast.date,
      isFirst: isFirst,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  info.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Tooltip(
            message: info.description,
            child: Icon(
              info.icon,
              size: 26,
              color: info.color,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 14,
                  color: colorScheme.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 2),
                Text(
                  '${forecast.precipitationProbabilityMax}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 78,
            child: Text(
              '${forecast.tempMin.round()}° / ${forecast.tempMax.round()}°',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
