import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../../core/errors/api_exception.dart';
import '../../core/storage/token_store.dart';
import '../../core/storage/secure_token_store.dart';

class CustomerSessionController extends ChangeNotifier {
  final ApiClient transport;
  final TokenStore store;
  Json? _session;
  Json? user;
  bool profileLoaded = false;
  int _generation = 0;
  Future<void>? _refreshing;
  int? _refreshEpoch;
  Future<void> _storageQueue = Future.value();
  CustomerSessionController({
    required String baseUrl,
    http.Client? client,
    TokenStore? store,
  }) : transport = ApiClient(baseUrl: baseUrl, client: client),
       store = store ?? SecureTokenStore();
  bool get signedIn => _session != null;
  bool get verified => user?['emailVerified'] == true;

  Future<void> _persist(int epoch) {
    final task = _storageQueue.catchError((Object _) {}).then((_) async {
      if (epoch != _generation) return;
      if (_session == null) {
        await store.clear();
      } else {
        await store.write(jsonEncode(_session));
      }
    });
    _storageQueue = task;
    return task;
  }

  Future<Json> request(
    String method,
    String path, {
    Json? body,
    bool authenticated = true,
  }) async {
    final epoch = _generation;
    final token = _session?['accessToken'] as String?;
    if (authenticated && token == null) {
      throw ApiException('Vui lòng đăng nhập.', status: 401);
    }
    try {
      final result = await transport.send(
        method,
        path,
        body,
        authenticated ? token : null,
      );
      if (authenticated && epoch != _generation) {
        throw ApiException('Phiên đăng nhập đã thay đổi.');
      }
      return result;
    } on ApiException catch (error) {
      if (!authenticated || error.status != 401 || epoch != _generation) {
        rethrow;
      }
      if (_session?['accessToken'] == token) await _refresh(epoch);
      if (epoch != _generation || _session == null) {
        throw ApiException('Phiên đăng nhập đã kết thúc.', status: 401);
      }
      final result = await transport.send(
        method,
        path,
        body,
        _session!['accessToken'] as String,
      );
      if (epoch != _generation) {
        throw ApiException('Phiên đăng nhập đã thay đổi.');
      }
      return result;
    }
  }

  Future<void> _refresh(int epoch) async {
    if (epoch != _generation) {
      throw ApiException('Phiên đăng nhập đã thay đổi.');
    }
    if (_refreshing != null && _refreshEpoch == epoch) return _refreshing;
    final future = () async {
      try {
        final refresh = _session?['refreshToken'];
        if (refresh == null) {
          throw ApiException('Vui lòng đăng nhập lại.', status: 401);
        }
        final next = await transport.send('POST', 'auth/refresh', {
          'refreshToken': refresh,
        }, null);
        _validateSession(next);
        if (epoch != _generation) return;
        _session = next;
        await _persist(epoch);
      } on ApiException catch (error) {
        if (epoch == _generation && [400, 401, 403].contains(error.status)) {
          await clear();
        }
        rethrow;
      }
    }();
    _refreshing = future;
    _refreshEpoch = epoch;
    try {
      await future;
    } finally {
      if (identical(_refreshing, future)) {
        _refreshing = null;
        _refreshEpoch = null;
      }
    }
  }

  void _validateSession(Json data) {
    if (data['accountGroup'] != 'Customer' ||
        data['accessToken'] is! String ||
        data['refreshToken'] is! String) {
      throw ApiException(
        'Ứng dụng chỉ dành cho tài khoản khách hàng.',
        status: 403,
      );
    }
  }

  Future<void> restore() async {
    final epoch = _generation;
    String? raw;
    try {
      raw = await store.read();
    } catch (_) {
      throw ApiException(
        'Không đọc được phiên đã lưu. Bạn có thể đăng nhập lại.',
      );
    }
    if (epoch != _generation) return;
    if (raw == null) return;
    try {
      final saved = jsonDecode(raw) as Json;
      _validateSession(saved);
      _session = saved;
    } catch (_) {
      await clear();
      return;
    }
    await load();
  }

  Future<void> authenticate(String action, Json body) async {
    final epoch = ++_generation;
    final result = await transport.send('POST', 'auth/$action', {
      ...body,
      'accountGroup': 'Customer',
    }, null);
    _validateSession(result);
    if (epoch != _generation) return;
    _session = result;
    user = result;
    profileLoaded = false;
    try {
      await _persist(epoch);
    } catch (_) {
      await clear();
      throw ApiException('Không lưu được phiên an toàn. Vui lòng thử lại.');
    }
    notifyListeners();
    await load();
  }

  Future<void> load() async {
    final epoch = _generation;
    final current = await request('GET', 'auth/me');
    if (current['accountGroup'] != 'Customer') {
      await clear();
      throw ApiException('Tài khoản không thuộc nhóm khách hàng.');
    }
    if (epoch != _generation) return;
    user = current;
    profileLoaded = true;
    notifyListeners();
  }

  Future<void> publicAction(String action, Json body) async {
    await request(
      'POST',
      'auth/$action',
      body: {...body, 'accountGroup': 'Customer'},
      authenticated: false,
    );
  }

  Future<void> verify(String code) async {
    await publicAction('verify-email', {'email': user!['email'], 'code': code});
    await load();
  }

  Future<void> logout() async {
    // Await an in-flight rotation before revoking the newest refresh token.
    final epoch = _generation;
    try {
      if (_refreshEpoch == epoch) await _refreshing;
    } catch (_) {}
    if (epoch != _generation) return;
    try {
      if (_session == null) return;
      try {
        await transport.send('POST', 'auth/logout', {
          'refreshToken': _session!['refreshToken'],
        }, _session!['accessToken'] as String);
      } on ApiException catch (error) {
        if (error.status != 401) rethrow;
        await _refresh(epoch);
        if (epoch == _generation && _session != null) {
          await transport.send('POST', 'auth/logout', {
            'refreshToken': _session!['refreshToken'],
          }, _session!['accessToken'] as String);
        }
      }
    } finally {
      if (epoch == _generation) await clear();
    }
  }

  Future<void> clear() async {
    final epoch = ++_generation;
    _session = null;
    user = null;
    profileLoaded = false;
    notifyListeners();
    try {
      await _persist(epoch);
    } catch (_) {
      throw ApiException(
        'Đã kết thúc phiên. Không xóa được dữ liệu lưu trên thiết bị.',
      );
    }
  }

  @override
  void dispose() {
    transport.dispose();
    super.dispose();
  }
}
