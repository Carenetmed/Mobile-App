import 'package:flutter/foundation.dart';

@immutable
class SearchSpecialist {
  const SearchSpecialist({
    required this.id,
    required this.name,
    required this.role,
    required this.categories,
    required this.rating,
    required this.availability,
    required this.priceLabel,
    required this.imageAsset,
    required this.summary,
  });

  final String id;
  final String name;
  final String role;
  final List<String> categories;
  final String rating;
  final String availability;
  final String priceLabel;
  final String imageAsset;
  final String summary;

  bool matches(String query, String category) {
    final normalizedQuery = query.trim().toLowerCase();
    final categoryMatches =
        category == SearchLocalStore.allCategory ||
        categories.any((item) => item.toLowerCase() == category.toLowerCase());

    if (!categoryMatches) {
      return false;
    }
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(normalizedQuery) ||
        role.toLowerCase().contains(normalizedQuery) ||
        categories.any((item) => item.toLowerCase().contains(normalizedQuery));
  }
}

class SearchLocalStore {
  SearchLocalStore._();

  static const String allCategory = 'All';

  static const List<String> categories = <String>[
    allCategory,
    'Generalist',
    'ENT Doctor',
    'Cardiologist',
    'Psychologist',
    'Physiotherapist',
    'Dietitians',
    'Neurologist',
    'Dermatologist',
  ];

  static const List<SearchSpecialist> specialists = <SearchSpecialist>[
    SearchSpecialist(
      id: 'dr-uzo-blessing',
      name: 'Dr. Uzo Blessing',
      role: 'General Practitioner, ENT Specialist & Neurologist',
      categories: <String>['Generalist', 'ENT Doctor', 'Neurologist'],
      rating: '5.0',
      availability: 'Sat-Sun | 6PM-9PM',
      priceLabel: 'From N10,000',
      imageAsset: 'assets/images/png/professional_one.png',
      summary:
          'Available for general care, ENT concerns, neurological reviews, and first-line triage.',
    ),
    SearchSpecialist(
      id: 'dr-chris-amaka',
      name: 'Dr. Chris Amaka',
      role: 'Cardiologist',
      categories: <String>['Cardiologist', 'Generalist'],
      rating: '4.9',
      availability: 'Mon-Fri | 5PM-8PM',
      priceLabel: 'From N20,000',
      imageAsset: 'assets/images/png/professional_two.png',
      summary:
          'Supports heart-health reviews, blood pressure discussions, and follow-up planning.',
    ),
    SearchSpecialist(
      id: 'dr-lakasegbe',
      name: 'Dr. Lakasegbe',
      role: 'Psychologist',
      categories: <String>['Psychologist'],
      rating: '4.8',
      availability: 'Tue-Thu | 4PM-7PM',
      priceLabel: 'From N15,000',
      imageAsset: 'assets/images/png/professional_three.png',
      summary:
          'Helps with stress, anxiety, emotional well-being, and practical coping routines.',
    ),
  ];

  static final ValueNotifier<Set<String>> requestedSpecialistIds =
      ValueNotifier<Set<String>>(<String>{});

  static List<SearchSpecialist> filter({
    required String query,
    required String category,
  }) {
    return specialists
        .where((specialist) => specialist.matches(query, category))
        .toList(growable: false);
  }

  static SearchSpecialist specialistById(String? id) {
    return specialists.firstWhere(
      (specialist) => specialist.id == id,
      orElse: () => specialists.first,
    );
  }

  static void markRequested(String specialistId) {
    requestedSpecialistIds.value = <String>{
      ...requestedSpecialistIds.value,
      specialistId,
    };
  }

  static void reset() {
    requestedSpecialistIds.value = <String>{};
  }
}
