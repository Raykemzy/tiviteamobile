import 'dart:io';

/// Helpers for distinguishing image vs video media and deriving thumbnails.
class MediaUtils {
  MediaUtils._();

  /// Largest upload the backend accepts, in bytes.
  static const int maxUploadBytes = 5 * 1024 * 1024;

  /// Human-readable form of [maxUploadBytes], for error messages.
  static const String maxUploadLabel = '5MB';

  /// Whether [bytes] is within the upload limit.
  static bool isWithinUploadLimit(int bytes) => bytes <= maxUploadBytes;

  /// Checks a file on disk against the upload limit. Missing files pass —
  /// the upload itself will surface a more useful error than a size check.
  static Future<bool> fileIsWithinUploadLimit(String path) async {
    final file = File(path);
    if (!await file.exists()) return true;
    return isWithinUploadLimit(await file.length());
  }

  /// Returns the paths in [paths] that exceed the upload limit.
  static Future<List<String>> oversizedFiles(Iterable<String> paths) async {
    final oversized = <String>[];
    for (final path in paths) {
      if (!await fileIsWithinUploadLimit(path)) oversized.add(path);
    }
    return oversized;
  }

  static const Set<String> _videoExtensions = {
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'm4v',
    '3gp',
    'flv',
    'wmv',
  };

  /// Returns the last path segment of [path] (after the final `/`), with any
  /// query string stripped.
  static String _fileName(String path) {
    final withoutQuery = path.split('?').first;
    final lastSlash = withoutQuery.lastIndexOf('/');
    return lastSlash == -1 ? withoutQuery : withoutQuery.substring(lastSlash + 1);
  }

  /// Returns the lowercased file extension (without the dot) of [path].
  /// Empty when the filename has no extension. Only the dot within the last
  /// path segment counts, so dots in the host (e.g. `x.com`) are ignored.
  static String _extension(String path) {
    final fileName = _fileName(path);
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1 || lastDot == fileName.length - 1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }

  /// Whether the given local path or remote URL points to a video.
  static bool isVideo(String path) => _videoExtensions.contains(_extension(path));

  /// Derives a still-image thumbnail URL for a Cloudinary video by swapping
  /// the video extension for `.jpg`. Cloudinary generates a poster frame on
  /// the fly. Falls back to the original URL when the filename has no
  /// extension.
  static String cloudinaryVideoThumbnail(String videoUrl) {
    final withoutQuery = videoUrl.split('?').first;
    final lastSlash = withoutQuery.lastIndexOf('/');
    final dir = lastSlash == -1 ? '' : withoutQuery.substring(0, lastSlash + 1);
    final fileName =
        lastSlash == -1 ? withoutQuery : withoutQuery.substring(lastSlash + 1);
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return videoUrl;
    return '$dir${fileName.substring(0, lastDot)}.jpg';
  }
}
