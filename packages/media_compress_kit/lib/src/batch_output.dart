import 'dart:io';

import 'options.dart';

/// The name, without extension, of the file [source] points to: the last
/// segment of a path or URL, with characters unsafe in file names replaced.
String baseName(String source) {
  String? name;
  final uri = Uri.tryParse(source);
  if (uri != null && uri.hasScheme && uri.scheme.length > 1) {
    // A URL or URI (not a Windows drive letter).
    final segments = uri.pathSegments.where((s) => s.isNotEmpty);
    if (segments.isEmpty) name = uri.host;
  }
  if (name == null) {
    name = uri != null && uri.hasScheme && uri.scheme.length > 1
        ? uri.pathSegments.lastWhere((s) => s.isNotEmpty)
        : source.split(RegExp(r'[/\\]')).last;
    final dot = name.lastIndexOf('.');
    if (dot > 0) name = name.substring(0, dot);
  }
  name = name.replaceAll(RegExp(r'[^\w\-]+'), '_');
  return name.isEmpty || name == '_' ? 'file' : name;
}

/// The file extension [compressImage] writes for [format].
String imageExtension(ImageFormat format) =>
    format == ImageFormat.jpeg ? 'jpg' : format.name;

/// Picks output files in a folder for a batch: `<name>.<ext>`, or
/// `<name>_1.<ext>` and so on when that name is taken, either by a file
/// already in the folder or by another file of the same batch.
class BatchOutputs {
  final _claimed = <String>{};

  /// For each of [sources], how many earlier ones have the same [baseName].
  /// Passed to [claim], it numbers same-named files in input order, whatever
  /// order they finish in.
  static List<int> ordinals(List<String> sources) {
    final seen = <String, int>{};
    return [
      for (final source in sources)
        seen.update(baseName(source), (n) => n + 1, ifAbsent: () => 0),
    ];
  }

  /// A free path in [folder] for the result of compressing [source], the
  /// [ordinal]th input with its name.
  String claim(
    String folder,
    String source,
    String extension, {
    int ordinal = 0,
  }) {
    final dir = folder.endsWith('/') || folder.endsWith(r'\')
        ? folder.substring(0, folder.length - 1)
        : folder;
    final base = baseName(source);
    String pathFor(int n) =>
        n == 0 ? '$dir/$base.$extension' : '$dir/${base}_$n.$extension';
    var n = ordinal;
    while (_claimed.contains(pathFor(n)) || File(pathFor(n)).existsSync()) {
      n++;
    }
    final path = pathFor(n);
    _claimed.add(path);
    return path;
  }
}

/// [options] writing to [outputPath] instead.
ImageOptions imageOptionsWithOutput(ImageOptions options, String outputPath) =>
    ImageOptions(
      quality: options.quality,
      maxWidth: options.maxWidth,
      maxHeight: options.maxHeight,
      format: options.format,
      maxSizeKB: options.maxSizeKB,
      metadata: options.metadata,
      outputPath: outputPath,
      allowLarger: options.allowLarger,
    );

/// [options] writing to [outputPath] instead.
VideoOptions videoOptionsWithOutput(VideoOptions options, String outputPath) =>
    VideoOptions(
      quality: options.quality,
      resolution: options.resolution,
      bitrate: options.bitrate,
      maxSizeMB: options.maxSizeMB,
      frameRate: options.frameRate,
      includeAudio: options.includeAudio,
      audioBitrate: options.audioBitrate,
      start: options.start,
      end: options.end,
      codec: options.codec,
      outputPath: outputPath,
      allowLarger: options.allowLarger,
    );
