import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_compress_kit/media_compress_kit.dart';

import 'sample_media.dart';

void main() => runApp(const CompressApp());

class CompressApp extends StatelessWidget {
  const CompressApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4F46E5),
        brightness: brightness,
      ),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'media_compress_kit',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: const CompressPage(),
    );
  }
}

enum Mode { video, image, batch }

class CompressPage extends StatefulWidget {
  const CompressPage({super.key});

  @override
  State<CompressPage> createState() => _CompressPageState();
}

class _CompressPageState extends State<CompressPage> {
  var _mode = Mode.video;
  MediaInfo? _source;
  String? _preview;
  var _loading = false;
  String? _error;

  // Image options.
  var _quality = 80;
  int? _maxSide = 1920;
  var _format = ImageFormat.jpeg;
  int? _maxSizeKB;
  var _metadata = ImageMetadata.removeAll;

  // Video options.
  var _videoQuality = VideoQuality.medium;
  double? _maxSizeMB;
  var _codec = VideoCodec.h264;
  var _audio = true;
  double? _frameRate;

  SizeEstimate? _estimate;
  var _estimateRequest = 0;

  CompressController? _controller;
  double _progress = 0;
  CompressResult? _result;
  String? _resultPreview;
  Duration? _took;

  // Batch.
  List<String> _batch = [];
  final _batchItems = <String, BatchItem>{};

  ImageOptions get _imageOptions => ImageOptions(
    quality: _quality,
    maxWidth: _maxSide,
    maxHeight: _maxSide,
    format: _format,
    maxSizeKB: _maxSizeKB,
    metadata: _metadata,
  );

  VideoOptions get _videoOptions => VideoOptions(
    quality: _videoQuality,
    maxSizeMB: _maxSizeMB,
    codec: _codec,
    includeAudio: _audio,
    frameRate: _frameRate,
  );

  bool get _busy => _controller != null;

  /// Changes an option and refreshes the size estimate.
  void _set(VoidCallback change) {
    setState(change);
    _updateEstimate();
  }

  Future<void> _updateEstimate() async {
    final source = _source;
    final request = ++_estimateRequest;
    if (source == null || _mode == Mode.batch) return;
    try {
      final estimate = source.type == MediaType.image
          ? await MediaCompress.estimateImage(
              source.path,
              options: _imageOptions,
            )
          : await MediaCompress.estimateVideo(
              source.path,
              options: _videoOptions,
            );
      if (request == _estimateRequest) setState(() => _estimate = estimate);
    } on MediaCompressException {
      if (request == _estimateRequest) setState(() => _estimate = null);
    }
  }

