class Client {
  final int? id;
  final String name;
  final String? phone;
  final String? photoPath;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Client({
    this.id,
    required this.name,
    this.phone,
    this.photoPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Client object → Map (to save into SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo_path': photoPath,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert Map → Client object (when reading from SQLite)
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      photoPath: map['photo_path'],
      notes: map['notes'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // Copy client but change specific fields
  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? photoPath,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}