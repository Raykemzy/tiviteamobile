/// Thrown when files are rejected before upload — currently only for
/// exceeding [MediaUtils.maxUploadBytes].
///
/// Carries a ready-to-show message so callers can pass it straight to
/// `context.showError`.
class MediaUploadException implements Exception {
  const MediaUploadException(this.message);

  final String message;

  factory MediaUploadException.tooLarge(
    List<String> fileNames,
    String limitLabel,
  ) {
    if (fileNames.length == 1) {
      return MediaUploadException(
        '${fileNames.first} is larger than $limitLabel. '
        'Please choose a smaller file.',
      );
    }
    return MediaUploadException(
      '${fileNames.length} files are larger than $limitLabel. '
      'Please choose smaller files.',
    );
  }

  @override
  String toString() => message;
}
