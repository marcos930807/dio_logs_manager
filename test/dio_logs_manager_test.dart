import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_logs_manager/dio_logs_manager.dart';
import 'package:dio_logs_manager/src/data/logs_pool.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns a canned response without touching the network, so the interceptor
/// chain runs exactly as it would against a real server.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 200});

  final int statusCode;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"ok":true}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Dio _dioWith(DioLogInterceptor interceptor, {int statusCode = 200}) {
  return Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = _FakeAdapter(statusCode: statusCode)
    ..interceptors.add(interceptor);
}

void main() {
  setUp(() => LogPoolManager.getInstance().clear());

  group('DioLogInterceptor', () {
    // Regression: dio 5.11.0 dispatches through the private
    // Interceptor._invokeRequest. A class declared `implements Interceptor`
    // cannot inherit it and blew up at runtime with NoSuchMethodError.
    test('completes a request and records it', () async {
      final dio = _dioWith(DioLogInterceptor());

      final response = await dio.get<dynamic>('/ping');

      expect(response.statusCode, 200);
      final pool = LogPoolManager.getInstance();
      expect(pool.logMapNotifier.length, 1);
      expect(pool.keys.length, 1);

      final logged = pool.logMapNotifier.value[pool.keys.first]!;
      expect(logged.reqOptions!.method, 'GET');
      expect(logged.reqOptions!.url, contains('/ping'));
      expect(logged.resOptions!.statusCode, 200);
      expect(logged.resOptions!.duration, isNotNull);
    });

    test('records the error branch without throwing', () async {
      final dio = _dioWith(DioLogInterceptor(), statusCode: 500);

      await expectLater(
        dio.get<dynamic>('/boom'),
        throwsA(isA<DioException>()),
      );

      final pool = LogPoolManager.getInstance();
      expect(pool.logMapNotifier.length, 1);
      final logged = pool.logMapNotifier.value[pool.keys.first]!;
      expect(logged.errOptions, isNotNull);
      expect(logged.resOptions!.statusCode, 500);
    });
  });

  group('LogPoolManager', () {
    test('evicts down to maxCount and keeps keys in sync with the map',
        () async {
      final dio = _dioWith(DioLogInterceptor(maxLogCount: 3));

      for (var i = 0; i < 6; i++) {
        await dio.get<dynamic>('/req$i');
      }

      final pool = LogPoolManager.getInstance();
      expect(pool.logMapNotifier.length, lessThanOrEqualTo(3));
      expect(pool.keys.length, pool.logMapNotifier.length);
      // Every tracked key must still resolve; LogsPage indexes the map by them.
      for (final key in pool.keys) {
        expect(pool.logMapNotifier.value[key], isNotNull);
      }
    });

    test('clear() notifies listeners so the UI refreshes', () async {
      final dio = _dioWith(DioLogInterceptor());
      await dio.get<dynamic>('/ping');

      final pool = LogPoolManager.getInstance();
      var notified = 0;
      void listener() => notified++;
      pool.logMapNotifier.addListener(listener);
      addTearDown(() => pool.logMapNotifier.removeListener(listener));

      pool.clear();

      expect(notified, greaterThan(0));
      expect(pool.logMapNotifier.length, 0);
      expect(pool.keys, isEmpty);
    });
  });
}
