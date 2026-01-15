class Transaction {
  final int? id;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String? note;
  final String type; // 'income' or 'expense'

  Transaction({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    required this.type,
  });

  // Convert Transaction to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'type': type,
    };
  }

  // Create Transaction from Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      categoryId: map['category_id'] as int,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      type: map['type'] as String,
    );
  }

  // Create a copy with modified fields
  Transaction copyWith({
    int? id,
    double? amount,
    int? categoryId,
    DateTime? date,
    String? note,
    String? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, amount: $amount, categoryId: $categoryId, date: $date, note: $note, type: $type}';
  }
}
