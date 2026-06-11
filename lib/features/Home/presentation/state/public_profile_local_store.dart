class PublicProfileContent {
  const PublicProfileContent({
    required this.name,
    required this.role,
    required this.rating,
    required this.location,
    required this.memberSince,
    required this.email,
    required this.website,
    required this.address,
    required this.about,
    required this.specializations,
    required this.articles,
    required this.sections,
  });

  final String name;
  final String role;
  final String rating;
  final String location;
  final String memberSince;
  final String email;
  final String website;
  final String address;
  final String about;
  final List<String> specializations;
  final List<PublicProfileArticle> articles;
  final List<PublicProfileSection> sections;
}

class PublicProfileArticle {
  const PublicProfileArticle({
    required this.category,
    required this.title,
    required this.summary,
    required this.author,
    required this.date,
    required this.readTime,
  });

  final String category;
  final String title;
  final String summary;
  final String author;
  final String date;
  final String readTime;
}

class PublicProfileSection {
  const PublicProfileSection({required this.title, required this.body});

  final String title;
  final String body;
}

class PublicProfileLocalStore {
  PublicProfileLocalStore._();

  static const PublicProfileContent profile = PublicProfileContent(
    name: 'Lagbaja Omo Tamedu',
    role: 'Resident Doctor, Luth',
    rating: '5.0',
    location: 'Epe, Lagos',
    memberSince: 'since 2021',
    email: 'lagbaja.tamedu@email.com',
    website: 'www.lagbajawebsite.com',
    address: 'Block 12, Lagbaja Street, Lagbaja Town, Lagbaja State.',
    about:
        'Learn about prostate cancer. Prostate cancer is common in men, and understanding early checks can save your life or someone you love. Once you are 40 plus, start checking it by visiting your doctor.',
    specializations: <String>['Surgery', 'Pneumotherapy', 'Oncology'],
    articles: <PublicProfileArticle>[
      PublicProfileArticle(
        category: 'Marketing',
        title: 'Migrating to Linear 101',
        summary:
            'A local profile article preview that stands in for verified creator content until public profile APIs exist.',
        author: 'Phoenix Baker',
        date: 'Jul 18, 2024',
        readTime: '5 mins read',
      ),
      PublicProfileArticle(
        category: 'Consulting',
        title: 'Care planning for community clinics',
        summary:
            'A practical preview of how care teams document follow-up, referrals, and patient education.',
        author: 'Lagbaja Omo Tamedu',
        date: 'Jul 22, 2024',
        readTime: '6 mins read',
      ),
    ],
    sections: <PublicProfileSection>[
      PublicProfileSection(
        title: 'Awards',
        body:
            'Recognized for community health education and patient follow-up planning.',
      ),
      PublicProfileSection(
        title: 'Conferences & Workshops',
        body:
            'Participates in local clinical workshops focused on prevention, oncology awareness, and care coordination.',
      ),
      PublicProfileSection(
        title: 'Experience',
        body:
            'Resident doctor with local clinical experience, public education work, and community care involvement.',
      ),
    ],
  );
}
