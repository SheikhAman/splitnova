class HistoryItem {
  final String id;
  final double bill;
  final double tipAmount;
  final double tipPercent;
  final bool isFixedTip;
  final int people;
  final String currency;
  final String? reason;
  final DateTime date;
  final bool isCustomSplit;
  final List<PersonSplit>? peopleList;
  final double totalPerPerson;

  HistoryItem({
    required this.id,
    required this.bill,
    required this.tipAmount,
    required this.tipPercent,
    required this.isFixedTip,
    required this.people,
    required this.currency,
    this.reason,
    required this.date,
    required this.isCustomSplit,
    this.peopleList,
    required this.totalPerPerson,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill': bill,
      'tipAmount': tipAmount,
      'tipPercent': tipPercent,
      'isFixedTip': isFixedTip,
      'people': people,
      'currency': currency,
      'reason': reason,
      'date': date.toIso8601String(),
      'isCustomSplit': isCustomSplit,
      'peopleList': peopleList?.map((x) => x.toMap()).toList(),
      'totalPerPerson': totalPerPerson,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id']?.toString() ?? '',
      bill: (map['bill'] as num? ?? 0).toDouble(),
      tipAmount: (map['tipAmount'] as num? ?? 0).toDouble(),
      tipPercent: (map['tipPercent'] as num? ?? 0).toDouble(),
      isFixedTip: map['isFixedTip'] ?? false,
      people: (map['people'] as num? ?? 1).toInt(),
      currency: map['currency'] ?? 'USD',
      reason: map['reason'],
      date: map['date'] != null ? DateTime.tryParse(map['date']) ?? DateTime.now() : DateTime.now(),
      isCustomSplit: map['isCustomSplit'] ?? false,
      peopleList: map['peopleList'] != null
          ? List<PersonSplit>.from((map['peopleList'] as List).map((x) => PersonSplit.fromMap(x)))
          : null,
      totalPerPerson: (map['totalPerPerson'] as num? ?? 0).toDouble(),
    );
  }
}

class PersonSplit {
  final String name;
  final double percentage;

  PersonSplit({
    required this.name,
    required this.percentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'percentage': percentage,
    };
  }

  factory PersonSplit.fromMap(Map<String, dynamic> map) {
    return PersonSplit(
      name: map['name'] ?? '',
      percentage: (map['percentage'] as num? ?? 0).toDouble(),
    );
  }
}

class Trip {
  final String id;
  final String name;
  final List<HistoryItem> items;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
  });

  double get totalBill => items.fold(0, (sum, item) => sum + item.bill);
  double get totalTip => items.fold(0, (sum, item) => sum + item.tipAmount);
  double get totalAmount => totalBill + totalTip;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      items: map['items'] != null
          ? List<HistoryItem>.from((map['items'] as List).map((x) => HistoryItem.fromMap(x)))
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
