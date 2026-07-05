class TripModel {
  final String id;
  final String name;
  final String? emoji;
  final int? colorValue;
  final String createdAt; // ISOString
  final List<String> billIds;
  final bool isSettled;

  TripModel({
    required this.id,
    required this.name,
    this.emoji,
    this.colorValue,
    required this.createdAt,
    required this.billIds,
    this.isSettled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'colorValue': colorValue,
      'createdAt': createdAt,
      'billIds': billIds,
      'isSettled': isSettled,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      emoji: map['emoji'],
      colorValue: map['colorValue'],
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
      billIds: List<String>.from(map['billIds'] ?? []),
      isSettled: map['isSettled'] ?? false,
    );
  }

  TripModel copyWith({
    String? name,
    String? emoji,
    int? colorValue,
    List<String>? billIds,
    bool? isSettled,
  }) {
    return TripModel(
      id: this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      createdAt: this.createdAt,
      billIds: billIds ?? this.billIds,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}
