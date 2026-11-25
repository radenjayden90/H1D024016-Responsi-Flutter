import 'package:flutter_test/flutter_test.dart';

import 'package:skyora/main.dart';
import 'package:skyora/services/geocoding_service.dart';
import 'package:skyora/services/storage_service.dart';
import 'package:skyora/services/weather_service.dart';

void main() {
  testWidgets('Skyora app renders home screen title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      SkyoraApp(
        storageService: StorageService(),
        weatherService: WeatherService(),
        geocodingService: GeocodingService(),
      ),
    );

    expect(find.text('Skyora'), findsOneWidget);
  });
}
