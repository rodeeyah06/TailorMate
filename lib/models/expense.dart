class Expense {
  final int? id;
  final int orderId;
  final String description;
  final double amount;

  Expense({
    this.id,
    required this.orderId,
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'description': description,
      'amount': amount,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      orderId: map['order_id'],
      description: map['description'],
      amount: map['amount'],
    );
  }

  Expense copyWith({
    int? id,
    int? orderId,
    String? description,
    double? amount,
  }) {
    return Expense(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }
}