  Future<void> _load(Future<String?> Function() pick) async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _estimate = null;
    });
    try {
      final path = await pick();
      if (path == null) return;
      // For a link, getInfo and thumbnail download it; the image preview
      // uses Image.network.
      final info = await MediaCompress.getInfo(path);
      final preview = info.type == MediaType.video
          ? (await MediaCompress.thumbnail(path)).path
          : path;
      setState(() {
        _source = info;
        _preview = preview;
      });
      _updateEstimate();
    } on MediaCompressException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _pickOne() async {
    final paths = await MediaCompress.pick(
      type: _mode == Mode.image ? PickType.image : PickType.video,
    );
    return paths.firstOrNull;
  }

  /// Asks for one or more web addresses (one per line in a batch).
  Future<List<String>> _askForUrls({bool multiple = false}) async {
    final field = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(multiple ? 'Add links' : 'Open a link'),
        content: TextField(
          controller: field,
          autofocus: true,
          // Multiline, so Enter starts a new line instead of closing.
          keyboardType: multiple ? TextInputType.multiline : TextInputType.url,
          minLines: multiple ? 3 : 1,
          maxLines: multiple ? 6 : 1,
          decoration: InputDecoration(
            hintText: 'https://example.com/video.mp4',
            helperText: multiple
                ? 'One link per line, or separated by spaces'
                : null,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, field.text),
            child: Text(multiple ? 'Add' : 'Open'),
          ),
        ],
      ),
    );
    field.dispose();
    final urls = (text ?? '')
        .split(RegExp(r'\s+'))
        .where((u) => u.isNotEmpty)
        .toList();
    final invalid = urls.where((u) => !isLink(u));
    if (invalid.isNotEmpty) {
      throw MediaCompressException(
        MediaCompressError.invalidArgument,
        'Not a web address: ${invalid.first}',
      );
    }
    return urls;
  }

  Future<String> _makeSample() =>
      _mode == Mode.image ? SampleMedia.photo() : SampleMedia.video(seconds: 8);

  Future<void> _compress() async {
    final source = _source!;
    final controller = CompressController();
    setState(() {
      _controller = controller;
      _error = null;
      _result = null;
      _progress = 0;
    });
    void onProgress(double p) {
      if (mounted) setState(() => _progress = p);
    }

    final watch = Stopwatch()..start();
    try {
      final CompressResult result = source.type == MediaType.image
          ? await MediaCompress.compressImage(
              source.path,
              options: _imageOptions,
              onProgress: onProgress,
              controller: controller,
            )
          : await MediaCompress.compressVideo(
              source.path,
              options: _videoOptions,
              onProgress: onProgress,
              controller: controller,
            );
      final took = watch.elapsed;
      final preview = source.type == MediaType.video
          ? (await MediaCompress.thumbnail(result.path)).path
          : result.path;
      setState(() {
        _result = result;
        _resultPreview = preview;
        _took = took;
      });
    } on MediaCompressException catch (e) {
      setState(
        () => _error = e.error == MediaCompressError.cancelled
            ? 'Cancelled.'
            : e.message,
      );
    } finally {
      if (mounted) setState(() => _controller = null);
    }
  }

  Future<void> _loadBatch(Future<List<String>> Function() pick) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final paths = await pick();
      if (paths.isNotEmpty) {
        setState(() {
          _batch = [..._batch, ...paths.where((p) => !_batch.contains(p))];
          _batchItems.clear();
        });
      }
    } on MediaCompressException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<String>> _makeBatchSamples() async => [
    await SampleMedia.photo(name: 'batch_1.jpg'),
    await SampleMedia.graphic(name: 'batch_2.png'),
    await SampleMedia.video(name: 'batch_3.mp4', seconds: 4),
    await SampleMedia.photo(name: 'batch_4.jpg', width: 3000, height: 2000),
  ];

  Future<void> _compressBatch() async {
    final controller = CompressController();
    setState(() {
      _controller = controller;
      _batchItems.clear();
      _progress = 0;
      _error = null;
    });
    final watch = Stopwatch()..start();
    await MediaCompress.compressAll(
      _batch,
      imageOptions: _imageOptions,
      videoOptions: _videoOptions,
      controller: controller,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
      onItemDone: (item) {
        if (mounted) setState(() => _batchItems[item.path] = item);
      },
    );
    if (mounted) {
      setState(() {
        _controller = null;
        _took = watch.elapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              'media_compress_kit',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Native image and video compression',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            SegmentedButton<Mode>(
              segments: const [
                ButtonSegment(
                  value: Mode.video,
                  label: Text('Video'),
                  icon: Icon(Icons.movie_outlined),
                ),
                ButtonSegment(
                  value: Mode.image,
                  label: Text('Image'),
                  icon: Icon(Icons.image_outlined),
                ),
                ButtonSegment(
                  value: Mode.batch,
                  label: Text('Batch'),
                  icon: Icon(Icons.collections_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: _busy
                  ? null
                  : (value) => setState(() {
                      _mode = value.single;
                      _source = null;
                      _result = null;
                      _estimate = null;
                      _error = null;
                    }),
            ),
            const SizedBox(height: 16),
            ...(_mode == Mode.batch ? _batchBody() : _singleBody()),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: colors.error)),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _singleBody() {
    final source = _source;
    final ready = source != null && !_loading;
    return [
      _SourceCard(
        info: source,
        preview: _preview,
        loading: _loading,
        onGallery: _busy ? null : () => _load(_pickOne),
        onSample: _busy ? null : () => _load(_makeSample),
        onLink: _busy
            ? null
            : () => _load(() async => (await _askForUrls()).firstOrNull),
      ),
      const SizedBox(height: 16),
      _Section(
        title: 'Options',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mode == Mode.image)
              _imageOptionsForm()
            else
              _videoOptionsForm(),
            if (_estimate != null) _EstimateLine(estimate: _estimate!),
            if (source != null && isLink(source.path))
              const _NoteLine(
                'Size estimates need a file on the device, so there is '
                'none for a link.',
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (_busy)
        _ProgressCard(progress: _progress, onCancel: _controller!.cancel)
      else
        _CompressButton(onPressed: ready ? _compress : null),
      if (_result != null) ...[
        const SizedBox(height: 16),
        _ResultCard(result: _result!, preview: _resultPreview, took: _took),
      ],
    ];
  }

  List<Widget> _batchBody() {
    // Sizes count each file once; the counts include every entry, so a
    // duplicate counts twice.
    final done = _batchItems.values.where((i) => i.isSuccess).toList();
    final succeeded = _batch
        .where((p) => _batchItems[p]?.isSuccess ?? false)
        .length;
    final failed = _batch
        .where((p) => _batchItems[p]?.isSuccess == false)
        .length;
    final before = done.fold(0, (sum, i) => sum + i.result!.originalSize);
    final after = done.fold(0, (sum, i) => sum + i.result!.size);
    return [
      _Section(
        title: _batch.isEmpty ? 'Files' : '${_batch.length} files',
        trailing: _batch.isEmpty || _busy
            ? null
            : TextButton(
                onPressed: () => setState(() {
                  _batch = [];
                  _batchItems.clear();
                }),
                child: const Text('Clear'),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            for (final path in _batch)
              _BatchRow(path: path, item: _batchItems[path]),
            if (_batch.isNotEmpty) const SizedBox(height: 12),
            _PickButtons(
              onGallery: _busy
                  ? null
                  : () => _loadBatch(() => MediaCompress.pick(multiple: true)),
              onSample: _busy ? null : () => _loadBatch(_makeBatchSamples),
              onLink: _busy
                  ? null
                  : () => _loadBatch(() => _askForUrls(multiple: true)),
            ),
            const SizedBox(height: 12),
            Text(
              'Uses the Image and Video tab settings: '
              '${_imageOptions.format.name.toUpperCase()} at quality $_quality, '
              '${_videoQuality.resolution}p video.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (_busy)
        _ProgressCard(progress: _progress, onCancel: _controller!.cancel)
      else
        _CompressButton(
          label: 'Compress all',
          onPressed: _batch.isNotEmpty && !_loading ? _compressBatch : null,
        ),
      if (_batchItems.isNotEmpty && !_busy) ...[
        const SizedBox(height: 16),
        _Section(
          title: 'Batch done',
          child: Builder(
            builder: (context) {
              final summary =
                  '$succeeded of ${_batch.length} compressed'
                  '${failed == 0 ? '' : ', $failed failed'}'
                  '${_took == null ? '' : ' in ${(_took!.inMilliseconds / 1000).toStringAsFixed(1)} s'}';
              if (done.isEmpty) {
                return Text(
                  summary,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                );
              }
              return _Saving(
                originalSize: before,
                size: after,
                footer: summary,
              );
            },
          ),
        ),
      ],
    ];
  }

  Widget _imageOptionsForm() {
    final native = Platform.isIOS ? ImageFormat.heic : ImageFormat.webp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Quality $_quality'),
        Slider(
          value: _quality.toDouble(),
          min: 10,
          max: 100,
          divisions: 18,
          onChanged: (v) => setState(() => _quality = v.round()),
          onChangeEnd: (_) => _updateEstimate(),
        ),
        const _Label('Longest side'),
        _Choices<int?>(
          values: const [1080, 1920, null],
          selected: _maxSide,
          label: (v) => v == null ? 'Original' : '$v px',
          onSelected: (v) => _set(() => _maxSide = v),
        ),
        const _Label('Format'),
        _Choices<ImageFormat>(
          values: [ImageFormat.jpeg, native, ImageFormat.png],
          selected: _format,
          label: (v) => v.name.toUpperCase(),
          onSelected: (v) => _set(() => _format = v),
        ),
        const _Label('Size limit'),
        _Choices<int?>(
          values: const [null, 100, 300, 1024],
          selected: _maxSizeKB,
          label: (v) => v == null
              ? 'None'
              : v >= 1024
              ? '${v ~/ 1024} MB'
              : '$v KB',
          onSelected: (v) => _set(() => _maxSizeKB = v),
        ),
        const _Label('Metadata'),
        _Choices<ImageMetadata>(
          values: ImageMetadata.values,
          selected: _metadata,
          label: (v) => switch (v) {
            ImageMetadata.removeAll => 'Remove all',
            ImageMetadata.keepWithoutLocation => 'Keep, no GPS',
            ImageMetadata.keepAll => 'Keep all',
          },
          onSelected: (v) => _set(() => _metadata = v),
        ),
      ],
    );
  }

  Widget _videoOptionsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Quality'),
        _Choices<VideoQuality>(
          values: VideoQuality.values,
          selected: _videoQuality,
          label: (v) => '${v.resolution}p',
          onSelected: (v) => _set(() => _videoQuality = v),
        ),
        const _Label('Size limit'),
        _Choices<double?>(
          values: const [null, 2, 8, 16],
          selected: _maxSizeMB,
          label: (v) => v == null ? 'None' : '${v.round()} MB',
          onSelected: (v) => _set(() => _maxSizeMB = v),
        ),
        const _Label('Codec'),
        _Choices<VideoCodec>(
          values: VideoCodec.values,
          selected: _codec,
          label: (v) => v == VideoCodec.h264 ? 'H.264' : 'HEVC',
          onSelected: (v) => _set(() => _codec = v),
        ),
        const _Label('Frame rate'),
        _Choices<double?>(
          values: const [null, 30, 24],
          selected: _frameRate,
          label: (v) => v == null ? 'Original' : '${v.round()} fps',
          onSelected: (v) => _set(() => _frameRate = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Keep audio'),
          value: _audio,
          onChanged: (v) => _set(() => _audio = v),
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.info,
    required this.preview,
    required this.loading,
    required this.onGallery,
    required this.onSample,
    required this.onLink,
  });

  final MediaInfo? info;
  final String? preview;
  final bool loading;
  final VoidCallback? onGallery;
  final VoidCallback? onSample;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final info = this.info;
    return _Section(
      title: 'Original',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (info != null)
            _MediaRow(
              preview: preview,
              title: formatBytes(info.size),
              lines: [
                if (isLink(info.path)) linkName(info.path),
                '${info.width} × ${info.height}'
                    '${info.rotation == 0 ? '' : ' (rotated ${info.rotation}°)'}',
                if (info.duration != null)
                  '${formatDuration(info.duration!)}'
                      '${info.frameRate == null ? '' : ' · ${info.frameRate!.round()} fps'}'
                      '${info.hasAudio ? ' · audio' : ''}',
                if (info.bitrate != null)
                  '${(info.bitrate! / 1000000).toStringAsFixed(1)} Mbps',
                if (info.mimeType != null) info.mimeType!,
              ],
            ),
          if (info != null || loading) const SizedBox(height: 12),
          _PickButtons(
            onGallery: onGallery,
            onSample: onSample,
            onLink: onLink,
          ),
        ],
      ),
    );
  }
}

class _PickButtons extends StatelessWidget {
  const _PickButtons({
    required this.onGallery,
    required this.onSample,
    required this.onLink,
  });

  final VoidCallback? onGallery;
  final VoidCallback? onSample;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    const compact = EdgeInsets.symmetric(horizontal: 8);
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onGallery,
            style: FilledButton.styleFrom(padding: compact),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onLink,
            style: OutlinedButton.styleFrom(padding: compact),
            icon: const Icon(Icons.link),
            label: const Text('Link'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSample,
            style: OutlinedButton.styleFrom(padding: compact),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Sample'),
          ),
        ),
      ],
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _EstimateLine extends StatelessWidget {
  const _EstimateLine({required this.estimate});

  final SizeEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.insights, size: 20, color: colors.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                estimate.isOriginal
                    ? 'Already small enough: the original is kept'
                    : 'Estimated ≈ ${formatBytes(estimate.size)} · '
                          '${estimate.width} × ${estimate.height}',
                style: TextStyle(color: colors.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompressButton extends StatelessWidget {
  const _CompressButton({required this.onPressed, this.label = 'Compress'});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.compress),
      label: Text(label),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress, required this.onCancel});

  final double progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Compressing… ${(progress * 100).round()}%',
      trailing: TextButton(onPressed: onCancel, child: const Text('Cancel')),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: progress, minHeight: 10),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, this.preview, this.took});

  final CompressResult result;
  final String? preview;
  final Duration? took;

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    return _Section(
      title: result.isOriginal ? 'Kept the original' : 'Compressed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Saving(originalSize: result.originalSize, size: result.size),
          const SizedBox(height: 16),
          _MediaRow(
            preview: preview,
            title: '${result.width} × ${result.height}',
            lines: [
              if (result is VideoResult)
                '${formatDuration(result.duration)} · '
                    '${(result.bitrate / 1000000).toStringAsFixed(2)} Mbps',
              if (result is ImageResult) result.format.name.toUpperCase(),
              if (took != null)
                'Took ${(took!.inMilliseconds / 1000).toStringAsFixed(1)} s',
            ],
          ),
        ],
      ),
    );
  }
}

