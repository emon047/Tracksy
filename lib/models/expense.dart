class Expense {
  final String? id; // Optional ID for update/delete
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      amount: map['amount'] is num
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount'].toString()) ?? 0,
      category: map['category'] ?? 'Others',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
