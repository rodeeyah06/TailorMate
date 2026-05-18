class TailorOrder {
  final int? id;
  final int clientId;
  final String outfitName;
  final String? fabric;
  final double? price;
  final String status;
  final String? dueDate;
  final String createdAt;

  TailorOrder({
    this.id,
    required this.clientId,
    required this.outfitName,
    this.fabric,
    this.price,
    this.status = 'pending',
    this.dueDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'outfit_name': outfitName,
      'fabric': fabric,
      'price': price,
      'status': status,
      'due_date': dueDate,
      'created_at': createdAt,
    };
  }

  factory TailorOrder.fromMap(Map<String, dynamic> map) {
    return TailorOrder(
      id: map['id'],
      clientId: map['client_id'],
      outfitName: map['outfit_name'],
      fabric: map['fabric'],
      price: map['price'],
      status: map['status'] ?? 'pending',
      dueDate: map['due_date'],
      createdAt: map['created_at'],
    );
  }

  TailorOrder copyWith({
    int? id,
    int? clientId,
    String? outfitName,
    String? fabric,
    double? price,
    String? status,
    String? dueDate,
    String? createdAt,
  }) {
    return TailorOrder(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      outfitName: outfitName ?? this.outfitName,
      fabric: fabric ?? this.fabric,
      price: price ?? this.price,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}