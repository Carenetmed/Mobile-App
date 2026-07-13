import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/podcast_local_store.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PodcastShellPage extends StatelessWidget {
  const PodcastShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Podcast',
          style: TextStyle(
            color: AppColors.primaryBlue5,
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: PodcastLocalStore.watchedEpisodeIds,
          builder: (context, watchedIds, _) {
            return ListView.separated(
              padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              itemCount: PodcastLocalStore.episodes.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      AbsorbPointer(
                        child: CarenetTextField(
                          hintText: 'Search keywords',
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Articles',
                                style: TextStyle(
                                  fontFamily: AppFonts.montserrat,
                                  fontSize: FontSizes.footer3,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.primaryBlue11,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Podcast',
                                    style: TextStyle(
                                      fontFamily: AppFonts.montserrat,
                                      fontSize: FontSizes.footer3,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.kBlack,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Container(
                                    width: 42.w,
                                    height: 2.h,
                                    color: AppColors.primaryBlue5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                final episode = PodcastLocalStore.episodes[index - 1];
                return _PodcastEpisodeCard(
                  episode: episode,
                  watched: watchedIds.contains(episode.id),
                  onWatch: () => PodcastLocalStore.markWatched(episode.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PodcastEpisodeCard extends StatelessWidget {
  const _PodcastEpisodeCard({
    required this.episode,
    required this.watched,
    required this.onWatch,
  });

  final PodcastEpisode episode;
  final bool watched;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: REdgeInsets.all(16.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.primaryBlue5,
                  child: Text(
                    episode.host.characters.first,
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w700,
                      fontSize: FontSizes.footer3,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.host,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w700,
                          fontSize: FontSizes.footer2,
                          color: AppColors.kBlack,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        episode.hostLine,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w400,
                          fontSize: FontSizes.footer4,
                          color: AppColors.primaryBlue11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: REdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue02,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    episode.typeLabel,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.footer4,
                      color: AppColors.kBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  episode.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: AppColors.blue02,
                        child: Icon(
                          episode.typeLabel == 'Video'
                              ? Icons.play_circle_outline
                              : Icons.graphic_eq,
                          size: 64.r,
                          color: AppColors.primaryBlue5,
                        ),
                      ),
                ),
                ColoredBox(color: Colors.black.withValues(alpha: 0.16)),
                Center(
                  child: Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: AppColors.kWhite.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      episode.typeLabel == 'Video'
                          ? Icons.play_arrow
                          : Icons.graphic_eq,
                      color: AppColors.primaryBlue5,
                      size: 34.r,
                    ),
                  ),
                ),
                Positioned(
                  right: 12.w,
                  bottom: 12.h,
                  child: Container(
                    padding: REdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      episode.durationLabel,
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w600,
                        fontSize: FontSizes.footer4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: REdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSizes.body3,
                    color: AppColors.kBlack,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  episode.summary,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizes.footer2,
                    color: AppColors.primaryBlue11,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 16.w,
                  runSpacing: 8.h,
                  children: [
                    Text(episode.dateLabel),
                    Text(episode.viewsLabel),
                    Text(episode.commentsLabel),
                    Text(episode.durationLabel),
                  ],
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onWatch,
                    icon: Icon(
                      watched ? Icons.check_circle_outline : Icons.play_arrow,
                    ),
                    label: Text(watched ? 'Watched locally' : 'Watch'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
