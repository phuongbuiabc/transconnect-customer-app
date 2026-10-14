import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_store.dart';

class SecureTokenStore implements TokenStore {
  final FlutterSecureStorage storage;
  SecureTokenStore([this.storage = const FlutterSecureStorage()]);
  @override
  Future<String?> read() => storage.read(key: 'customer_session');
  @override
  Future<void> write(String value) =>
      storage.write(key: 'customer_session', value: value);
  @override
  Future<void> clear() => storage.delete(key: 'customer_session');
}
