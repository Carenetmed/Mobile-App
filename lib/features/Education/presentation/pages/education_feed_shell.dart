import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Education/data/repositories/education_public_content_repository.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:app_t/features/Education/presentation/state/education_feed_controller.dart';
import 'package:app_t/features/Education/presentation/widgets/education_video_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EducationFeedShellPage extends StatefulWidget {
  const EducationFeedShellPage({super.key, this.source});

  final EducationPublicContentSource? source;

  @override
  State<EducationFeedShellPage> createState() => _EducationFeedShellPageState();
}

class _EducationFeedShellPageState extends State<EducationFeedShellPage> {
  late final EducationFeedController _controller;
  final ScrollController _scrollController = ScrollController();

  EducationPublicContentSource get _source =>
      widget.source ?? sl<EducationPublicContentRepository>();

  @override
  void initState() {
    super.initState();
    _controller = EducationFeedController(_source);
    _scrollController.addListener(_maybeLoadMore);
    unawaited(_controller.load());
  }

  void _maybeLoadMore() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 420) {
      unawaited(_controller.loadMore());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health education'),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder:
                (context, _) => IconButton(
                  tooltip: 'Refresh posts',
                  onPressed:
                      _controller.loading || _controller.refreshing
                          ? null
                          : _controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder:
              (context, _) => RefreshIndicator(
                onRefresh: _controller.refresh,
                child: _buildList(context),
              ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final items = _controller.items;
    if (_controller.loading && items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 240),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (_controller.error != null && items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          _ReaderMessage(
            icon: Icons.cloud_off_outlined,
            message: 'Health education posts could not be loaded.',
            actionLabel: 'Retry',
            onAction: _controller.load,
          ),
        ],
      );
    }
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          _ReaderMessage(
            icon: Icons.menu_book_outlined,
            message: 'Health education posts are not available yet.',
          ),
        ],
      );
    }

    final showFooter =
        _controller.hasMore ||
        _controller.loadingMore ||
        _controller.loadMoreError != null;
    final showRefreshStatus =
        _controller.refreshing || _controller.refreshError != null;
    final refreshStatusOffset = showRefreshStatus ? 1 : 0;
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length + (showFooter ? 1 : 0) + refreshStatusOffset,
      itemBuilder: (context, index) {
        if (showRefreshStatus && index == 0) {
          if (_controller.refreshing) {
            return const LinearProgressIndicator(minHeight: 2);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InlineStatus(
              message: _controller.refreshError!,
              actionLabel: 'Retry',
              onAction: _controller.refresh,
            ),
          );
        }
        final itemIndex = index - refreshStatusOffset;
        if (itemIndex == items.length) return _paginationFooter();
        return _EducationPostTile(
          content: items[itemIndex],
          onTap:
              () => Navigator.of(context).pushNamed(
                RouteName.educationDetail,
                arguments: items[itemIndex].id,
              ),
        );
      },
    );
  }

  Widget _paginationFooter() {
    if (_controller.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_controller.loadMoreError != null) {
      return Center(
        child: TextButton.icon(
          onPressed: _controller.loadMore,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry loading posts'),
        ),
      );
    }
    return Center(
      child: TextButton(
        onPressed: _controller.loadMore,
        child: const Text('Load more'),
      ),
    );
  }
}

class _EducationPostTile extends StatelessWidget {
  const _EducationPostTile({required this.content, required this.onTap});

