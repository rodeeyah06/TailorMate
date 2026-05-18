class ShoppingItem {
  final int? id;
  final int orderId;
  final String item;
  final bool isBought;

  ShoppingItem({
    this.id,
    required this.orderId,
    required this.item,
    this.isBought = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'item': item,
      'is_bought': isBought ? 1 : 0,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      orderId: map['order_id'],
      item: map['item'],
      isBought: map['is_bought'] == 1,
    );
  }

  ShoppingItem copyWith({
    int? id,
    int? orderId,
    String? item,
    bool? isBought,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      item: item ?? this.item,
      isBought: isBought ?? this.isBought,
    );
  }
}