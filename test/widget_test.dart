import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_customer_app/app/session/customer_session_controller.dart';
import 'package:transconnect_customer_app/core/storage/token_store.dart';
import 'package:transconnect_customer_app/app/customer_app.dart';

class MemoryStore implements TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async {
    value = v;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  testWidgets('customer home and orders fit a small phone', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = {
      'accountGroup': 'Customer',
      'accessToken': 'a',
      'refreshToken': 'r',
      'fullName': 'Khách hàng',
      'email': 'customer@example.test',
      'emailVerified': true,
    };
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: MemoryStore()..value = jsonEncode(data),
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode({'succeeded': true, 'data': data}), 200),
      ),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(CustomerApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Đơn của tôi'));
    await tester.pumpAndSettle();
    expect(find.text('Đặt chuyến chưa mở'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('unauthenticated app presents customer registration', (
    tester,
  ) async {
    final api = CustomerSessionController(
      baseUrl: 'https://example.test',
      store: MemoryStore(),
      client: MockClient((_) async => http.Response('{}', 500)),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(CustomerApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Chưa có tài khoản? Đăng ký ngay'), findsOneWidget);
  });
}
