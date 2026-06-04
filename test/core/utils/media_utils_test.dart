import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/core/utils/media_utils.dart';

void main() {
  group('MediaUtils.isVideo', () {
    test('detects common video extensions (case-insensitive)', () {
      expect(MediaUtils.isVideo('/tmp/clip.mp4'), isTrue);
      expect(MediaUtils.isVideo('/tmp/clip.MOV'), isTrue);
      expect(MediaUtils.isVideo('movie.webm'), isTrue);
      expect(MediaUtils.isVideo('a/b/c.MkV'), isTrue);
    });

    test('detects videos on remote Cloudinary URLs', () {
      expect(
        MediaUtils.isVideo(
          'https://res.cloudinary.com/tivitea/video/upload/v1/abc.mp4',
        ),
        isTrue,
      );
    });

    test('returns false for images', () {
      expect(MediaUtils.isVideo('/tmp/photo.jpg'), isFalse);
      expect(MediaUtils.isVideo('photo.PNG'), isFalse);
      expect(
        MediaUtils.isVideo(
          'https://res.cloudinary.com/tivitea/image/upload/v1/abc.jpeg',
        ),
        isFalse,
      );
    });

    test('ignores query strings when reading the extension', () {
      expect(MediaUtils.isVideo('https://x.com/a.mp4?token=123'), isTrue);
      expect(MediaUtils.isVideo('https://x.com/a.jpg?token=123'), isFalse);
    });

    test('returns false when there is no extension', () {
      expect(MediaUtils.isVideo('https://x.com/noextension'), isFalse);
      expect(MediaUtils.isVideo('trailingdot.'), isFalse);
      expect(MediaUtils.isVideo(''), isFalse);
    });
  });

  group('MediaUtils.cloudinaryVideoThumbnail', () {
    test('swaps a video extension for .jpg', () {
      expect(
        MediaUtils.cloudinaryVideoThumbnail(
          'https://res.cloudinary.com/tivitea/video/upload/v1/abc.mp4',
        ),
        'https://res.cloudinary.com/tivitea/video/upload/v1/abc.jpg',
      );
    });

    test('drops the query string while swapping', () {
      expect(
        MediaUtils.cloudinaryVideoThumbnail('https://x.com/a.mov?token=123'),
        'https://x.com/a.jpg',
      );
    });

    test('returns the original url when there is no extension', () {
      expect(
        MediaUtils.cloudinaryVideoThumbnail('https://x.com/noextension'),
        'https://x.com/noextension',
      );
    });
  });
}
