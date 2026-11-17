import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_island_bar/android_island_bar.dart';

void main() {
  group('IslandItem Live Activity Presets', () {
    testWidgets(
        'IslandItem.rideHailing creates valid compact and expanded widgets',
        (tester) async {
      bool called = false;
      final item = IslandItem.rideHailing(
        driverName: 'Rajesh K.',
        vehicleName: 'White Dzire',
        licensePlate: 'MH 02 DE 4421',
        etaText: '3 mins',
        otpCode: '4921',
        onCallDriver: () => called = true,
      );

      expect(item.id, equals('ride_hailing'));
      expect(item.priority, equals(12));
      expect(item.subtitle, contains('OTP 4921'));

      // Test expanded builder
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return item.expandedBuilder!(
                  context,
                  item,
                  const IslandTheme(),
                  () {},
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Rajesh K. • ★ 4.9'), findsOneWidget);
      expect(find.text('White Dzire • MH 02 DE 4421'), findsOneWidget);
      expect(find.text('4921'), findsOneWidget);
      expect(find.text('Arriving in 3 mins'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);

      await tester.tap(find.text('Call'));
      expect(called, isTrue);
    });

    testWidgets(
        'IslandItem.foodDelivery creates valid compact and expanded widgets',
        (tester) async {
      final item = IslandItem.foodDelivery(
        restaurantName: 'Truffles',
        orderStatus: 'Out for delivery',
        etaText: '14 mins',
        itemSummary: '2 items',
        driverName: 'Vikram',
      );

      expect(item.id, equals('food_delivery'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return item.expandedBuilder!(
                  context,
                  item,
                  const IslandTheme(),
                  () {},
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Truffles'), findsOneWidget);
      expect(find.text('2 items • Out for delivery'), findsOneWidget);
      expect(find.text('Partner: Vikram'), findsOneWidget);
      expect(find.text('14 mins'), findsOneWidget);
    });
  });
}
