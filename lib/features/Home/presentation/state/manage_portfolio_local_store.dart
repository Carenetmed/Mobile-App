import 'package:flutter/foundation.dart';

@immutable
class ManagedPortfolioContent {
  const ManagedPortfolioContent({
    required this.ownerName,
    required this.profileType,
    required this.rating,
    required this.membersLabel,
    required this.memberSince,
    required this.pageTitle,
    required this.pageSummary,
    required this.authorName,
    required this.articles,
    required this.circles,
  });

  final String ownerName;
  final String profileType;
  final String rating;
  final String membersLabel;
  final String memberSince;
  final String pageTitle;
  final String pageSummary;
  final String authorName;
  final List<ManagedPortfolioArticle> articles;
  final List<ManagedPortfolioCircle> circles;
}

@immutable
class ManagedPortfolioArticle {
  const ManagedPortfolioArticle({
    required this.title,
    required this.summary,
    required this.author,
    required this.status,
  });

  final String title;
  final String summary;
  final String author;
  final String status;
}

@immutable
class ManagedPortfolioCircle {
  const ManagedPortfolioCircle({
    required this.name,
    required this.description,
    required this.membersLabel,
  });

  final String name;
  final String description;
  final String membersLabel;
}

class ManagePortfolioLocalStore {
  ManagePortfolioLocalStore._();

  static const ManagedPortfolioContent portfolio = ManagedPortfolioContent(
    ownerName: 'Old People Circle',
    profileType: 'Circle',
    rating: '5.0',
    membersLabel: '120 members',
    memberSince: 'since 2021',
    pageTitle: '60+ Exercise Group',
    pageSummary:
        'Learn about prostate cancer. Prostate cancer is common in men, and understanding early checks can save your life or someone you love. Once you are 40 plus, start checking it by visiting your doctor.',
    authorName: 'Tailok Olwan',
    articles: <ManagedPortfolioArticle>[
      ManagedPortfolioArticle(
        title: '60+ Exercise Group',
        summary:
            'Learn about prostate cancer. Prostate cancer is common in men, and understanding it can save your life or someone you love.',
        author: 'Tailok Olwan',
        status: 'Local draft preview',
      ),
    ],
    circles: <ManagedPortfolioCircle>[
      ManagedPortfolioCircle(
        name: 'Old People Circle',
        description:
            'A local managed community portfolio preview until creator portfolio APIs exist.',
        membersLabel: '120 members',
      ),
    ],
  );
}
