import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/auth/custom_social_button.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('CustomSocialButton', () {
    late MockVoidCallback mockOnTap;

    setUp(() {
      mockOnTap = MockVoidCallback();
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        CustomSocialButton(
          onTap: mockOnTap.call,
          text: 'Continue with Google',
          icon: 'assets/icons/google.svg',
        ),
      );

      expect(find.byType(CustomSocialButton), findsOneWidget);
    });

    testWidgets('displays text', (tester) async {
      await tester.pumpAppWithScaffold(
        CustomSocialButton(
          onTap: mockOnTap.call,
          text: 'Continue with Apple',
          icon: 'assets/icons/apple.svg',
        ),
      );

      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('contains SvgPicture for icon', (tester) async {
      await tester.pumpAppWithScaffold(
        CustomSocialButton(
          onTap: mockOnTap.call,
          text: 'Sign in',
          icon: 'assets/icons/test.svg',
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('uses Row for layout', (tester) async {
      await tester.pumpAppWithScaffold(
        CustomSocialButton(
          onTap: mockOnTap.call,
          text: 'Sign in',
          icon: 'assets/icons/test.svg',
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('has Padding wrapper', (tester) async {
      await tester.pumpAppWithScaffold(
        CustomSocialButton(
          onTap: mockOnTap.call,
          text: 'Sign in',
          icon: 'assets/icons/test.svg',
        ),
      );

      final outerPadding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(Container).first,
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(outerPadding.padding, const EdgeInsets.symmetric(horizontal: 25));
    });

    testWidgets('uses default margin when not specified', (tester) async {
      final widget = CustomSocialButton(
        onTap: () {},
        text: 'Test',
        icon: 'test.svg',
      );

      expect(widget.margin, isNull);
    });

    testWidgets('accepts custom margin', (tester) async {
      final widget = CustomSocialButton(
        onTap: () {},
        text: 'Test',
        icon: 'test.svg',
        margin: 10.0,
      );

      expect(widget.margin, 10.0);
    });
  });
}
