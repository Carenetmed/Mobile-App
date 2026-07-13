import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/circles_shell.dart';
import 'package:app_t/features/Home/presentation/pages/community_profile_page.dart';
import 'package:app_t/features/Home/presentation/pages/create_community_page.dart';
import 'package:app_t/features/Home/presentation/state/communities_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpCommunities(WidgetTester tester) async {
  CommunitiesLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const CirclesShellPage(),
            routes: {
              RouteName.discoverCommunities:
                  (_) => const DiscoverCommunitiesPage(),
              RouteName.communityProfile:
                  (context) => CommunityProfilePage(
                    profile:
                        (ModalRoute.of(context)!.settings.arguments
                                as CommunityProfileRouteArgs)
                            .profile,
                    isOwner:
                        (ModalRoute.of(context)!.settings.arguments
                                as CommunityProfileRouteArgs)
                            .isOwner,
                  ),
              RouteName.ownerCircleProfile:
                  (_) => const CommunityProfilePage(
                    profile: CommunitiesLocalStore.ownerCircleProfile,
                    isOwner: true,
                  ),
              RouteName.createCommunity: (_) => const CreateCommunityPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('circles screen shows my communities', (tester) async {
    await _pumpCommunities(tester);

    expect(
      find.text('Stay close to the communities that matter.'),
      findsOneWidget,
    );
    expect(find.text('My communities'), findsOneWidget);
    expect(find.text('Women in Medicine'), findsOneWidget);
    expect(find.text('Diabetes Care Circle'), findsOneWidget);
  });

  testWidgets('discover communities route opens and can join locally', (
    tester,
  ) async {
    await _pumpCommunities(tester);

    await tester.tap(find.text('Discover communities'));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Resident Doctors Network'), findsOneWidget);

    await tester.tap(find.text('Join community').first);
    await tester.pumpAndSettle();

    expect(find.text('Joined locally'), findsOneWidget);
  });

  testWidgets('joined discovered community appears in my communities', (
    tester,
  ) async {
    await _pumpCommunities(tester);

    expect(find.text('Resident Doctors Network'), findsNothing);

    await tester.tap(find.text('Discover communities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Join community').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('My communities'), findsOneWidget);
    expect(find.text('Resident Doctors Network'), findsOneWidget);
    expect(
      find.text('Rotations, night shift survival, and practical support.'),
      findsOneWidget,
    );
  });

  testWidgets('community request acceptance reuses joined community state', (
    tester,
  ) async {
    await _pumpCommunities(tester);

    await tester.tap(find.text('Discover communities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();

    expect(find.text('360 Health Club'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.text('You have no requests'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('360 Health Club'), findsOneWidget);
  });

  testWidgets('community drafts tab shows an honest empty state', (
    tester,
  ) async {
    await _pumpCommunities(tester);

    await tester.tap(find.text('Discover communities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drafts'));
    await tester.pumpAndSettle();

    expect(find.text('You have no drafts'), findsOneWidget);
  });

  testWidgets('community card opens a local profile page', (tester) async {
    await _pumpCommunities(tester);

    await tester.tap(find.text('Women in Medicine'));
    await tester.pumpAndSettle();

    expect(find.text('Description'), findsOneWidget);
    expect(find.text('1.2k members'), findsWidgets);
    expect(find.text('Community articles'), findsOneWidget);
    expect(
      find.text('How to ask for sponsorship, not just mentorship'),
      findsOneWidget,
    );
  });

  testWidgets('create community validates required fields', (tester) async {
    await _pumpCommunities(tester);

    await tester.tap(find.text('Create community'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Community name is required'), findsOneWidget);
    expect(find.text('Community description is required'), findsOneWidget);
    expect(find.text('Privacy is required'), findsOneWidget);
  });

  testWidgets('create community adds local owned community and opens profile', (
    tester,
  ) async {
    await _pumpCommunities(tester);

    await tester.tap(find.text('Create community'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Heart Health Circle',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Support and education for daily heart health habits.',
    );
    await tester.tap(find.text('Public'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'amy@example.com, bolo@example.com',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Owner note'), findsOneWidget);
    expect(find.text('Heart Health Circle'), findsWidgets);
    expect(find.text('3 members'), findsWidgets);
    expect(find.text('Created locally'), findsOneWidget);
  });

  testWidgets('owner circle profile route shows owner settings as deferred', (
    tester,
  ) async {
    await _pumpCommunities(tester);

    Navigator.of(
      tester.element(find.byType(CirclesShellPage)),
    ).pushNamed(RouteName.ownerCircleProfile);
    await tester.pumpAndSettle();

    expect(find.text('Old People Circle'), findsWidgets);
    expect(find.text('120 members'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Circle permissions'), findsOneWidget);
    expect(find.text('Delete Circle'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });
}
