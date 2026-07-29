import 'appointment_summary.dart';

class BookingIntent {
  const BookingIntent({
    required this.professionalProfileId,
    required this.startAt,
    required this.endAt,
    required this.durationMinutes,
    required this.idempotencyKey,
    required this.resumeRoute,
    required this.createdAt,
    required this.expiresAt,
    this.consultationMode = ConsultationMode.video,
    this.accountUserId,
  });

  final String professionalProfileId;
  final DateTime startAt;
  final DateTime endAt;
  final int durationMinutes;
  final String idempotencyKey;
  final String resumeRoute;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ConsultationMode consultationMode;
  final String? accountUserId;

  bool isExpired(DateTime now) => !expiresAt.isAfter(now.toUtc());

  bool matches({
    required String professionalProfileId,
    required DateTime startAt,
    required int durationMinutes,
    ConsultationMode? consultationMode,
  }) {
    return this.professionalProfileId == professionalProfileId &&
        this.startAt.toUtc() == startAt.toUtc() &&
        this.durationMinutes == durationMinutes &&
        (consultationMode == null || this.consultationMode == consultationMode);
  }

  BookingIntent copyWith({String? accountUserId}) {
    return BookingIntent(
      professionalProfileId: professionalProfileId,
      startAt: startAt,
      endAt: endAt,
      durationMinutes: durationMinutes,
      idempotencyKey: idempotencyKey,
      resumeRoute: resumeRoute,
      createdAt: createdAt,
      expiresAt: expiresAt,
      consultationMode: consultationMode,
      accountUserId: accountUserId ?? this.accountUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'professionalProfileId': professionalProfileId,
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': endAt.toUtc().toIso8601String(),
      'durationMinutes': durationMinutes,
      'idempotencyKey': idempotencyKey,
      'resumeRoute': resumeRoute,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'consultationMode': consultationMode.wireName,
      if (accountUserId != null) 'accountUserId': accountUserId,
    };
  }

  factory BookingIntent.fromJson(Map<String, dynamic> json) {
    final startAt = _requiredUtc(json['startAt']);
    final endAt = _requiredUtc(json['endAt']);
    final createdAt = _requiredUtc(json['createdAt']);
    final expiresAt = _requiredUtc(json['expiresAt']);
    final professionalProfileId =
        json['professionalProfileId'] as String? ?? '';
    final idempotencyKey = json['idempotencyKey'] as String? ?? '';
    final resumeRoute = json['resumeRoute'] as String? ?? '';
    final durationMinutes = json['durationMinutes'] as int? ?? 0;
    if (professionalProfileId.trim().isEmpty ||
        idempotencyKey.trim().isEmpty ||
        resumeRoute.trim().isEmpty ||
        durationMinutes != 30 ||
        !endAt.isAfter(startAt)) {
      throw const FormatException('Invalid booking intent.');
    }
    return BookingIntent(
      professionalProfileId: professionalProfileId,
      startAt: startAt,
      endAt: endAt,
      durationMinutes: durationMinutes,
      idempotencyKey: idempotencyKey,
      resumeRoute: resumeRoute,
      createdAt: createdAt,
      expiresAt: expiresAt,
      consultationMode:
          ConsultationModeWire.tryParse(json['consultationMode']) ??
          ConsultationMode.video,
      accountUserId: json['accountUserId'] as String?,
    );
  }

  static DateTime _requiredUtc(Object? value) {
    final parsed = DateTime.tryParse(value is String ? value : '');
    if (parsed == null) {
      throw const FormatException('Invalid booking intent timestamp.');
    }
    return parsed.toUtc();
  }
}
