class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final String? note;
  final double? balance;
  

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.balance
    
  });

factory Expense.fromJson(Map<String, dynamic> json) {
  return Expense(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    category: json['category']?.toString() ?? '',
    date: json['date']?.toString() ?? '',
    note: json['note']?.toString() ?? '',
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
      'balance':balance,
    };
  }
}
