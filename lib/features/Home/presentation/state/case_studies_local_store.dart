import 'package:flutter/foundation.dart';

class CaseStudyContent {
  const CaseStudyContent({
    required this.id,
    required this.title,
    required this.author,
    required this.readTime,
    required this.isBest,
    required this.summary,
    required this.body,
  });

  final String id;
  final String title;
  final String author;
  final String readTime;
  final bool isBest;
  final String summary;
  final String body;
}

class CaseStudiesLocalStore {
  CaseStudiesLocalStore._();

  static const List<CaseStudyContent> caseStudies = <CaseStudyContent>[
    CaseStudyContent(
      id: 'printed-organ-transplant',
      title:
          'The First Successful 3D-Printed Organ Transplant: Lessons Learned',
      author: 'Dr. Bisi Lawal',
      readTime: '7 min',
      isBest: true,
      summary:
          'Clinical coordination, recovery monitoring, and patient education lessons from a complex transplant milestone.',
      body:
          'This local case study summarizes how preparation, surgical planning, follow-up readings, and patient communication can shape recovery after a high-complexity intervention. In a backend version, the content API should provide the verified article body, author record, and publication metadata.',
    ),
    CaseStudyContent(
      id: 'rare-condition-care',
      title: 'Managing Rare Medical Conditions: Insights from Experts',
      author: 'Dr. Tamedu Okafor',
      readTime: '7 min',
      isBest: false,
      summary:
          'A practical look at multidisciplinary care planning when symptoms, referrals, and diagnostics are hard to standardize.',
      body:
          'Rare-condition care often depends on careful documentation, repeatable handoffs, and consistent follow-up with the patient. This local content keeps the reader flow usable while later content services replace the source with reviewed clinical material.',
    ),
  ];

  static final ValueNotifier<Set<String>> readCaseStudies =
      ValueNotifier<Set<String>>(<String>{});

  static void markRead(String caseStudyId) {
    final next = Set<String>.from(readCaseStudies.value)..add(caseStudyId);
    readCaseStudies.value = next;
  }

  static void reset() {
    readCaseStudies.value = <String>{};
  }
}