/// The saving as a big percentage, sizes, and before and after bars.
class _Saving extends StatelessWidget {
  const _Saving({required this.originalSize, required this.size, this.footer});

  final int originalSize;
  final int size;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = originalSize == 0 ? 1.0 : size / originalSize;
    final saved = (1 - ratio) * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              saved >= 0
                  ? '−${saved.toStringAsFixed(0)}%'
                  : '+${(-saved).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${formatBytes(originalSize)} → ${formatBytes(size)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Bar(fraction: 1, color: colors.outlineVariant, label: 'Original'),
        const SizedBox(height: 6),
        _Bar(
          fraction: ratio.clamp(0, 1),
          color: colors.primary,
          label: 'Result',
        ),
        if (footer != null) ...[
          const SizedBox(height: 12),
          Text(footer!, style: TextStyle(color: colors.onSurfaceVariant)),
        ],
      ],
    );
  }
}

class _BatchRow extends StatelessWidget {
  const _BatchRow({required this.path, required this.item});

  final String path;
  final BatchItem? item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = this.item;
    final result = item?.result;
    final link = isLink(path);
    final isVideo =
        result is VideoResult ||
        RegExp(
          r'\.(mp4|mov|m4v|3gp|webm|mkv)$',
          caseSensitive: false,
        ).hasMatch(link ? Uri.parse(path).path : path);
    final String status;
    if (item == null) {
      status = link ? 'Waiting · link' : 'Waiting';
    } else if (result == null) {
      status = '${item.error!.error.name}: ${item.error!.message}';
    } else {
      status =
          '${formatBytes(result.originalSize)} → ${formatBytes(result.size)}'
          '  (−${((1 - result.ratio) * 100).toStringAsFixed(0)}%)';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isVideo ? Icons.movie_outlined : Icons.image_outlined,
            color: colors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link
                      ? linkName(path)
                      : path.split(Platform.pathSeparator).last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: item != null && result == null
                        ? colors.error
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (result != null) Icon(Icons.check_circle, color: colors.primary),
          if (item != null && result == null)
            Icon(Icons.error_outline, color: colors.error),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.color,
    required this.label,
  });

  final double fraction;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fraction.clamp(0.01, 1),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({
    required this.preview,
    required this.title,
    required this.lines,
  });

  final String? preview;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 84,
            height: 84,
            color: colors.surfaceContainerHighest,
            child: preview == null
                ? null
                : isLink(preview!)
                ? Image.network(
                    preview!,
                    key: ValueKey(preview),
                    fit: BoxFit.cover,
                    cacheWidth: 252,
                    errorBuilder: (_, _, _) => const Icon(Icons.link),
                  )
                : Image.file(
                    File(preview!),
                    key: ValueKey(preview),
                    fit: BoxFit.cover,
                    cacheWidth: 252,
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              for (final line in lines)
                Text(line, style: TextStyle(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

class _Choices<T> extends StatelessWidget {
  const _Choices({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          ChoiceChip(
            label: Text(label(value)),
            selected: value == selected,
            onSelected: (_) => onSelected(value),
          ),
      ],
    );
  }
}

bool isLink(String path) =>
    path.startsWith('https://') || path.startsWith('http://');

/// The host and file name of a link, for display.
String linkName(String url) {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments.where((s) => s.isNotEmpty);
  return segments.isEmpty ? uri.host : '${uri.host} · ${segments.last}';
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

String formatDuration(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
