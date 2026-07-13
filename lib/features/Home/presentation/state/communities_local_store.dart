import 'package:flutter/foundation.dart';

@immutable
class CommunityMembership {
  const CommunityMembership({
    required this.name,
    required this.description,
    required this.members,
  });

  final String name;
  final String description;
  final String members;
}

@immutable
class CommunityMemberPreview {
  const CommunityMemberPreview({
    required this.name,
    required this.role,
    required this.note,
  });

  final String name;
  final String role;
  final String note;
}

@immutable
class CommunityArticlePreview {
  const CommunityArticlePreview({
    required this.category,
    required this.title,
    required this.excerpt,
    required this.dateLabel,
    required this.readTimeLabel,
  });

  final String category;
  final String title;
  final String excerpt;
  final String dateLabel;
  final String readTimeLabel;
}

@immutable
class CommunityEventPreview {
  const CommunityEventPreview({
    required this.trackLabel,
    required this.title,
    required this.scheduleLabel,
  });

  final String trackLabel;
  final String title;
  final String scheduleLabel;
}

@immutable
class CommunityProfile {
  const CommunityProfile({
    required this.membership,
    required this.description,
    required this.memberPreviews,
    required this.articlePreviews,
    required this.comingEvents,
    required this.recentEvents,
  });

  final CommunityMembership membership;
  final String description;
  final List<CommunityMemberPreview> memberPreviews;
  final List<CommunityArticlePreview> articlePreviews;
  final List<CommunityEventPreview> comingEvents;
  final List<CommunityEventPreview> recentEvents;
}

@immutable
class CreatedCommunityDraft {
  const CreatedCommunityDraft({
    required this.name,
    required this.description,
    required this.privacy,
    required this.invites,
  });

  final String name;
  final String description;
  final String privacy;
  final List<String> invites;
}

class CommunitiesLocalStore {
  CommunitiesLocalStore._();

  static const CommunityProfile ownerCircleProfile = CommunityProfile(
    membership: CommunityMembership(
      name: 'Old People Circle',
      description: 'Circle for prostate health education and elder care.',
      members: '120 members',
    ),
    description:
        'Learn about prostate cancer. Prostate cancer is mostly common in men. Understanding it can save your life or someone you love. Once you are 40 plus, start checking it by visiting your doctor, stop smoking, and keep the conversation active in the circle.',
    memberPreviews: <CommunityMemberPreview>[
      CommunityMemberPreview(
        name: 'Tailok Olwan',
        role: 'Owner',
        note:
            'Keeps the circle focused on screening reminders and elder-care education.',
      ),
      CommunityMemberPreview(
        name: 'Dr. Adaeze Okoro',
        role: 'Admin',
        note:
            'Reviews prostate-health posts and prepares member question roundups.',
      ),
      CommunityMemberPreview(
        name: 'Nurse Bamidele',
        role: 'Moderator',
        note:
            'Helps members find practical next steps after screening reminders.',
      ),
    ],
    articlePreviews: <CommunityArticlePreview>[
      CommunityArticlePreview(
        category: 'Marketing',
        title: 'Migrating to Linear 101',
        excerpt:
            'Linear helps streamline software projects, sprints, tasks, and bug tracking. Here is how to get started.',
        dateLabel: 'Jul 18, 2024',
        readTimeLabel: '5 mins read',
      ),
      CommunityArticlePreview(
        category: 'Screening',
        title: 'What men over 40 should ask at checkups',
        excerpt:
            'A practical owner-curated reminder list for prostate-health appointments.',
        dateLabel: 'Jul 24, 2024',
        readTimeLabel: '4 mins read',
      ),
    ],
    comingEvents: <CommunityEventPreview>[
      CommunityEventPreview(
        trackLabel: 'Consulting - 2010',
        title: 'Migrating to Linear 101',
        scheduleLabel: 'Fri, 6:00 PM',
      ),
      CommunityEventPreview(
        trackLabel: 'Screening',
        title: 'Monthly prostate-health check-in',
        scheduleLabel: 'Sat, 10:00 AM',
      ),
    ],
    recentEvents: <CommunityEventPreview>[
      CommunityEventPreview(
        trackLabel: 'Consulting - 2010',
        title: 'Migrating to Linear 101',
        scheduleLabel: 'Last week',
      ),
      CommunityEventPreview(
        trackLabel: 'Education',
        title: 'Early signs and family conversations',
        scheduleLabel: '2 weeks ago',
      ),
    ],
  );

