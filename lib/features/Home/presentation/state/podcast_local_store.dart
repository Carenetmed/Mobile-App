import 'package:flutter/foundation.dart';

@immutable
class PodcastEpisode {
  const PodcastEpisode({
    required this.id,
    required this.host,
    required this.hostLine,
    required this.typeLabel,
    required this.title,
    required this.summary,
    required this.imageAsset,
    required this.dateLabel,
    required this.viewsLabel,
    required this.commentsLabel,
    required this.durationLabel,
  });

  final String id;
  final String host;
  final String hostLine;
  final String typeLabel;
  final String title;
  final String summary;
  final String imageAsset;
  final String dateLabel;
  final String viewsLabel;
  final String commentsLabel;
  final String durationLabel;
}

class PodcastLocalStore {
  PodcastLocalStore._();

  static const List<PodcastEpisode> episodes = <PodcastEpisode>[
    PodcastEpisode(
      id: 'podcast-ai-robotics',
      host: 'Lagbaja Tamedu',
      hostLine: 'General Practitioner & Psychiatrist',
      typeLabel: 'Video',
      title: 'The Future of Healthcare: AI & Robotics in Medicine',
      summary:
          'Explore how AI and robotics are revolutionizing medicine, transforming diagnostics, and changing how care teams work with patients.',
      imageAsset: 'assets/images/png/professional_one.png',
      dateLabel: 'Nov. 16, 2024',
      viewsLabel: '192 views',
      commentsLabel: '39 comments',
      durationLabel: '7:39',
    ),
    PodcastEpisode(
      id: 'podcast-mental-health',
      host: 'Dr. Lakasegbe',
      hostLine: 'CareNet mental health contributor',
      typeLabel: 'Podcast',
      title: 'Building calmer daily health routines',
      summary:
          'A short conversation about keeping simple routines realistic when work, family, and health concerns overlap.',
      imageAsset: 'assets/images/png/professional_two.png',
      dateLabel: 'Nov. 18, 2024',
      viewsLabel: '88 views',
      commentsLabel: '12 comments',
      durationLabel: '11:04',
    ),
  ];

  static final ValueNotifier<Set<String>> watchedEpisodeIds =
      ValueNotifier<Set<String>>(<String>{});

  static void markWatched(String episodeId) {
    watchedEpisodeIds.value = <String>{...watchedEpisodeIds.value, episodeId};
  }

  static void reset() {
    watchedEpisodeIds.value = <String>{};
  }
}
