import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/account_screen/theme_switch.dart';

import '../helpers/mock_providers.dart';

void main() {
  group('ThemeSwitch', () {
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockThemeProvider = MockThemeProvider();
      when(() => mockThemeProvider.isDarkMode).thenReturn(false);
    });

    Future<void> pumpThemeSwitch(
      WidgetTester tester, {
      ThemeSwitch? widget,
    }) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: mockThemeProvider,
          child: MaterialApp(
            home: Scaffold(body: widget ?? const ThemeSwitch()),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      await pumpThemeSwitch(tester);

      expect(find.byType(ThemeSwitch), findsOneWidget);
    });

    testWidgets('displays light mode icon (sun)', (tester) async {
      await pumpThemeSwitch(tester);

      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    });

    testWidgets('displays dark mode icon (moon)', (tester) async {
      await pumpThemeSwitch(tester);

      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    });

    testWidgets('uses default dimensions', (tester) async {
      const widget = ThemeSwitch();

      expect(widget.width, 60.0);
      expect(widget.height, 30.0);
      expect(widget.radius, 15.0);
    });

    testWidgets('accepts custom dimensions', (tester) async {
      const widget = ThemeSwitch(width: 80.0, height: 40.0, radius: 20.0);

      expect(widget.width, 80.0);
      expect(widget.height, 40.0);
      expect(widget.radius, 20.0);
    });

    testWidgets('calls toggleTheme when tapped', (tester) async {
      when(() => mockThemeProvider.toggleTheme()).thenReturn(null);

      await pumpThemeSwitch(tester);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      verify(() => mockThemeProvider.toggleTheme()).called(1);
    });

    testWidgets('contains AnimatedContainer', (tester) async {
      await pumpThemeSwitch(tester);

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('uses GestureDetector for tap', (tester) async {
      await pumpThemeSwitch(tester);

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('displays custom icons when provided', (tester) async {
      await pumpThemeSwitch(
        tester,
        widget: const ThemeSwitch(
          lightModeIcon: Icon(Icons.light_mode, key: Key('custom_light')),
          darkModeIcon: Icon(Icons.dark_mode, key: Key('custom_dark')),
        ),
      );

      expect(find.byKey(const Key('custom_light')), findsOneWidget);
      expect(find.byKey(const Key('custom_dark')), findsOneWidget);
    });
  });
}
