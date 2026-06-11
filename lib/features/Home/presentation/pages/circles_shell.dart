import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/pages/community_profile_page.dart';
import 'package:app_t/features/Home/presentation/state/communities_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CirclesShellPage extends StatelessWidget {
  const CirclesShellPage({super.key});

  static const List<_CommunityItem> _myCommunities = <_CommunityItem>[
    _CommunityItem(
      name: 'Women in Medicine',
      description: 'Peer support, mentorship, and career conversations.',
      members: '1.2k members',
    ),
    _CommunityItem(
      name: 'Diabetes Care Circle',
      description: 'Practical advice for monitoring, meals, and check-ins.',
      members: '860 members',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Circles',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: REdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stay close to the communities that matter.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This local communities slice gives the Circles tab a real home now, while live membership, posting, and moderation can plug in later.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CarenetButton(
                  label: 'Discover communities',
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.discoverCommunities);
                  },
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: CarenetButton(
                  label: 'Create community',
                  type: CarenetButtonType.outline,
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.createCommunity);
                  },
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'My communities',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 10.h),
              ValueListenableBuilder<List<CommunityMembership>>(
                valueListenable: CommunitiesLocalStore.joinedCommunities,
                builder: (context, joinedCommunities, _) {
                  final visibleCommunities = <_CommunityItem>[
                    ..._myCommunities,
                    ...joinedCommunities.map(_CommunityItem.fromMembership),
                  ];

                  return Column(
                    children:
                        visibleCommunities
                            .map(
                              (item) => _CommunityCard(
                                item: item,
                                onTap: () {
                                  final profile =
                                      CommunitiesLocalStore.profileFor(
                                        item.name,
                                      );
                                  if (profile == null) {
                                    return;
                                  }
                                  Navigator.pushNamed(
                                    context,
                                    RouteName.communityProfile,
                                    arguments: CommunityProfileRouteArgs(
                                      profile: profile,
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscoverCommunitiesPage extends StatefulWidget {
  const DiscoverCommunitiesPage({super.key});

  @override
  State<DiscoverCommunitiesPage> createState() =>
      _DiscoverCommunitiesPageState();
}

class _DiscoverCommunitiesPageState extends State<DiscoverCommunitiesPage> {
  int _selectedTab = 0;

  static const List<_CommunityItem> _discoverItems = <_CommunityItem>[
    _CommunityItem(
      name: 'Resident Doctors Network',
      description: 'Rotations, night shift survival, and practical support.',
      members: '2.4k members',
    ),
    _CommunityItem(
      name: 'Healthy Living Q&A',
      description: 'Evidence-based wellness questions and peer tips.',
      members: '970 members',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Discover',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: REdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          children: [
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 0, label: Text('For you')),
                ButtonSegment<int>(value: 1, label: Text('Requests')),
                ButtonSegment<int>(value: 2, label: Text('Drafts')),
              ],
              selected: <int>{_selectedTab},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedTab = selection.first;
                });
              },
            ),
            SizedBox(height: 24.h),
            if (_selectedTab == 0) ...[
              Text(
                'Find a circle that fits your needs.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Discovery is local/mock for now, but the join action and community list structure are ready for a later live community backend.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              ValueListenableBuilder<List<CommunityMembership>>(
                valueListenable: CommunitiesLocalStore.joinedCommunities,
                builder: (context, joinedCommunities, _) {
                  return Column(
                    children:
                        _discoverItems.map((item) {
                          final isJoined = joinedCommunities.any(
                            (community) => community.name == item.name,
                          );

                          return Container(
                            width: double.infinity,
                            margin: REdgeInsets.only(bottom: 12.h),
                            padding: REdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: AppColors.blue02,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.white04),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: FontSizes.footer2,
                                    fontFamily: AppFonts.montserrat,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.kBlack,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: FontSizes.footer3,
                                    fontFamily: AppFonts.montserrat,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primaryBlue11,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  item.members,
                                  style: TextStyle(
                                    fontSize: FontSizes.footer4,
                                    fontFamily: AppFonts.montserrat,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryBlue5,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: CarenetButton(
                                    label:
                                        isJoined
                                            ? 'Joined locally'
                                            : 'Join community',
                                    onPressed:
                                        isJoined
                                            ? null
                                            : () {
                                              CommunitiesLocalStore.joinCommunity(
                                                item.toMembership(),
                                              );
                                            },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ] else if (_selectedTab == 1)
              ValueListenableBuilder<List<CommunityMembership>>(
                valueListenable: CommunitiesLocalStore.pendingInvitations,
                builder: (context, invitations, _) {
                  if (invitations.isEmpty) {
                    return const _DiscoverEmptyState(
                      icon: Icons.mark_email_read_outlined,
                      message: 'You have no requests',
                    );
                  }
                  return Column(
                    children:
                        invitations
                            .map(
                              (invitation) => _InvitationCard(
                                invitation: invitation,
                                onAccept:
                                    () =>
                                        CommunitiesLocalStore.acceptInvitation(
                                          invitation,
                                        ),
                              ),
                            )
                            .toList(),
                  );
                },
              )
            else
              const _DiscoverEmptyState(
                icon: Icons.drafts_outlined,
                message: 'You have no drafts',
              ),
          ],
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation, required this.onAccept});

  final CommunityMembership invitation;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invitation.name,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            invitation.description,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            invitation.members,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 12.h),
          CarenetButton(label: 'Accept', onPressed: onAccept),
        ],
      ),
    );
  }
}

class _DiscoverEmptyState extends StatelessWidget {
  const _DiscoverEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 48.h),
      child: Column(
        children: [
          Icon(icon, size: 40.r, color: AppColors.primaryBlue11),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.kBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.item, this.onTap});

  final _CommunityItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: REdgeInsets.only(bottom: 12.h),
          padding: REdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.blue02,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.white04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                item.members,
                style: TextStyle(
                  fontSize: FontSizes.footer4,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue5,
                ),
              ),
              if (onTap != null) ...[
                SizedBox(height: 12.h),
                Text(
                  'Open community profile',
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityItem {
  const _CommunityItem({
    required this.name,
    required this.description,
    required this.members,
  });

  factory _CommunityItem.fromMembership(CommunityMembership membership) {
    return _CommunityItem(
      name: membership.name,
      description: membership.description,
      members: membership.members,
    );
  }

  final String name;
  final String description;
  final String members;

  CommunityMembership toMembership() {
    return CommunityMembership(
      name: name,
      description: description,
      members: members,
    );
  }
}
