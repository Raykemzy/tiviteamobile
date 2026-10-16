import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage.dart';
import 'package:tivi_tea/core/services/local_storage/storage_keys.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/repositories/authentication/general/general_authetication_repo.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';

class _MemoryStorage implements LocalStorage {
  final Map<String, dynamic> data = {};

  @override
  Future<void> put(dynamic key, dynamic value) async =>
      data[key.toString()] = value;
  @override
  dynamic get<T>(String key) => data[key];
  @override
  dynamic getAt(int key) => data.values.elementAt(key);
  @override
  Future<int> add(dynamic value) async {
    data[data.length.toString()] = value;
    return data.length - 1;
  }

  @override
  Future<void> clear() async => data.clear();
  @override
  Future<void> delete(dynamic key) async => data.remove(key.toString());
  @override
  Future<void> putAll(Map<String, dynamic> entries) async =>
      data.addAll(entries);
}

/// Answers every request with a fixed status and body.
class _FixedAdapter implements HttpClientAdapter {
  _FixedAdapter(this.status, this.body);
  final int status;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        body,
        status,
        headers: body.isEmpty
            ? {}
            : {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MemoryStorage storage;

  GeneralAuthenticationRepo repoAnswering(int status, String body) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _FixedAdapter(status, body);
    return GeneralAuthenticationRepo(
      restClient: RestClient(dio),
      userRepository: UserRepoImpl(storage),
    );
  }

  setUp(() async {
    storage = _MemoryStorage();
    await storage.put(HiveKeys.token, 'access');
    await storage.put(HiveKeys.refreshToken, 'refresh');
  });

  test('204 with no body is a successful deletion and clears the session',
      () async {
    final response = await repoAnswering(204, '').deleteAccount();

    expect(response.isSuccess(), isTrue);
    expect(storage.data, isEmpty);
  });

  test('200 with a JSON body is also a successful deletion', () async {
    final response = await repoAnswering(
      200,
      '{"code":200,"status":"Success","message":"Deleted","data":[]}',
    ).deleteAccount();

    expect(response.isSuccess(), isTrue);
    expect(storage.data, isEmpty);
  });

  test('a server error is reported and keeps the session', () async {
    final response = await repoAnswering(
      400,
      '{"code":400,"status":"Failed","message":"Invalid token","data":[]}',
    ).deleteAccount();

    expect(response.isSuccess(), isFalse);
    expect(storage.data[HiveKeys.token], 'access');
  });
}