  static const Map<String, CommunityProfile>
  _profiles = <String, CommunityProfile>{
    'Women in Medicine': CommunityProfile(
      membership: CommunityMembership(
        name: 'Women in Medicine',
        description: 'Peer support, mentorship, and career conversations.',
        members: '1.2k members',
      ),
      description:
          'A local leadership and support space for women building long-term careers in medicine. This slice stays read-only for now, but the structure is ready for live membership, posts, and moderation later.',
      memberPreviews: <CommunityMemberPreview>[
        CommunityMemberPreview(
          name: 'Dr. Amara Okafor',
          role: 'Owner',
          note: 'Runs mentorship circles and monthly office-hours threads.',
        ),
        CommunityMemberPreview(
          name: 'Dr. Zainab Musa',
          role: 'Moderator',
          note: 'Keeps new-member questions and career resources organized.',
        ),
        CommunityMemberPreview(
          name: 'Dr. Esther Bello',
          role: 'Member',
          note: 'Shares fellowship prep notes and residency application tips.',
        ),
      ],
      articlePreviews: <CommunityArticlePreview>[
        CommunityArticlePreview(
          category: 'Career Growth',
          title: 'How to ask for sponsorship, not just mentorship',
          excerpt:
              'A practical guide for clinicians moving from advice to active advocacy.',
          dateLabel: 'Jul 18, 2024',
          readTimeLabel: '5 mins read',
        ),
        CommunityArticlePreview(
          category: 'Wellbeing',
          title: 'Protecting your off-hours during demanding rotations',
          excerpt:
              'Boundaries, scheduling patterns, and scripts members are using locally.',
          dateLabel: 'Jul 22, 2024',
          readTimeLabel: '4 mins read',
        ),
      ],
      comingEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Mentorship',
          title: 'Residency applications office hours',
          scheduleLabel: 'Tue, 7:30 PM',
        ),
        CommunityEventPreview(
          trackLabel: 'Leadership',
          title: 'Negotiation clinic for clinicians',
          scheduleLabel: 'Fri, 6:00 PM',
        ),
      ],
      recentEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Networking',
          title: 'Women founders in digital health',
          scheduleLabel: 'Last week',
        ),
        CommunityEventPreview(
          trackLabel: 'Support',
          title: 'Burnout recovery roundtable',
          scheduleLabel: '2 weeks ago',
        ),
      ],
    ),
    'Diabetes Care Circle': CommunityProfile(
      membership: CommunityMembership(
        name: 'Diabetes Care Circle',
        description: 'Practical advice for monitoring, meals, and check-ins.',
        members: '860 members',
      ),
      description:
          'A practical support group for better daily diabetes care. Members share monitoring routines, food planning ideas, and reminders that fit real schedules.',
      memberPreviews: <CommunityMemberPreview>[
        CommunityMemberPreview(
          name: 'Nurse Temi Afolayan',
          role: 'Owner',
          note: 'Hosts weekly blood sugar check-in prompts.',
        ),
        CommunityMemberPreview(
          name: 'Dr. Ikenna Obi',
          role: 'Admin',
          note: 'Curates educational posts and local care pathways.',
        ),
        CommunityMemberPreview(
          name: 'Miriam Ade',
          role: 'Member',
          note: 'Shares meal planning templates and tracker habits.',
        ),
      ],
      articlePreviews: <CommunityArticlePreview>[
        CommunityArticlePreview(
          category: 'Monitoring',
          title: 'What to log when readings swing unexpectedly',
          excerpt:
              'A short checklist for context, timing, meals, and symptoms.',
          dateLabel: 'Jul 12, 2024',
          readTimeLabel: '3 mins read',
        ),
        CommunityArticlePreview(
          category: 'Nutrition',
          title: 'Simple breakfast swaps members actually keep using',
          excerpt:
              'Local examples from the community without extreme diet rules.',
          dateLabel: 'Jul 20, 2024',
          readTimeLabel: '4 mins read',
        ),
      ],
      comingEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Care Plan',
          title: 'Weekly glucose trend review',
          scheduleLabel: 'Wed, 8:00 PM',
        ),
        CommunityEventPreview(
          trackLabel: 'Nutrition',
          title: 'Meal prep Q&A',
          scheduleLabel: 'Sat, 11:00 AM',
        ),
      ],
      recentEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Support',
          title: 'Newly diagnosed orientation',
          scheduleLabel: 'Last weekend',
        ),
        CommunityEventPreview(
          trackLabel: 'Monitoring',
          title: 'Reading review workshop',
          scheduleLabel: '2 weeks ago',
        ),
      ],
    ),
    'Resident Doctors Network': CommunityProfile(
      membership: CommunityMembership(
        name: 'Resident Doctors Network',
        description: 'Rotations, night shift survival, and practical support.',
        members: '2.4k members',
      ),
      description:
          'A fast-moving resident community focused on shift survival, workload advice, and practical peer support across rotations.',
      memberPreviews: <CommunityMemberPreview>[
        CommunityMemberPreview(
          name: 'Dr. Daniel Aina',
          role: 'Owner',
          note: 'Coordinates shift cover requests and onboarding guidance.',
        ),
        CommunityMemberPreview(
          name: 'Dr. Chika Eze',
          role: 'Moderator',
          note: 'Keeps call-room resources and study links organized.',
        ),
        CommunityMemberPreview(
          name: 'Dr. Miriam Jatto',
          role: 'Member',
          note: 'Posts handoff templates and night-float coping tips.',
        ),
      ],
      articlePreviews: <CommunityArticlePreview>[
        CommunityArticlePreview(
          category: 'Residency',
          title: 'Night shift handoff notes that reduce missed details',
          excerpt:
              'Templates and reminder patterns residents are reusing locally.',
          dateLabel: 'Jul 08, 2024',
          readTimeLabel: '6 mins read',
        ),
        CommunityArticlePreview(
          category: 'Study',
          title: 'How residents are organizing exam prep in short bursts',
          excerpt:
              'A realistic approach for crowded schedules and low energy days.',
          dateLabel: 'Jul 24, 2024',
          readTimeLabel: '4 mins read',
        ),
      ],
      comingEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Support',
          title: 'Night-float debrief',
          scheduleLabel: 'Thu, 9:00 PM',
        ),
        CommunityEventPreview(
          trackLabel: 'Study',
          title: 'Case review sprint',
          scheduleLabel: 'Sun, 5:30 PM',
        ),
      ],
      recentEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Rotations',
          title: 'Surgery rotation survival thread',
          scheduleLabel: '3 days ago',
        ),
        CommunityEventPreview(
          trackLabel: 'Wellbeing',
          title: 'Post-call recovery discussion',
          scheduleLabel: 'Last week',
        ),
      ],
    ),
    'Healthy Living Q&A': CommunityProfile(
      membership: CommunityMembership(
        name: 'Healthy Living Q&A',
        description: 'Evidence-based wellness questions and peer tips.',
        members: '970 members',
      ),
      description:
          'A mixed community for evidence-based wellness questions, habit experiments, and practical routines that members can actually sustain.',
      memberPreviews: <CommunityMemberPreview>[
        CommunityMemberPreview(
          name: 'Coach Aisha Lawal',
          role: 'Owner',
          note: 'Moderates routine-building conversations and weekly prompts.',
        ),
        CommunityMemberPreview(
          name: 'Femi Ojo',
          role: 'Admin',
          note: 'Collects shared habit trackers and recap notes.',
        ),
        CommunityMemberPreview(
          name: 'Joy Nnaji',
          role: 'Member',
          note: 'Shares exercise consistency tips and check-in templates.',
        ),
      ],
      articlePreviews: <CommunityArticlePreview>[
        CommunityArticlePreview(
          category: 'Habits',
          title: 'Starting a walking routine without burning out by day five',
          excerpt: 'Small-pattern advice from members who stuck with it.',
          dateLabel: 'Jul 15, 2024',
          readTimeLabel: '4 mins read',
        ),
        CommunityArticlePreview(
          category: 'Sleep',
          title: 'What improved sleep hygiene looked like in practice',
          excerpt:
              'A checklist members simplified after trying too many systems.',
          dateLabel: 'Jul 26, 2024',
          readTimeLabel: '3 mins read',
        ),
      ],
      comingEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Q&A',
          title: 'Ask a coach: building consistency',
          scheduleLabel: 'Mon, 6:00 PM',
        ),
        CommunityEventPreview(
          trackLabel: 'Movement',
          title: 'Beginner mobility check-in',
          scheduleLabel: 'Sat, 8:30 AM',
        ),
      ],
      recentEvents: <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Wellness',
          title: 'Habit reset workshop',
          scheduleLabel: 'Last week',
        ),
        CommunityEventPreview(
          trackLabel: 'Sleep',
          title: 'Screen-time boundaries discussion',
          scheduleLabel: '2 weeks ago',
        ),
      ],
    ),
  };

  static final ValueNotifier<List<CommunityMembership>> joinedCommunities =
      ValueNotifier<List<CommunityMembership>>(<CommunityMembership>[]);
  static final ValueNotifier<List<CommunityProfile>> ownedCommunities =
      ValueNotifier<List<CommunityProfile>>(<CommunityProfile>[]);
  static final ValueNotifier<List<CommunityMembership>>
  pendingInvitations = ValueNotifier<List<CommunityMembership>>(<
    CommunityMembership
  >[
    const CommunityMembership(
      name: '360 Health Club',
      description:
          'A practical community for year-round health conversations and shared care habits.',
      members: '225k members',
    ),
  ]);

  static bool isJoined(String communityName) {
    return joinedCommunities.value.any((item) => item.name == communityName);
  }

  static void joinCommunity(CommunityMembership community) {
    if (isJoined(community.name)) {
      return;
    }

    joinedCommunities.value = <CommunityMembership>[
      ...joinedCommunities.value,
      community,
    ];
  }

  static void acceptInvitation(CommunityMembership community) {
    joinCommunity(community);
    pendingInvitations.value =
        pendingInvitations.value
            .where((item) => item.name != community.name)
            .toList();
  }

  static CommunityProfile? profileFor(String communityName) {
    for (final profile in ownedCommunities.value) {
      if (profile.membership.name == communityName) {
        return profile;
      }
    }
    return _profiles[communityName];
  }

  static CommunityProfile createCommunity(CreatedCommunityDraft draft) {
    final inviteCount = draft.invites.length;
    final privacyLabel =
        draft.privacy == 'Private' ? 'Private circle' : 'Public circle';
    final profile = CommunityProfile(
      membership: CommunityMembership(
        name: draft.name,
        description: draft.description,
        members: inviteCount > 0 ? '${inviteCount + 1} members' : '1 member',
      ),
      description:
          '${draft.description} This community was created locally from the Phase 10 create-community slice. $privacyLabel settings, invites, posting, and moderation can be replaced later without changing the route flow.',
      memberPreviews: <CommunityMemberPreview>[
        CommunityMemberPreview(
          name: 'You',
          role: 'Owner',
          note:
              inviteCount > 0
                  ? 'Created this community locally and invited ${draft.invites.join(', ')}.'
                  : 'Created this community locally. Invite handling can plug into backend workflows later.',
        ),
      ],
      articlePreviews: const <CommunityArticlePreview>[
        CommunityArticlePreview(
          category: 'Next step',
          title: 'No articles yet',
          excerpt:
              'Articles are intentionally empty until community publishing exists.',
          dateLabel: 'Local only',
          readTimeLabel: 'Pending content',
        ),
      ],
      comingEvents: const <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Planning',
          title: 'No upcoming events yet',
          scheduleLabel: 'Create flow complete',
        ),
      ],
      recentEvents: const <CommunityEventPreview>[
        CommunityEventPreview(
          trackLabel: 'Created locally',
          title: 'Community draft created',
          scheduleLabel: 'Just now',
        ),
      ],
    );

    ownedCommunities.value = <CommunityProfile>[
      profile,
      ...ownedCommunities.value,
    ];
    joinCommunity(profile.membership);
    return profile;
  }

  static void reset() {
    joinedCommunities.value = <CommunityMembership>[];
    ownedCommunities.value = <CommunityProfile>[];
    pendingInvitations.value = <CommunityMembership>[
      const CommunityMembership(
        name: '360 Health Club',
        description:
            'A practical community for year-round health conversations and shared care habits.',
        members: '225k members',
      ),
    ];
  }
}
