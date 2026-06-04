import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/utils/image_picker_util.dart';

part 'room_image_selector_notifier.g.dart';

@riverpod
class RoomImageSelectorNotifier extends _$RoomImageSelectorNotifier {
  @override
  List<XFile> build() => [];

  Future<XFile?> selectSingleImage({ImageSource source = ImageSource.gallery}) async {
    final result = await ImagePickerUtil.pickSingleImage(source);
    if (result == null) return null;
    return result;
  }

  void selectImages({ImageSource source = ImageSource.gallery}) async {
    final results = await ImagePickerUtil.pickImages(source);
    state = [...state, ...results];
  }

  /// Picks multiple images and/or videos from the gallery.
  void selectMedia() async {
    final results = await ImagePickerUtil.pickMultipleMedia();
    state = [...state, ...results];
  }

  /// Picks a single video from [source].
  void selectVideo({ImageSource source = ImageSource.camera}) async {
    final result = await ImagePickerUtil.pickVideo(source);
    if (result == null) return;
    state = [...state, result];
  }

  void deleteImage(String imagePath) {
    state = state.where((path) => path.path != imagePath).toList();
  }

  void clearMedia() {
    state = [];
  }
}
