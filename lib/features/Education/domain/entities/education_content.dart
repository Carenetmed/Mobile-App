enum EducationContentType {
  textPost('TEXT_POST'),
  shortVideo('SHORT_VIDEO');

  const EducationContentType(this.wireName);

  final String wireName;

  static EducationContentType parse(Object? value) => switch (value) {
    'TEXT_POST' => EducationContentType.textPost,
    'SHORT_VIDEO' => EducationContentType.shortVideo,
    _ => throw const FormatException('Education content type is invalid.'),
  };
}

class EducationContent {
  const EducationContent({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.body,
    required this.caption,
    required this.mediaDurationMs,
    required this.rejectionCode,
    required this.createdAt,
    required this.updatedAt,
    required this.submittedAt,
    required this.publishedAt,
  });

  final String id;
  final EducationContentType type;
  final String status;
  final String title;
  final String? body;
  final String? caption;
  final int? mediaDurationMs;
  final String? rejectionCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;
  final DateTime? publishedAt;

  bool get hasVideo => mediaDurationMs != null && mediaDurationMs! > 0;
  bool get canEdit =>
      status == 'DRAFT' || status == 'REJECTED' || status == 'PUBLISHED';
  bool get canArchive => status != 'ARCHIVED';
  bool get canSubmit =>
      (status == 'DRAFT' || status == 'REJECTED') &&
      (type == EducationContentType.textPost
          ? body?.trim().isNotEmpty == true
          : hasVideo);

  factory EducationContent.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final status = json['status'];
    final title = json['title'];
    if (id is! String ||
        id.isEmpty ||
        status is! String ||
        !_educationStatuses.contains(status) ||
        title is! String) {
      throw const FormatException('Education content response is invalid.');
    }
    return EducationContent(
      id: id,
      type: EducationContentType.parse(json['type']),
      status: status,
      title: title,
      body: _optionalString(json['body']),
      caption: _optionalString(json['caption']),
      mediaDurationMs: _optionalInt(json['mediaDurationMs']),
      rejectionCode: _optionalString(json['rejectionCode']),
      createdAt: _optionalDate(json['createdAt']),
      updatedAt: _optionalDate(json['updatedAt']),
      submittedAt: _optionalDate(json['submittedAt']),
      publishedAt: _optionalDate(json['publishedAt']),
    );
  }

  EducationContent copyWith({
    String? title,
    String? body,
    String? caption,
    int? mediaDurationMs,
    String? rejectionCode,
    String? status,
    DateTime? submittedAt,
    DateTime? publishedAt,
    bool clearRejectionCode = false,
  }) => EducationContent(
    id: id,
    type: type,
    status: status ?? this.status,
    title: title ?? this.title,
    body: body ?? this.body,
    caption: caption ?? this.caption,
    mediaDurationMs: mediaDurationMs ?? this.mediaDurationMs,
    rejectionCode:
        clearRejectionCode ? null : rejectionCode ?? this.rejectionCode,
    createdAt: createdAt,
    updatedAt: updatedAt,
    submittedAt: submittedAt ?? this.submittedAt,
    publishedAt: publishedAt ?? this.publishedAt,
  );
}

class EducationVideoUploadReceipt {
  const EducationVideoUploadReceipt({
    required this.id,
    required this.status,
    required this.durationMs,
  });

  final String id;
  final String status;
  final int durationMs;

  factory EducationVideoUploadReceipt.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final status = json['status'];
    final durationMs = json['mediaDurationMs'];
    if (id is! String ||
        id.isEmpty ||
        status is! String ||
        !_educationStatuses.contains(status) ||
        durationMs is! int ||
        durationMs <= 0 ||
        durationMs > 60000) {
      throw const FormatException('Video upload response is invalid.');
    }
    return EducationVideoUploadReceipt(
      id: id,
      status: status,
      durationMs: durationMs,
    );
  }
}

const Set<String> _educationStatuses = <String>{
  'DRAFT',
  'PENDING_REVIEW',
  'PUBLISHED',
  'REJECTED',
  'ARCHIVED',
};

String? _optionalString(Object? value) {
  if (value == null || value is String) return value as String?;
  throw const FormatException('Education content field is invalid.');
}

int? _optionalInt(Object? value) {
  if (value == null || value is int) return value as int?;
  throw const FormatException('Education media field is invalid.');
}

DateTime? _optionalDate(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Education content date is invalid.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) {
    throw const FormatException('Education content date is invalid.');
  }
  return parsed;
}
