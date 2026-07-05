import 'package:flutter_test/flutter_test.dart';
import 'package:splitnova/app/data/models/history_model.dart';

// We extract the logic to a testable pure function or similar for testing
// Since it's in HistoryController, we can simulate its inputs

List<String> findCommonPeople(List<HistoryItem> items) {
  if (items.isEmpty) return [];
  
  Map<String, int> counts = {};
  for (var item in items) {
    if (item.peopleList == null) continue;
    final names = item.peopleList!.map((p) => p.name.trim().toLowerCase()).toSet();
    for (var name in names) {
      counts[name] = (counts[name] ?? 0) + 1;
    }
  }

  return counts.entries
      .where((e) => e.value == items.length)
      .map((e) => e.key)
      .toList();
}

void main() {
  group('Suggestion Logic Tests', () {
    test('Common people detection', () {
      final items = [
        HistoryItem(
          id: '1', bill: 10, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 2, currency: 'USD', 
          date: DateTime.now(), isCustomSplit: true, 
          peopleList: [PersonSplit(name: 'Alice', percentage: 50), PersonSplit(name: 'Bob', percentage: 50)],
          totalPerPerson: 5
        ),
        HistoryItem(
          id: '2', bill: 10, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 2, currency: 'USD', 
          date: DateTime.now(), isCustomSplit: true, 
          peopleList: [PersonSplit(name: ' Alice', percentage: 50), PersonSplit(name: 'Bob', percentage: 50)],
          totalPerPerson: 5
        ),
        HistoryItem(
          id: '3', bill: 10, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 2, currency: 'USD', 
          date: DateTime.now(), isCustomSplit: true, 
          peopleList: [PersonSplit(name: 'alice', percentage: 50), PersonSplit(name: 'Charlie', percentage: 50)],
          totalPerPerson: 5
        ),
      ];

      final common = findCommonPeople(items);
      expect(common.length, 1);
      expect(common[0], 'alice');
    });

    test('Window detection (Logic simulation)', () {
      final now = DateTime.now();
      final items = [
        HistoryItem(id: '1', date: now, bill: 0, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 0, currency: '', totalPerPerson: 0, isCustomSplit: false),
        HistoryItem(id: '2', date: now.add(Duration(hours: 24)), bill: 0, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 0, currency: '', totalPerPerson: 0, isCustomSplit: false),
        HistoryItem(id: '3', date: now.add(Duration(hours: 71)), bill: 0, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 0, currency: '', totalPerPerson: 0, isCustomSplit: false),
      ];

      final diff = items.last.date.difference(items.first.date).inHours;
      expect(diff <= 72, true);

      final items2 = [
        HistoryItem(id: '1', date: now, bill: 0, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 0, currency: '', totalPerPerson: 0, isCustomSplit: false),
        HistoryItem(id: '2', date: now.add(Duration(hours: 24)), bill: 0, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 0, currency: '', totalPerPerson: 0, isCustomSplit: false),
        HistoryItem(id: '3', date: now.add(Duration(hours: 73)), bill: 0, tipAmount: 0, tipPercent: 0, isFixedTip: true, people: 0, currency: '', totalPerPerson: 0, isCustomSplit: false),
      ];
      final diff2 = items2.last.date.difference(items2.first.date).inHours;
      expect(diff2 <= 72, false);
    });
  });
}
