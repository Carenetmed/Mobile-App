import 'package:flutter/foundation.dart';

class ArticleContent {
  const ArticleContent({
    required this.category,
    required this.title,
    required this.summary,
    required this.body,
  });

  final String category;
  final String title;
  final String summary;
  final String body;
}

class ArticlesLocalStore {
  ArticlesLocalStore._();

  static const List<ArticleContent> articles = <ArticleContent>[
    ArticleContent(
      category: 'Heart health',
      title: 'What to monitor after an intense workout',
      summary:
          'A simple checklist for recovery signs, hydration, and when to slow down before your next session.',
      body:
          'Watch for chest tightness, unusual dizziness, and recovery that stays delayed beyond the rest of your day. Rehydrating early and easing back into movement usually helps, but persistent warning signs are a cue to pause and get professional advice.',
    ),
    ArticleContent(
      category: 'Nutrition',
      title: 'Five easy breakfast upgrades for steadier energy',
      summary:
          'Small ingredient swaps can keep your morning routine familiar while helping energy stay more stable.',
      body:
          'Pairing protein, fiber, and slower carbohydrates in the morning can reduce the late-morning crash. Think yogurt plus fruit, eggs with toast, or oats with seeds rather than quick-sugar options on their own.',
    ),
  ];

  static final ValueNotifier<Set<String>> savedArticles =
      ValueNotifier<Set<String>>(<String>{});
  static final ValueNotifier<Set<String>> readArticles =
      ValueNotifier<Set<String>>(<String>{});

  static void toggleSaved(String articleTitle) {
    final next = Set<String>.from(savedArticles.value);
    if (!next.add(articleTitle)) {
      next.remove(articleTitle);
    }
    savedArticles.value = next;
  }

  static void markRead(String articleTitle) {
    final next = Set<String>.from(readArticles.value)..add(articleTitle);
    readArticles.value = next;
  }

  static void reset() {
    savedArticles.value = <String>{};
    readArticles.value = <String>{};
  }
}
