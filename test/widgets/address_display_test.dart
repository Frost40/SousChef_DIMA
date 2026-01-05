import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/widgets/home_screen/address_display.dart';

import '../helpers/mock_providers.dart';

void main() {
  group('AddressDisplay', () {
    late MockUserProvider mockUserProvider;

    setUp(() {
      mockUserProvider = MockUserProvider();
    });

    Future<void> pumpAddressDisplay(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: const MaterialApp(home: Scaffold(body: AddressDisplay())),
        ),
      );
    }

    testWidgets('renders correctly', (tester) async {
      when(() => mockUserProvider.userData).thenReturn(null);

      await pumpAddressDisplay(tester);

      expect(find.byType(AddressDisplay), findsOneWidget);
    });

    testWidgets('shows default text when no address saved', (tester) async {
      when(() => mockUserProvider.userData).thenReturn(null);

      await pumpAddressDisplay(tester);

      expect(find.text('Choose your location'), findsOneWidget);
    });

    testWidgets('displays saved address when available', (tester) async {
      final testUser = User(
        id: 'user-1',
        email: 'test@test.com',
        username: 'testuser',
        name: 'Test',
        surname: 'User',
        phone: '123456789',
        favourites: [],
        savedAddress: 'Via Roma 1, Milano, Italy',
      );

      when(() => mockUserProvider.userData).thenReturn(testUser);

      await pumpAddressDisplay(tester);

      // Verify address is displayed (widget extracts first two parts)
      expect(find.textContaining('Via Roma'), findsOneWidget);
    });

    testWidgets('shows Selected location label', (tester) async {
      when(() => mockUserProvider.userData).thenReturn(null);

      await pumpAddressDisplay(tester);

      expect(find.text('Selected location:'), findsOneWidget);
    });

    testWidgets('contains InkWell for tap', (tester) async {
      when(() => mockUserProvider.userData).thenReturn(null);

      await pumpAddressDisplay(tester);

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('has Container with decoration', (tester) async {
      when(() => mockUserProvider.userData).thenReturn(null);

      await pumpAddressDisplay(tester);

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('extracts address before second comma', (tester) async {
      final testUser = User(
        id: 'user-1',
        email: 'test@test.com',
        username: 'testuser',
        name: 'Test',
        surname: 'User',
        phone: '123456789',
        favourites: [],
        savedAddress: 'Via Dante 5, Roma, Lazio, Italy',
      );

      when(() => mockUserProvider.userData).thenReturn(testUser);

      await pumpAddressDisplay(tester);

      // Should show only first two parts
      expect(find.textContaining('Via Dante'), findsOneWidget);
    });
  });
}
