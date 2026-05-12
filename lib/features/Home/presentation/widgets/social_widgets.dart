import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialPost {
  const SocialPost({
    required this.author,
    required this.role,
    required this.postAge,
    required this.content,
    required this.imageAsset,
    required this.reactions,
    required this.comments,
  });

  final String author;
  final String role;
  final String postAge;
  final String content;
  final String imageAsset;
  final String reactions;
  final String comments;
}

class ArticleItem {
  const ArticleItem({
    required this.author,
    required this.title,
    required this.summary,
    required this.body,
    required this.imageAsset,
    required this.readTime,
  });

  final String author;
  final String title;
  final String summary;
  final String body;
  final String imageAsset;
  final String readTime;
}

const String _postBody =
    'Learn about prostrate cancer. Prostrate cancer is mostly common in men.\n\n'
    'Understanding it can save your life or someone you love. Once you are 40 plus, '
    'start checking it by visiting your doctor,\n'
    '1. Stop smoking\n'
    '2. Exercise regularly\n'
    '3. Do PSA test';

const String _postBodyExtended =
    'Learn about prostrate cancer. Prostrate cancer is mostly common in men.\n\n'
    'Understanding it can save your life or someone you love. Once you are 40 plus, start checking it by\n\n'
    'visiting your doctor,\n'
    'Stop smoking\n'
    'exercise regularly\n'
    'Do PSA test\n'
    'No alcohol\n'
    'Eat balanced diet\n\n'
    'More in thread';

const String _articleSummary =
    'AI and robotics are changing diagnostics, treatment planning, and patient monitoring. '
    'This article explores the opportunities and the clinical responsibility that comes with them.';

const String _articleBody =
    'Artificial intelligence and robotics are no longer future concepts in healthcare. '
    'They are now part of patient triage, diagnosis support, treatment planning, and recovery monitoring.\n\n'
    'When applied responsibly, these technologies help clinicians work faster, reduce repetitive tasks, '
    'and create room for more personal patient care. Robotics can improve precision in surgery, while '
    'AI can support pattern detection across large clinical datasets.\n\n'
    'The real opportunity is not replacing practitioners, but giving them stronger tools. '
    'The best outcomes happen when technology supports medical judgment, ethical review, and patient trust.\n\n'
    'Healthcare teams still need clear accountability, transparent workflows, and careful validation. '
    'With those pieces in place, AI and robotics can improve speed, safety, and quality across the care journey.';

const demoSocialPosts = <SocialPost>[
  SocialPost(
    author: 'Lagbaja Tamedu',
    role: 'Resident Doctor, Luth',
    postAge: '2hr',
    content: _postBody,
    imageAsset: AssetsImages.professionalOne,
    reactions: '22k',
    comments: '252k',
  ),
  SocialPost(
    author: 'Lagbaja Tamedu',
    role: 'Resident Doctor, Luth',
    postAge: '2hr',
    content: _postBody,
    imageAsset: AssetsImages.professionalThree,
    reactions: '22k',
    comments: '252k',
  ),
];

const commentThreadPost = SocialPost(
  author: 'Lagbaja Tamedu',
  role: 'Resident Doctor, Luth',
  postAge: '2hr',
  content: _postBodyExtended,
  imageAsset: AssetsImages.professionalOne,
  reactions: '22k reactions',
  comments: '252k comments',
);

const demoArticles = <ArticleItem>[
  ArticleItem(
    author: 'Lagbaja Tamedu',
    title: 'The Future of Healthcare: AI & Robiotics in Medicine',
    summary: _articleSummary,
    body: _articleBody,
    imageAsset: AssetsImages.upgrade,
    readTime: '6 min read',
  ),
  ArticleItem(
    author: 'Lagbaja Tamedu',
    title: 'The Future of Healthcare: AI & Robiotics in Medicine',
    summary: _articleSummary,
    body: _articleBody,
    imageAsset: AssetsImages.professionalTwo,
    readTime: '4 min read',
  ),
];

const demoPodcasts = <ArticleItem>[
  ArticleItem(
    author: 'Lagbaja Tamedu',
    title: 'The Future of Healthcare: AI & Robiotics in Medicine',
    summary:
        'Podcast episode on AI-assisted care, doctor workflows, and what safe adoption looks like in practice.',
    body: _articleBody,
    imageAsset: AssetsImages.professionalThree,
    readTime: '18 min listen',
  ),
  ArticleItem(
    author: 'Lagbaja Tamedu',
    title: 'The Future of Healthcare: AI & Robiotics in Medicine',
    summary:
        'A shorter discussion on clinical decision support, robotics, and patient confidence in digital health tools.',
    body: _articleBody,
    imageAsset: AssetsImages.professionalOne,
    readTime: '12 min listen',
  ),
];

class SocialPostCard extends StatelessWidget {
  const SocialPostCard({
    super.key,
    required this.post,
    required this.onCommentTap,
    this.compact = false,
    this.showCountsLabel = false,
    this.showActionBar = false,
  });

  final SocialPost post;
  final VoidCallback onCommentTap;
  final bool compact;
  final bool showCountsLabel;
  final bool showActionBar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(compact ? 10 : 0),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(compact ? 12.r : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          SizedBox(height: 8.h),
          Text(
            post.content,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              fontSize: FontSizes.footer2,
              color: AppColors.white05,
              height: 1.5,
            ),
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 12.r : 0),
            child: Image.asset(
              post.imageAsset,
              height: compact ? 190.h : 210.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _MetricText(
                icon: Icons.favorite_border,
                label: showCountsLabel ? post.reactions : post.reactions,
              ),
              SizedBox(width: 14.w),
              InkWell(
                onTap: onCommentTap,
                child: _MetricText(
                  icon: Icons.mode_comment_outlined,
                  label: showCountsLabel ? post.comments : post.comments,
                ),
              ),
            ],
          ),
          if (showActionBar) ...[
            SizedBox(height: 10.h),
            Divider(color: const Color(0xFFE5E7EB), height: 1.h),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionLabel(icon: Icons.favorite_border, label: 'React'),
                InkWell(
                  onTap: onCommentTap,
                  child: const _ActionLabel(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comment',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class SocialCommentComposer extends StatelessWidget {
  const SocialCommentComposer({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundImage: const AssetImage(AssetsImages.profileHandle),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What do you think?',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.footer2,
                  color: AppColors.white04,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer2,
                color: AppColors.white06,
              ),
            ),
          ),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded, color: AppColors.primaryBlue5),
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final SocialPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundImage: const AssetImage(AssetsImages.profileHandle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  fontSize: FontSizes.footer2,
                  color: AppColors.white06,
                ),
              ),
              Text(
                '${post.role}    ${post.postAge}',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizes.footer3,
                  color: AppColors.white04,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: REdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue11,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'Follow',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              fontSize: FontSizes.footer3,
              color: AppColors.kWhite,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricText extends StatelessWidget {
  const _MetricText({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.white04),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes.footer3,
            color: AppColors.white04,
          ),
        ),
      ],
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: AppColors.white05),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w500,
            fontSize: FontSizes.footer2,
            color: AppColors.white05,
          ),
        ),
      ],
    );
  }
}
