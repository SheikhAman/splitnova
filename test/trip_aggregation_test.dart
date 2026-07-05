import 'package:flutter_test/flutter_test.dart';
import 'package:splitnova/app/data/models/history_model.dart';
import 'package:splitnova/app/data/services/trip_aggregation_service.dart';

void main() {
  group('TripAggregationService Tests', () {
    test('Aggregate single currency trip correctly', () {
      final items = [
        HistoryItem(
          id: '1',
          bill: 100.0,
          tipAmount: 10.0,
          tipPercent: 10,
          isFixedTip: false,
          people: 2,
          currency: 'USD',
          date: DateTime(2023, 1, 1),
          isCustomSplit: true,
          peopleList: [
            PersonSplit(name: 'Alice', percentage: 60),
            PersonSplit(name: 'Bob', percentage: 40),
          ],
          totalPerPerson: 55.0,
        ),
        HistoryItem(
          id: '2',
          bill: 200.0,
          tipAmount: 20.0,
          tipPercent: 10,
          isFixedTip: false,
          people: 2,
          currency: 'USD',
          date: DateTime(2023, 1, 2),
          isCustomSplit: true,
          peopleList: [
            PersonSplit(name: 'Alice', percentage: 50),
            PersonSplit(name: 'Bob', percentage: 50),
          ],
          totalPerPerson: 110.0,
        ),
      ];

      final result = TripAggregationService.aggregate(items);

      expect(result.grandTotals['USD'], 330.0);
      expect(result.hasMixedCurrencies, false);
      
      final alice = result.perPersonTotals['USD']!.firstWhere((p) => p.displayName == 'Alice');
      final bob = result.perPersonTotals['USD']!.firstWhere((p) => p.displayName == 'Bob');

      // Alice: (110 * 0.6) + (220 * 0.5) = 66 + 110 = 176
      // Bob: (110 * 0.4) + (220 * 0.5) = 44 + 110 = 154
      expect(alice.totalAmount, 176.0);
      expect(bob.totalAmount, 154.0);
    });

    test('Aggregate mixed currency trip correctly', () {
      final items = [
        HistoryItem(
          id: '1',
          bill: 100.0,
          tipAmount: 0,
          tipPercent: 0,
          isFixedTip: true,
          people: 1,
          currency: 'USD',
          date: DateTime(2023, 1, 1),
          isCustomSplit: true,
          peopleList: [PersonSplit(name: 'Alice', percentage: 100)],
          totalPerPerson: 100.0,
        ),
        HistoryItem(
          id: '2',
          bill: 1000.0,
          tipAmount: 0,
          tipPercent: 0,
          isFixedTip: true,
          people: 1,
          currency: 'INR',
          date: DateTime(2023, 1, 2),
          isCustomSplit: true,
          peopleList: [PersonSplit(name: 'Alice', percentage: 100)],
          totalPerPerson: 1000.0,
        ),
      ];

      final result = TripAggregationService.aggregate(items);

      expect(result.hasMixedCurrencies, true);
      expect(result.grandTotals['USD'], 100.0);
      expect(result.grandTotals['INR'], 1000.0);
      expect(result.perPersonTotals['USD']![0].totalAmount, 100.0);
      expect(result.perPersonTotals['INR']![0].totalAmount, 1000.0);
    });

    test('Normalize names correctly', () {
       final items = [
        HistoryItem(
          id: '1',
          bill: 100.0,
          tipAmount: 0,
          tipPercent: 0,
          isFixedTip: true,
          people: 1,
          currency: 'USD',
          date: DateTime(2023, 1, 1),
          isCustomSplit: true,
          peopleList: [PersonSplit(name: 'Partho', percentage: 100)],
          totalPerPerson: 100.0,
        ),
        HistoryItem(
          id: '2',
          bill: 100.0,
          tipAmount: 0,
          tipPercent: 0,
          isFixedTip: true,
          people: 1,
          currency: 'USD',
          date: DateTime(2023, 1, 2),
          isCustomSplit: true,
          peopleList: [PersonSplit(name: 'partho ', percentage: 100)],
          totalPerPerson: 100.0,
        ),
      ];

      final result = TripAggregationService.aggregate(items);
      expect(result.perPersonTotals['USD']!.length, 1);
      expect(result.perPersonTotals['USD']![0].displayName, 'Partho');
      expect(result.perPersonTotals['USD']![0].totalAmount, 200.0);
    });
  });
}
