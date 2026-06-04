import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/features/profile/model/edit_profile_model.dart';

void main() {
  group('EditProfileModel.toJson', () {
    test(
        'omits artisan_gallery_images when null so a normal profile edit '
        'never touches the gallery', () {
      final json = EditProfileModel(
        phoneNumber: '2347011002935',
        firstName: 'Tee',
        lastName: 'Dee',
      ).toJson();

      expect(json.containsKey('artisan_gallery_images'), isFalse);
      expect(json['phone_number'], '2347011002935');
      expect(json['first_name'], 'Tee');
      expect(json['last_name'], 'Dee');
    });

    test('includes an empty artisan_gallery_images array (clears the gallery)',
        () {
      final json = EditProfileModel(artisanGalleryImages: const []).toJson();

      expect(json.containsKey('artisan_gallery_images'), isTrue);
      expect(json['artisan_gallery_images'], isEmpty);
    });

    test('includes populated artisan_gallery_images', () {
      final urls = [
        'https://res.cloudinary.com/tivitea/image/upload/v1/a.jpg',
        'https://res.cloudinary.com/tivitea/video/upload/v1/b.mp4',
      ];
      final json =
          EditProfileModel(artisanGalleryImages: urls).toJson();

      expect(json['artisan_gallery_images'], urls);
    });
  });

  group('EditProfileModel.fromJson', () {
    test('parses artisan_gallery_images', () {
      final model = EditProfileModel.fromJson(<String, dynamic>{
        'phone_number': '2347011002935',
        'profile_picture': '',
        'artisan_gallery_images': ['https://x.com/a.jpg'],
        'first_name': 'Tee',
        'last_name': 'Dee',
      });

      expect(model.artisanGalleryImages, ['https://x.com/a.jpg']);
      expect(model.phoneNumber, '2347011002935');
    });

    test('tolerates a missing artisan_gallery_images key', () {
      final model = EditProfileModel.fromJson(<String, dynamic>{
        'first_name': 'Tee',
      });

      expect(model.artisanGalleryImages, isNull);
      expect(model.firstName, 'Tee');
    });
  });
}
