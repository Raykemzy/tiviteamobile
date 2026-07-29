import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/features/services/model/workspace_room_model.dart';

void main() {
  group('WorkspaceRoomModel.toJson', () {
    test('omits room_id for a new room', () {
      final json = WorkspaceRoomModel(
        name: 'studio 71 v1',
        description: 'a plain background studio',
        maxCapacity: 3,
        amount: 15000,
        features: const ['24 hours Electricity'],
        images: const ['https://example.com/a.png'],
      ).toJson();

      // Add-space rejects room_id; an empty string would still serialise, so
      // the id has to stay null rather than falling back to ''.
      expect(json.containsKey('room_id'), isFalse);
      expect(json['name'], 'studio 71 v1');
    });

    test('sends room_id when editing an existing room', () {
      final json = WorkspaceRoomModel(
        id: '2cd3ed87-5689-4c4b-bdc3-c3d84a331844',
        name: 'studio 71 v1',
      ).toJson();

      expect(json['room_id'], '2cd3ed87-5689-4c4b-bdc3-c3d84a331844');
    });

    test('an empty id would still serialise — guards the regression', () {
      final json = WorkspaceRoomModel(id: '', name: 'studio').toJson();

      expect(json['room_id'], '');
    });
  });
}
