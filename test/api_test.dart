import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_customer_app/app/session/customer_session_controller.dart';
import 'package:transconnect_customer_app/core/network/json.dart';
import 'package:transconnect_customer_app/core/errors/api_exception.dart';
import 'widget_test.dart' show MemoryStore;

Json session(String token) => {
  'accessToken': token,
  'refreshToken': 'refresh-' + token,
  'accountGroup': 'Customer',
  'emailVerified': true,
  'email': 'customer@example.test',
  'fullName': 'Khách hàng',
};
http.Response ok(Json data) => http.Response(
  jsonEncode({'succeeded': true, 'data': data}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
http.Response failure(int status) => http.Response(
  jsonEncode({'succeeded': false, 'message': 'Failure'}),
  status,
);
void main() {
  test('simultaneous unauthorized requests rotate refresh once', () async {
    final store = MemoryStore()..value = jsonEncode(session('old'));
    var refreshes = 0;
    final gate = Completer<void>();
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient((r) async {
        if (r.url.path == '/auth/me') return ok(session('old'));
        if (r.url.path == '/auth/refresh') {
          refreshes++;
          await gate.future;
          return ok(session('new'));
        }
        return r.headers['Authorization'] == 'Bearer old'
            ? failure(401)
            : ok({'value': true});
      }),
    );
    addTearDown(api.dispose);
    await api.restore();
    final a = api.request('GET', 'protected');
    final b = api.request('GET', 'protected');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    gate.complete();
    await Future.wait([a, b]);
    expect(refreshes, 1);
    expect(jsonDecode(store.value!)['refreshToken'], 'refresh-new');
  });
  test('logout refreshes expired access and revokes rotated refresh', () async {
    final store = MemoryStore()..value = jsonEncode(session('old'));
    final revoked = <String>[];
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient((r) async {
        if (r.url.path == '/auth/me') return ok(session('old'));
        if (r.url.path == '/auth/refresh') return ok(session('new'));
        if (r.url.path == '/auth/logout') {
          if (r.headers['Authorization'] == 'Bearer old') return failure(401);
          revoked.add(jsonDecode(r.body)['refreshToken'] as String);
          return ok({});
        }
        return failure(500);
      }),
    );
    addTearDown(api.dispose);
    await api.restore();
    await api.logout();
    expect(revoked, ['refresh-new']);
    expect(store.value, isNull);
    expect(api.signedIn, isFalse);
  });
  test('late refresh cannot restore a cleared session', () async {
    final store = MemoryStore()..value = jsonEncode(session('old'));
    final gate = Completer<void>();
    final entered = Completer<void>();
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient((r) async {
        if (r.url.path == '/auth/me') return ok(session('old'));
        if (r.url.path == '/auth/refresh') {
          entered.complete();
          await gate.future;
          return ok(session('new'));
        }
        return failure(401);
      }),
    );
    addTearDown(api.dispose);
    await api.restore();
    final request = api.request('GET', 'protected');
    final assertion = expectLater(request, throwsA(isA<ApiException>()));
    await entered.future;
    await api.clear();
    gate.complete();
    await assertion;
    expect(api.signedIn, isFalse);
    expect(store.value, isNull);
  });

  test('stale logout unauthorized cannot rotate new login token', () async {
    final store = MemoryStore()..value = jsonEncode(session('old'));
    final entered = Completer<void>(), gate = Completer<void>();
    var refreshes = 0;
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient((r) async {
        if (r.url.path == '/auth/login') {
          expect(jsonDecode(r.body)['accountGroup'], 'Customer');
          return ok(session('new'));
        }
        if (r.url.path == '/auth/me') return ok(session('identity'));
        if (r.url.path == '/auth/logout') {
          entered.complete();
          await gate.future;
          return failure(401);
        }
        if (r.url.path == '/auth/refresh') {
          refreshes++;
          return ok(session('rotated'));
        }
        return failure(500);
      }),
    );
    addTearDown(api.dispose);
    await api.restore();
    final loggingOut = api.logout();
    final assertion = expectLater(loggingOut, throwsA(isA<ApiException>()));
    await entered.future;
    await api.authenticate('login', {
      'email': 'customer@example.test',
      'password': 'secret',
    });
    gate.complete();
    await assertion;
    expect(refreshes, 0);
    expect(api.signedIn, isTrue);
    expect(jsonDecode(store.value!)['refreshToken'], 'refresh-new');
  });
  test('wrong account group is refused and no session persisted', () async {
    final store = MemoryStore();
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient(
        (r) async => ok({...session('bad'), 'accountGroup': 'Operator'}),
      ),
    );
    addTearDown(api.dispose);
    await expectLater(
      api.authenticate('login', {
        'email': 'x@example.test',
        'password': 'secret',
      }),
      throwsA(isA<ApiException>()),
    );
    expect(api.signedIn, isFalse);
    expect(store.value, isNull);
  });
  test('temporary restore failure retains session for retry', () async {
    final store = MemoryStore()..value = jsonEncode(session('saved'));
    var fail = true;
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient(
        (r) async => fail ? failure(503) : ok(session('saved')),
      ),
    );
    addTearDown(api.dispose);
    await expectLater(api.restore(), throwsA(isA<ApiException>()));
    expect(api.signedIn, isTrue);
    expect(api.profileLoaded, isFalse);
    fail = false;
    await api.load();
    expect(api.profileLoaded, isTrue);
  });
}
