class Measurement {
  final int? id;
  final int clientId;
  final double? bust;
  final double? underbust;
  final double? nipple_to_nipple;
  final double? halfLength;
  final double? waist;
  final double? hips;
  final double? back;
  final double? shoulder;
  final double? sleeve;
  final double? fullLength;
  final double? sleeveLength;
  final double? thigh;
  final double? neck;
  final String recordedAt;

  Measurement({
    this.id,
    required this.clientId,
    this.bust,
    this.underbust,
    this.nipple_to_nipple,
    this.halfLength,
    this.waist,
    this.hips,
    this.back,
    this.shoulder,
    this.sleeve,
    this.fullLength,
    this.sleeveLength,
    this.thigh,
    this.neck,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'bust': bust,
      'underbust': underbust,
      'nipple_to_nipple': nipple_to_nipple,
      'waist': waist,
      'hips': hips,
      'back': back,
      'shoulder': shoulder,
      'sleeve': sleeve,
      'fullLength': fullLength,
      'halfLength': halfLength,
      'sleeveLength': sleeveLength,
      'thigh': thigh,
      'neck': neck,
      'recorded_at': recordedAt,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'],
      clientId: map['client_id'],
      bust: map['bust'],
      underbust: map['underbust'],
      nipple_to_nipple: map['nipple_to_nipple'],
      halfLength: map['halfLength'],
      waist: map['waist'],
      hips: map['hips'],
      back: map['back'],
      shoulder: map['shoulder'],
      sleeve: map['sleeve'],
      fullLength: map['fullLength'],
      sleeveLength: map['sleeveLength'],
      thigh: map['thigh'],
      neck: map['neck'],
      recordedAt: map['recorded_at'],
    );
  }

  Measurement copyWith({
    int? id,
    int? clientId,
    double? bust,
    double? underbust,
    double? nipple_to_nipple,
    double? halfLength,
    double? waist,
    double? hips,
    double? back,
    double? shoulder,
    double? sleeve,
    double? fullLength,
    double? sleeveLength,
    double? thigh,
    double? neck,
    String? recordedAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      bust: bust ?? this.bust,
      underbust: underbust ?? this.underbust,
      nipple_to_nipple: nipple_to_nipple ?? this.nipple_to_nipple,
      halfLength: halfLength ?? this.halfLength,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      back: back?? this.back,
      shoulder: shoulder ?? this.shoulder,
      sleeve: sleeve ?? this.sleeve,
      fullLength: fullLength ?? this.fullLength,
      sleeveLength: sleeveLength?? this.sleeveLength,
      thigh: thigh ?? this.thigh,
      neck: neck ?? this.neck,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
