import '../../domain/entities/appointment_summary.dart';

class AppointmentSummaryModel extends AppointmentSummary {
  const AppointmentSummaryModel({
    required super.id,
    required super.patientProfileId,
    required super.professionalProfileId,
    required super.requestedStartAt,
    required super.durationMinutes,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory AppointmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return AppointmentSummaryModel(
      id: (json['id'] as String?) ?? '',
      patientProfileId: (json['patientProfileId'] as String?) ?? '',
      professionalProfileId: (json['professionalProfileId'] as String?) ?? '',
      requestedStartAt: _asRequiredDateTime(json['requestedStartAt']),
      durationMinutes: _asInt(json['durationMinutes']),
      status: _statusFromWire(json['status']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  static int _asInt(Object? value) {
    return switch (value) {
      int parsed => parsed,
      num parsed => parsed.toInt(),
      String text => int.tryParse(text) ?? 0,
      _ => 0,
    };
  }

  static DateTime _asRequiredDateTime(Object? value) {
    return _asDateTime(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static AppointmentStatus _statusFromWire(Object? value) {
    return switch (value) {
      'REQUESTED' => AppointmentStatus.requested,
      'ACCEPTED' => AppointmentStatus.accepted,
      'DECLINED' => AppointmentStatus.declined,
      'CANCELLED' => AppointmentStatus.cancelled,
      'COMPLETED' => AppointmentStatus.completed,
      _ => AppointmentStatus.unknown,
    };
  }
}
