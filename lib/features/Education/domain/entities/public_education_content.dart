enum PublicEducationContentType {
  textPost,
  shortVideo;

  static PublicEducationContentType parse(Object? value) => switch (value) {
    'TEXT_POST' => PublicEducationContentType.textPost,
    'SHORT_VIDEO' => PublicEducationContentType.shortVideo,
    _ => throw const FormatException('Education content type is invalid.'),
  };
}

class PublicEducationAuthor {
  const PublicEducationAuthor({
    required this.displayName,
    required this.category,
    required this.specialty,
  });

  final String displayName;
  final String category;
  final String? specialty;

  factory PublicEducationAuthor.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Education author is invalid.');
    }
    final displayName = value['displayName'];
    final category = value['category'];
    final specialty = value['specialty'];
    if (displayName is! String ||
        displayName.trim().isEmpty ||
        category is! String ||
        category.trim().isEmpty ||
        (specialty != null && specialty is! String)) {
      throw const FormatException('Education author is invalid.');
    }
    return PublicEducationAuthor(
      displayName: displayName,
      category: category,
      specialty: specialty as String?,
    );
  }
}

class PublicEducationVideo {
  const PublicEducationVideo({
    required this.url,
    required this.expiresInSeconds,
    required this.receivedAt,
  });

  final Uri url;
  final int expiresInSeconds;
  final DateTime receivedAt;

  DateTime get expiresAt => receivedAt.add(Duration(seconds: expiresInSeconds));

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  factory PublicEducationVideo.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Education video is invalid.');
    }
    final rawUrl = value['url'];
    final expiresInSeconds = value['expiresInSeconds'];
    final uri = rawUrl is String ? Uri.tryParse(rawUrl) : null;
    final host = uri?.host.toLowerCase() ?? '';
    final trustedStorageHost =
        host == 'storage.googleapis.com' ||
        host.endsWith('.storage.googleapis.com');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        !trustedStorageHost ||
        expiresInSeconds is! int ||
        expiresInSeconds < 1 ||
        expiresInSeconds > 600) {
      throw const FormatException('Education video is invalid.');
    }
    return PublicEducationVideo(
      url: uri,
      expiresInSeconds: expiresInSeconds,
      receivedAt: DateTime.now().toUtc(),
    );
  }
}

class PublicEducationContent {
  const PublicEducationContent({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.caption,
    required this.publishedAt,
    required this.author,
    required this.video,
  });

  final String id;
  final PublicEducationContentType type;
  final String title;
  final String? body;
  final String? caption;
  final DateTime publishedAt;
  final PublicEducationAuthor author;
  final PublicEducationVideo? video;

  factory PublicEducationContent.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final body = json['body'];
    final caption = json['caption'];
    final publishedAt = json['publishedAt'];
    final type = PublicEducationContentType.parse(json['type']);
    final videoJson = json['video'];
    final parsedVideo =
        videoJson == null ? null : PublicEducationVideo.fromJson(videoJson);
    final parsedPublishedAt =
        publishedAt is String ? DateTime.tryParse(publishedAt) : null;

    if (id is! String ||
        id.trim().isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        (body != null && body is! String) ||
        (caption != null && caption is! String) ||
        parsedPublishedAt == null ||
        !parsedPublishedAt.isUtc ||
        (type == PublicEducationContentType.textPost &&
            (body as String?)?.trim().isNotEmpty != true) ||
        (type == PublicEducationContentType.shortVideo &&
            parsedVideo == null) ||
        (type == PublicEducationContentType.textPost && parsedVideo != null)) {
      throw const FormatException('Education content is invalid.');
    }
    return PublicEducationContent(
      id: id,
      type: type,
      title: title,
      body: body as String?,
      caption: caption as String?,
      publishedAt: parsedPublishedAt,
      author: PublicEducationAuthor.fromJson(json['author']),
      video: parsedVideo,
    );
  }
}

class PublicEducationFeedPage {
  const PublicEducationFeedPage({
    required this.items,
    required this.nextCursor,
  });

  final List<PublicEducationContent> items;
  final String? nextCursor;

  factory PublicEducationFeedPage.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Education feed is invalid.');
    }
    final items = value['items'];
    final nextCursor = value['nextCursor'];
    if (items is! List ||
        items.length > 20 ||
        (nextCursor != null && nextCursor is! String) ||
        (nextCursor is String &&
            (nextCursor.length > 128 ||
                !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(nextCursor)))) {
      throw const FormatException('Education feed is invalid.');
    }
    return PublicEducationFeedPage(
      items: items
          .map(
            (item) => PublicEducationContent.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : throw const FormatException('Education post is invalid.'),
            ),
          )
          .toList(growable: false),
      nextCursor: nextCursor as String?,
    );
  }
}
