import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/app/theme/app_theme.dart';
import 'package:transconnect_customer_app/shared/widgets/panel.dart';
import 'package:transconnect_customer_app/app/session/widgets/email_verification.dart';
import 'package:transconnect_customer_app/app/session/customer_session_controller.dart';

class AccountScreen extends StatelessWidget {
  final CustomerSessionController api;
  final VoidCallback onLogout;
  const AccountScreen({super.key, required this.api, required this.onLogout});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.account_circle_outlined, size: 52, color: red),
            const SizedBox(height: 16),
            Text(
              api.user?['fullName'] as String? ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'EMAIL',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: Color(0xFF636366),
              ),
            ),
            SelectableText(api.user?['email'] as String? ?? ''),
            const SizedBox(height: 16),
            const Text(
              'SỐ ĐIỆN THOẠI',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: Color(0xFF636366),
              ),
            ),
            Text(api.user?['phoneNumber'] as String? ?? 'Chưa cung cấp'),
            const SizedBox(height: 16),
            Chip(
              avatar: Icon(
                api.verified ? Icons.verified_outlined : Icons.mail_outline,
              ),
              label: Text(
                api.verified ? 'Email đã xác thực' : 'Email chưa xác thực',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      if (!api.verified && api.user != null) EmailVerification(api: api),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Đăng xuất'),
      ),
    ],
  );
}
