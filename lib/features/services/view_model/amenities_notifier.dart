import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/features/services/model/amenity_model.dart';

part 'amenities_notifier.g.dart';

@riverpod
class AmenitiesNotifier extends _$AmenitiesNotifier {
  /// Unselected by default — the submit path only sends amenities whose
  /// [AmenityModel.isSelected] is true, so pre-selecting these would attach
  /// all of them to every new listing regardless of what the user ticked.
  final List<AmenityModel> _defaultAmenities = [
    AmenityModel(label: '24 hours Electricity', isSelected: false),
    AmenityModel(label: 'Parking', isSelected: false),
    AmenityModel(label: 'Wifi', isSelected: false),
    AmenityModel(label: 'CCTV', isSelected: false),
    AmenityModel(label: 'Cafeteria', isSelected: false),
  ];
  @override
  List<AmenityModel> build() => _defaultAmenities;

  void toggleAmenity(String label) {
    state = state
        .map((amenity) => amenity.label == label
            ? amenity.copyWith(isSelected: !amenity.isSelected)
            : amenity)
        .toList();
  }

  void addNewAmenityFromList(List<String> newAmenities) {
    state = [
      ...state,
      ...newAmenities.map(
        (amenity) => AmenityModel(label: amenity, isSelected: true),
      )
    ];
  }

  void addNewAmenity(String newAmenity) {
    if (state.any((amenity) => amenity.label == newAmenity)) {
      return;
    }
    state = [...state, AmenityModel(label: newAmenity, isSelected: true)];
  }

  void removeAmenity(String label) {
    if (_defaultAmenities.any((amenity) => amenity.label == label)) {
      return;
    }
    state = state.where((amenity) => amenity.label != label).toList();
  }

  void initializeWithSelectedAmenities(List<String> selectedAmenities) {
    // Reset to default amenities with proper selection state
    state = _defaultAmenities
        .map((amenity) => amenity.copyWith(
              isSelected: selectedAmenities.contains(amenity.label),
            ))
        .toList();

    // Add any custom amenities from the selected listing
    final customAmenities = selectedAmenities
        .where((amenity) => !_defaultAmenities.any((defaultAmenity) => defaultAmenity.label == amenity))
        .toList();

    if (customAmenities.isNotEmpty) {
      addNewAmenityFromList(customAmenities);
    }
  }
}
