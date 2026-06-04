/// Helpers for distinguishing image vs video media and deriving thumbnails.
class MediaUtils {
  MediaUtils._();

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
