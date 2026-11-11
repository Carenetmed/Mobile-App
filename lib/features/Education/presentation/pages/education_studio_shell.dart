import 'dart:typed_data';

import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/repositories/education_content_repository.dart';
import 'package:app_t/features/Education/domain/entities/education_content.dart';
import 'package:app_t/features/Education/presentation/state/education_studio_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class EducationPickedVideo {
  const EducationPickedVideo({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

abstract interface class EducationVideoPicker {
  Future<EducationPickedVideo?> pick(ImageSource source);
}

class ImagePickerEducationVideoPicker implements EducationVideoPicker {
  const ImagePickerEducationVideoPicker();

  @override
  Future<EducationPickedVideo?> pick(ImageSource source) async {
    final file = await ImagePicker().pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 60),
    );
    if (file == null) return null;
    if (!file.name.toLowerCase().endsWith('.mp4')) {
      throw const AuthFailure(
        type: AuthFailureType.validation,
        message: 'Choose an MP4 video under 60 seconds and 25 MB.',
      );
    }
    final length = await file.length();
    if (length <= 0 || length > EducationContentApiLimits.maxVideoBytes) {
      throw const AuthFailure(
        type: AuthFailureType.validation,
        message: 'Choose an MP4 video under 25 MB.',
      );
    }
    return EducationPickedVideo(
      name: file.name,
      bytes: await file.readAsBytes(),
    );
  }
}

class EducationContentApiLimits {
  EducationContentApiLimits._();

  static const int maxVideoBytes = 25 * 1024 * 1024;
}

class EducationStudioShellPage extends StatefulWidget {
  const EducationStudioShellPage({
    super.key,
    this.repository,
    this.videoPicker,
  });

  final EducationContentDataSource? repository;
  final EducationVideoPicker? videoPicker;

  @override
  State<EducationStudioShellPage> createState() =>
      _EducationStudioShellPageState();
}

class _EducationStudioShellPageState extends State<EducationStudioShellPage> {
  late final EducationStudioController _controller;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  final TextEditingController _caption = TextEditingController();
  EducationContentType _type = EducationContentType.textPost;
  bool _savingDraft = false;
  bool _selectingVideo = false;

  EducationVideoPicker get _videoPicker =>
      widget.videoPicker ?? const ImagePickerEducationVideoPicker();

  @override
  void initState() {
    super.initState();
    _controller = EducationStudioController(
      widget.repository ?? sl<EducationContentRepository>(),
    )..addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _title.dispose();
    _body.dispose();
    _caption.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _saveDraft() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    final caption = _caption.text.trim();
    if (title.isEmpty || title.length > 120) {
      _showMessage('Add a title using 1 to 120 characters.');
      return;
    }
    if (_type == EducationContentType.textPost &&
        (body.isEmpty || body.length > 3000)) {
      _showMessage('Add text using 1 to 3,000 characters.');
      return;
    }
    if (caption.length > 280) {
      _showMessage('Keep the caption under 280 characters.');
      return;
    }

    setState(() => _savingDraft = true);
    await _controller.createDraft(
      type: _type,
      title: title,
      body: _type == EducationContentType.textPost ? body : null,
      caption: caption.isNotEmpty ? caption : null,
    );
    if (!mounted) return;
    setState(() {
      _savingDraft = false;
      if (_controller.actionError == null) {
        _title.clear();
        _body.clear();
        _caption.clear();
        _type = EducationContentType.textPost;
      }
    });
  }

