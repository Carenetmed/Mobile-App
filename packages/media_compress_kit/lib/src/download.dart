import 'dart:async';
import 'dart:io';

/// Whether [path] is a web address rather than a file.
bool isUrl(String path) =>
    path.startsWith('https://') || path.startsWith('http://');

/// A failed download, before it is turned into a MediaCompressException.
class DownloadException implements Exception {
  const DownloadException(this.message, {this.cancelled = false});

  final String message;
  final bool cancelled;

  @override
  String toString() => message;
}

/// The file extension for a downloaded file: from the URL's path, or else
/// from its content type. iOS needs it to recognize videos.
String extensionFor(Uri uri, String? mimeType) {
  final last = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
  final dot = last.lastIndexOf('.');
  if (dot > 0 && last.length - dot <= 6) {
    final extension = last.substring(dot + 1).toLowerCase();
    if (RegExp(r'^[a-z0-9]+$').hasMatch(extension)) return extension;
  }
  return switch (mimeType) {
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/heic' || 'image/heif' => 'heic',
    'image/gif' => 'gif',
    'video/mp4' => 'mp4',
    'video/quicktime' => 'mov',
    'video/x-m4v' => 'm4v',
    'video/3gpp' => '3gp',
    'video/webm' => 'webm',
    _ => 'bin',
  };
}

var _downloads = 0;

/// Downloads [url] into [folder] and returns the file's path.
///
/// [onProgress] gets the fraction received when the server sends the
/// length. [registerAbort] gets a callback that stops the download, for
/// cancelling; the download then throws a cancelled [DownloadException].
Future<String> download(
  String url, {
  required String folder,
  Map<String, String>? headers,
  void Function(double progress)? onProgress,
  void Function(void Function() abort)? registerAbort,
}) async {
  final uri = Uri.parse(url);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  var aborted = false;
  HttpClientRequest? request;
  StreamSubscription<List<int>>? subscription;
  final done = Completer<void>();
  // Cancelling can fail it before anything awaits it.
  done.future.ignore();
  registerAbort?.call(() {
    aborted = true;
    request?.abort();
    subscription?.cancel();
    if (!done.isCompleted) {
      done.completeError(
        const DownloadException('Cancelled.', cancelled: true),
      );
    }
  });
  File? file;
  try {
    request = await client.getUrl(uri);
    if (aborted) throw const DownloadException('Cancelled.', cancelled: true);
    headers?.forEach(request.headers.set);
    final response = await request.close();
    if (aborted) throw const DownloadException('Cancelled.', cancelled: true);
    if (response.statusCode >= 400) {
      final reason = response.reasonPhrase;
      throw DownloadException(
        'HTTP ${response.statusCode}${reason.isEmpty ? '' : ' $reason'}: $url',
      );
    }
    final extension = extensionFor(uri, response.headers.contentType?.mimeType);
    await Directory(folder).create(recursive: true);
    // The counter keeps two downloads in the same microsecond apart, such as
    // the same URL twice in one batch.
    file = File(
      '$folder/download_${DateTime.now().microsecondsSinceEpoch}'
      '_${_downloads++}.$extension',
    );
    final sink = file.openWrite();
    final total = response.contentLength;
    var received = 0;
    subscription = response.listen(
      (chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      },
      onError: (Object error) {
        if (!done.isCompleted) done.completeError(error);
      },
      onDone: () {
        if (!done.isCompleted) done.complete();
      },
      cancelOnError: true,
    );
    try {
      await done.future;
    } finally {
      await sink.close();
    }
    if (total > 0 && received < total) {
      throw DownloadException(
        'The download of $url stopped after $received of $total bytes.',
      );
    }
    onProgress?.call(1);
    return file.path;
  } on DownloadException {
    await _delete(file);
    rethrow;
  } on Object catch (e) {
    await _delete(file);
    if (aborted) throw const DownloadException('Cancelled.', cancelled: true);
    throw DownloadException(_describe(e, uri));
  } finally {
    client.close(force: true);
  }
}

/// A short, readable reason for a failed download.
String _describe(Object error, Uri uri) {
  final host = uri.host;
  final text = error.toString();
  if (error is SocketException) {
    if (text.contains('host lookup')) {
      return "Couldn't find $host. Check the address and the internet "
          'connection.';
    }
    if (text.contains('timed out')) return 'Connecting to $host timed out.';
    final reason = error.osError?.message ?? error.message;
    return "Couldn't connect to $host${reason.isEmpty ? '' : ': $reason'}.";
  }
  if (error is HandshakeException || error is TlsException) {
    return 'The secure connection to $host failed.';
  }
  if (error is HttpException) return 'The connection to $host was lost.';
  if (error is FileSystemException) {
    return "Couldn't save the download: ${error.osError?.message ?? error.message}.";
  }
  return 'Downloading $uri failed: $text';
}

Future<void> _delete(File? file) async {
  try {
    await file?.delete();
  } on FileSystemException {
    // Not created.
  }
}