  final PublicEducationContent content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isVideo = content.type == PublicEducationContentType.shortVideo;
    final authorDescription = [
      content.author.category,
      if (content.author.specialty?.trim().isNotEmpty == true)
        content.author.specialty!.trim(),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: CarenetColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: CarenetColors.neutral200),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isVideo
                          ? Icons.play_circle_outline
                          : Icons.article_outlined,
                      color: CarenetColors.brand,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isVideo ? 'Short video' : 'Post',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: CarenetColors.primary600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat.yMMMd().format(content.publishedAt.toLocal()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CarenetColors.neutral500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  content.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CarenetColors.neutral700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isVideo && content.body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    content.body!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CarenetColors.neutral600,
                      height: 1.45,
                    ),
                  ),
                ],
                if (isVideo) ...[
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(minHeight: 112),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CarenetColors.info200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 38,
                          color: CarenetColors.info100,
                        ),
                        SizedBox(height: 6),
                        Text('Open to watch'),
                      ],
                    ),
                  ),
                  if (content.caption?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      content.caption!.trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
                const SizedBox(height: 14),
                Text(
                  content.author.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CarenetColors.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authorDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CarenetColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EducationDetailShellPage extends StatefulWidget {
  const EducationDetailShellPage({
    super.key,
    required this.contentId,
    this.source,
    this.playbackFactory,
  });

  final String? contentId;
  final EducationPublicContentSource? source;
  final EducationVideoPlaybackFactory? playbackFactory;

  @override
  State<EducationDetailShellPage> createState() =>
      _EducationDetailShellPageState();
}

class _EducationDetailShellPageState extends State<EducationDetailShellPage> {
  late final EducationDetailController _controller;

  EducationPublicContentSource get _source =>
      widget.source ?? sl<EducationPublicContentRepository>();

  @override
  void initState() {
    super.initState();
    _controller = EducationDetailController(_source, widget.contentId ?? '');
    unawaited(_controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health education'),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder:
                (context, _) => IconButton(
                  tooltip: 'Refresh post',
                  onPressed:
                      _controller.loading || _controller.refreshing
                          ? null
                          : _controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder:
                (context, _) => IconButton(
                  tooltip: 'Report post',
                  onPressed:
                      _controller.content == null ||
                              _controller.reporting ||
                              _controller.reported
                          ? null
                          : _report,
                  icon: const Icon(Icons.flag_outlined),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder:
              (context, _) => RefreshIndicator(
                onRefresh: _controller.refresh,
                child: _buildBody(context),
              ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final content = _controller.content;
    if (_controller.loading && content == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 240),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (_controller.notFound) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 130),
          _ReaderMessage(
            icon: Icons.article_outlined,
            message: 'This post is no longer available.',
            actionLabel: 'Back to posts',
            onAction: () => Navigator.of(context).maybePop(),
          ),
        ],
      );
    }
    if (content == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 130),
          _ReaderMessage(
            icon: Icons.cloud_off_outlined,
            message: 'This post could not be loaded.',
            actionLabel: 'Retry',
            onAction: _controller.load,
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        if (_controller.refreshing) const LinearProgressIndicator(minHeight: 2),
        if (_controller.error != null) ...[
          _InlineStatus(
            message: _controller.error!,
            actionLabel: 'Retry',
            onAction: _controller.refresh,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          content.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: CarenetColors.neutral700,
          ),
        ),
        const SizedBox(height: 12),
        _AuthorLine(content: content),
        const SizedBox(height: 6),
        Text(
          'Published ${DateFormat.yMMMd().format(content.publishedAt.toLocal())}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: CarenetColors.neutral500),
        ),
        const SizedBox(height: 20),
        if (content.video != null)
          EducationVideoPlayer(
            video: content.video!,
            onRefresh: _controller.refresh,
            playbackFactory:
                widget.playbackFactory ?? NativeEducationVideoPlayback.new,
          ),
        if (content.caption?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text(
            content.caption!.trim(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: CarenetColors.neutral700,
            ),
          ),
        ],
        if (content.body?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text(
            content.body!.trim(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.55,
              color: CarenetColors.neutral700,
            ),
          ),
        ],
        const SizedBox(height: 22),
        const _SafetyNote(),
        if (_controller.reported) ...[
          const SizedBox(height: 12),
          const _InlineStatus(message: 'Your report was received.'),
        ],
        if (_controller.reportError != null) ...[
          const SizedBox(height: 12),
          _InlineStatus(
            message: _controller.reportError!,
            actionLabel: _controller.reportRequiresSignIn ? 'Sign in' : null,
            onAction:
                _controller.reportRequiresSignIn
                    ? () =>
                        Navigator.of(context).pushNamed(RouteName.signInPhone)
                    : null,
          ),
        ],
      ],
    );
  }

  Future<void> _report() async {
    const reasons = <String, String>{
      'MISLEADING_HEALTH_INFORMATION': 'Misleading health information',
      'HARMFUL_OR_UNSAFE': 'Harmful or unsafe',
      'PRIVACY_CONCERN': 'Privacy concern',
      'SPAM_OR_PROMOTION': 'Spam or promotion',
      'OTHER': 'Other',
    };
    final reason = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report this post'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: reasons.entries
                  .map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value),
                      onTap: () => Navigator.pop(context, entry.key),
                    ),
                  )
                  .toList(growable: false),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
    if (reason == null || !mounted) return;
    await _controller.report(reason);
    if (!mounted) return;
    if (_controller.reported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your report was received.')),
      );
    }
  }
}

class _AuthorLine extends StatelessWidget {
  const _AuthorLine({required this.content});

  final PublicEducationContent content;

  @override
  Widget build(BuildContext context) {
    final author = content.author;
    final description = [
      author.category,
      if (author.specialty?.trim().isNotEmpty == true) author.specialty!.trim(),
    ].join(' · ');
    return Row(
      children: [
        const CircleAvatar(
          radius: 19,
          backgroundColor: CarenetColors.primary100,
          child: Icon(
            Icons.medical_services_outlined,
            color: CarenetColors.brand,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.displayName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CarenetColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CarenetColors.info200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'For general information only. This is not a diagnosis or personal medical advice.',
      ),
    );
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CarenetColors.info200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message)),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _ReaderMessage extends StatelessWidget {
  const _ReaderMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: CarenetColors.neutral400),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