  Future<void> _editDraft(EducationContent content) async {
    if (content.status == 'PUBLISHED') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Edit approved content?'),
              content: const Text(
                'Saving changes will remove this post from the public feed until '
                'CareNet reviews the updated version.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue'),
                ),
              ],
            ),
      );
      if (confirmed != true || !mounted) return;
    }
    final updated = await showDialog<EducationDraftValues>(
      context: context,
      builder: (_) => EducationDraftEditorDialog(content: content),
    );
    if (updated == null) return;
    await _controller.updateDraft(
      content: content,
      title: updated.title,
      body: content.type == EducationContentType.textPost ? updated.body : null,
      caption:
          updated.caption == (content.caption ?? '') ? null : updated.caption,
    );
  }

  Future<void> _uploadVideo(EducationContent content) async {
    if (_selectingVideo || _controller.isMutating) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: const Text('Record a video'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.video_library_outlined),
                  title: const Text('Choose a video'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
    );
    if (source == null || !mounted) return;
    setState(() => _selectingVideo = true);
    try {
      final video = await _videoPicker.pick(source);
      if (!mounted || video == null) return;
      await _controller.uploadVideo(
        contentId: content.id,
        fileName: video.name,
        bytes: video.bytes,
      );
    } on AuthFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } catch (_) {
      if (mounted) {
        _showMessage('The video could not be selected. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _selectingVideo = false);
    }
  }

  Future<void> _submit(EducationContent content) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Submit for review?'),
            content: const Text(
              'A CareNet reviewer will check your post before it can be published. '
              'Do not include patient details or write personal diagnoses or prescriptions.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Submit'),
              ),
            ],
          ),
    );
    if (accepted == true) await _controller.submit(content);
  }

  Future<void> _retryUncertainDraft() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Retry an unconfirmed save?'),
            content: const Text(
              'The original save may already have succeeded. Retrying can create a duplicate draft.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Retry anyway'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    final created = await _controller.retryUncertainCreate();
    if (!mounted || created == null) return;
    setState(() {
      _title.clear();
      _body.clear();
      _caption.clear();
      _type = EducationContentType.textPost;
    });
  }

  Future<void> _archive(EducationContent content) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Archive this post?'),
            content: const Text('It will no longer be available in CareNet.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Archive'),
              ),
            ],
          ),
    );
    if (accepted == true) await _controller.archive(content);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final content = _controller.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education studio'),
        actions: [
          IconButton(
            tooltip: 'Refresh posts',
            onPressed:
                _controller.isLoading || _controller.isRefreshing
                    ? null
                    : _controller.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: REdgeInsets.all(16.r),
            children: [
              _guidance(),
              SizedBox(height: 20.h),
              if (!_controller.authoringUnavailable) _composer(),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your posts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_controller.isRefreshing)
                    SizedBox.square(
                      dimension: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              if (_controller.notice != null) ...[
                SizedBox(height: 12.h),
                _messageBox(_controller.notice!, success: true),
              ],
              if (_controller.actionError != null) ...[
                SizedBox(height: 12.h),
                _messageBox(_controller.actionError!),
              ],
              if (_controller.hasUncertainCreate) ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed:
                        _controller.isMutating ? null : _retryUncertainDraft,
                    icon: const Icon(Icons.warning_amber_outlined),
                    label: const Text('Retry save anyway'),
                  ),
                ),
              ],
              if (_controller.loadError != null && content.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _messageBox(
                  'Refresh failed. Your previously loaded posts are still shown.',
                ),
              ],
              SizedBox(height: 12.h),
              if (_controller.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_controller.loadError != null && content.isEmpty)
                _loadFailure()
              else if (content.isEmpty)
                _emptyState()
              else
                ...content.map(_contentCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guidance() => Container(
    padding: REdgeInsets.all(14.r),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF5EF),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: const Color(0xFFCFE3D8)),
    ),
    child: const Text(
      'Share general health education. Do not include patient details, '
      'personal diagnoses, prescriptions, or emergency guidance. '
      'Every submission is reviewed before publication.',
      style: TextStyle(height: 1.45),
    ),
  );

  Widget _composer() => Container(
    padding: REdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: const Color(0xFFD8E6DF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a draft',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 12.h),
        SegmentedButton<EducationContentType>(
          segments: const [
            ButtonSegment(
              value: EducationContentType.textPost,
              label: Text('Text post'),
              icon: Icon(Icons.article_outlined),
            ),
            ButtonSegment(
              value: EducationContentType.shortVideo,
              label: Text('Short video'),
              icon: Icon(Icons.videocam_outlined),
            ),
          ],
          selected: <EducationContentType>{_type},
          onSelectionChanged:
              _savingDraft || _controller.isMutating
                  ? null
                  : (selection) => setState(() => _type = selection.first),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _title,
          maxLength: 120,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8.h),
        if (_type == EducationContentType.textPost)
          TextField(
            controller: _body,
            minLines: 4,
            maxLines: 8,
            maxLength: 3000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Education text',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        TextField(
          controller: _caption,
          maxLength: 280,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Caption (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed:
                _savingDraft || _controller.isMutating ? null : _saveDraft,
            icon:
                _savingDraft
                    ? SizedBox.square(
                      dimension: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save_outlined),
            label: const Text('Save draft'),
          ),
        ),
      ],
    ),
  );

  Widget _contentCard(EducationContent item) {
    final canArchive = item.canArchive;
    return Container(
      key: ValueKey<String>('education-${item.id}'),
      margin: REdgeInsets.only(bottom: 10.h),
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD8E6DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(width: 8.w),
              _statusLabel(item.status),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            item.type == EducationContentType.textPost
                ? 'Text post'
                : 'Short video',
            style: TextStyle(color: AppColors.primaryBlue5, fontSize: 12.sp),
          ),
          if (item.rejectionCode != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Review note: ${_readableReason(item.rejectionCode!)}. Edit your draft before resubmitting.',
              style: TextStyle(color: const Color(0xFF8B4035), fontSize: 13.sp),
            ),
          ],
          if (item.type == EducationContentType.shortVideo) ...[
            SizedBox(height: 8.h),
            Text(
              item.hasVideo
                  ? 'Video uploaded · ${(item.mediaDurationMs! / 1000).round()} sec'
                  : 'Add an MP4 video before submitting.',
              style: TextStyle(color: const Color(0xFF54675E), fontSize: 13.sp),
            ),
          ],
          if (item.status == 'PUBLISHED') ...[
            SizedBox(height: 8.h),
            Text(
              'Approved by CareNet review. Feed availability depends on the current launch settings.',
              style: TextStyle(color: const Color(0xFF54675E), fontSize: 13.sp),
            ),
          ],
          if (_controller.isMutating &&
              item.type == EducationContentType.shortVideo &&
              _controller.uploadProgress > 0) ...[
            SizedBox(height: 10.h),
            LinearProgressIndicator(value: _controller.uploadProgress),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _controller.cancelUpload,
                child: const Text('Cancel upload'),
              ),
            ),
          ],
          if (item.canEdit || canArchive) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (item.canEdit &&
                    item.type == EducationContentType.shortVideo)
                  OutlinedButton.icon(
                    onPressed:
                        _controller.isMutating || _selectingVideo
                            ? null
                            : () => _uploadVideo(item),
                    icon: const Icon(Icons.video_library_outlined),
                    label: Text(item.hasVideo ? 'Replace video' : 'Add video'),
                  ),
                if (item.canEdit)
                  OutlinedButton.icon(
                    onPressed:
                        _controller.isMutating ? null : () => _editDraft(item),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                if (item.canSubmit)
                  FilledButton.icon(
                    onPressed:
                        _controller.isMutating ? null : () => _submit(item),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit for review'),
                  ),
                if (canArchive)
                  TextButton.icon(
                    onPressed:
                        _controller.isMutating ? null : () => _archive(item),
                    icon: const Icon(Icons.archive_outlined),
                    label: const Text('Archive'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusLabel(String status) {
    final (label, foreground, background) = switch (status) {
      'DRAFT' => ('Draft', const Color(0xFF44564E), const Color(0xFFEFF3F1)),
      'PENDING_REVIEW' => (
        'In review',
        const Color(0xFF76510D),
        const Color(0xFFFFF4D8),
      ),
      'PUBLISHED' => (
        'Approved',
        const Color(0xFF17674D),
        const Color(0xFFE7F4EC),
      ),
      'REJECTED' => (
        'Changes needed',
        const Color(0xFF8B4035),
        const Color(0xFFFFEFEC),
      ),
      'ARCHIVED' => (
        'Archived',
        const Color(0xFF5D6863),
        const Color(0xFFF0F2F1),
      ),
      _ => ('Unavailable', const Color(0xFF5D6863), const Color(0xFFF0F2F1)),
    };
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _loadFailure() => Container(
    padding: REdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4F1),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_controller.loadError ?? 'Your posts could not be loaded.'),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: _controller.isLoading ? null : _controller.refresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _emptyState() => Padding(
    padding: REdgeInsets.symmetric(vertical: 28.h),
    child: Column(
      children: [
        Icon(
          Icons.post_add_outlined,
          size: 36.r,
          color: AppColors.primaryBlue5,
        ),
        SizedBox(height: 8.h),
        const Text(
          'No education posts yet',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4.h),
        const Text('Your saved drafts and review updates will appear here.'),
      ],
    ),
  );

  Widget _messageBox(String message, {bool success = false}) => Container(
    padding: REdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: success ? const Color(0xFFE7F4EC) : const Color(0xFFFFF4F1),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      message,
      style: TextStyle(
        height: 1.4,
        color: success ? const Color(0xFF17674D) : const Color(0xFF8B4035),
      ),
    ),
  );

  String _readableReason(String value) =>
      value.replaceAll('_', ' ').toLowerCase();
}

class EducationDraftValues {
  const EducationDraftValues({
    required this.title,
    required this.body,
    required this.caption,
  });

  final String title;
  final String body;
  final String caption;
}

class EducationDraftEditorDialog extends StatefulWidget {
  const EducationDraftEditorDialog({required this.content, super.key});

  final EducationContent content;

  @override
  State<EducationDraftEditorDialog> createState() =>
      _EducationDraftEditorDialogState();
}

class _EducationDraftEditorDialogState
    extends State<EducationDraftEditorDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.content.title,
  );
  late final TextEditingController _body = TextEditingController(
    text: widget.content.body ?? '',
  );
  late final TextEditingController _caption = TextEditingController(
    text: widget.content.caption ?? '',
  );

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _caption.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    final body = _body.text.trim();
    final caption = _caption.text.trim();
    if (title.isEmpty ||
        title.length > 120 ||
        (widget.content.type == EducationContentType.textPost &&
            (body.isEmpty || body.length > 3000)) ||
        (widget.content.type == EducationContentType.shortVideo &&
            caption.length > 280)) {
      return;
    }
    Navigator.pop(
      context,
      EducationDraftValues(title: title, body: body, caption: caption),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit draft'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            maxLength: 120,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          if (widget.content.type == EducationContentType.textPost)
            TextField(
              controller: _body,
              minLines: 3,
              maxLines: 7,
              maxLength: 3000,
              decoration: const InputDecoration(labelText: 'Education text'),
            ),
          TextField(
            controller: _caption,
            maxLength: 280,
            decoration: const InputDecoration(labelText: 'Caption (optional)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );
}
