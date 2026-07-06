import '../models/history_model.dart';

class TripAggregationResult {
  final Map<String, double> grandTotals;
  final Map<String, List<PersonAggregation>> perPersonTotals;
  final bool hasMixedCurrencies;
  final DateTime? earliestDate;
  final DateTime? latestDate;

  TripAggregationResult({
    required this.grandTotals,
    required this.perPersonTotals,
    required this.hasMixedCurrencies,
    this.earliestDate,
    this.latestDate,
  });
}

class PersonAggregation {
  final String displayName;
  final double totalAmount;
  final double sharePercentage;
  final String currency;

  PersonAggregation({
    required this.displayName,
    required this.totalAmount,
    required this.sharePercentage,
    required this.currency,
  });
}

class TripAggregationService {
  static TripAggregationResult aggregate(List<HistoryItem> items) {
    if (items.isEmpty) {
      return TripAggregationResult(
        grandTotals: {},
        perPersonTotals: {},
        hasMixedCurrencies: false,
      );
    }

    final Map<String, double> grandTotals = {};
    // Map<Currency, Map<NormalizedName, {CanonicalName, Total}>>
    final Map<String, Map<String, _PersonAccumulator>> personMap = {};
    final Set<String> currencies = {};
    DateTime? earliest;
    DateTime? latest;

    for (var item in items) {
      final currency = item.currency;
      currencies.add(currency);
      
      final totalBill = item.bill + item.tipAmount;
      grandTotals[currency] = (grandTotals[currency] ?? 0) + totalBill;

      if (earliest == null || item.date.isBefore(earliest)) earliest = item.date;
      if (latest == null || item.date.isAfter(latest)) latest = item.date;

      personMap.putIfAbsent(currency, () => {});

      if (item.isCustomSplit && item.peopleList != null) {
        for (var p in item.peopleList!) {
          final normalized = p.name.trim().toLowerCase();
          final personTotal = totalBill * (p.percentage / 100);
          
          if (!personMap[currency]!.containsKey(normalized)) {
            personMap[currency]![normalized] = _PersonAccumulator(p.name.trim(), 0);
          }
          personMap[currency]![normalized]!.total += personTotal;
        }
      } else {
        // Equal split logic: If no names, use "Anonymous" or similar.
        // However, if we want to support professional reporting, we should try to associate 
        // these amounts with a generic "Participant" bucket if specific names aren't provided.
        final personTotal = totalBill / item.people;
        final name = "Participant";
        final normalized = name.toLowerCase();

        for (int i = 0; i < item.people; i++) {
           final key = "$normalized-${i+1}"; // Distinguish participants
           if (!personMap[currency]!.containsKey(key)) {
             personMap[currency]![key] = _PersonAccumulator("Participant ${i+1}", 0);
           }
           personMap[currency]![key]!.total += personTotal;
        }
      }
    }

    final Map<String, List<PersonAggregation>> finalPerPerson = {};
    personMap.forEach((currency, people) {
      final subtotal = grandTotals[currency] ?? 1.0;
      finalPerPerson[currency] = people.values.map((acc) {
        return PersonAggregation(
          displayName: acc.canonicalName,
          totalAmount: acc.total,
          sharePercentage: (acc.total / subtotal) * 100,
          currency: currency,
        );
      }).toList();
      
      // Sort by amount descending
      finalPerPerson[currency]!.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    });

    return TripAggregationResult(
      grandTotals: grandTotals,
      perPersonTotals: finalPerPerson,
      hasMixedCurrencies: currencies.length > 1,
      earliestDate: earliest,
      latestDate: latest,
    );
  }
}

class _PersonAccumulator {
  String canonicalName;
  double total;
  _PersonAccumulator(this.canonicalName, this.total);
}
