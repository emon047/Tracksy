class Expense {
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      title: map['title'] ?? '',
      amount: map['amount'] is num
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount'].toString()) ?? 0,
      category: map['category'] ?? 'Others',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
