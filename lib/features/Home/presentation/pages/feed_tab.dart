import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/widgets/social_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: REdgeInsets.only(top: 8, bottom: 24),
      itemCount: demoSocialPosts.length,
      separatorBuilder: (_, __) => SizedBox(height: 18.h),
      itemBuilder: (context, index) {
        final post = demoSocialPosts[index];
        return SocialPostCard(
          post: post,
          onCommentTap: () {
            Navigator.of(context).pushNamed(RouteName.commentOnFeed);
          },
        );
      },
    );
  }
}
