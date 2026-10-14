import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/app/session/customer_session_controller.dart';
import 'package:transconnect_customer_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:transconnect_customer_app/features/home/presentation/screens/home_screen.dart';
import 'package:transconnect_customer_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:transconnect_customer_app/features/account/presentation/screens/account_screen.dart';
import 'package:transconnect_customer_app/shared/widgets/brand.dart';
import 'package:transconnect_customer_app/shared/widgets/notice.dart';

class CustomerShell extends StatefulWidget {
  final CustomerSessionController api;
  const CustomerShell({super.key, required this.api});
  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  bool starting = true, loading = false;
  String? error;
  int tab = 0;
  @override
  void initState() {
    super.initState();
    widget.api.addListener(changed);
    restore();
  }

  @override
  void dispose() {
    widget.api.removeListener(changed);
    super.dispose();
  }

  void changed() {
    if (mounted) setState(() {});
  }

  Future<void> restore() async {
    try {
      await widget.api.restore();
    } catch (e) {
      error = e.toString();
    }
    if (mounted) setState(() => starting = false);
  }

  Future<void> reload() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await widget.api.load();
      if (mounted) setState(() => error = null);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có thể đăng nhập lại bất cứ lúc nào.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.logout();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Phiên trên thiết bị đã xóa. Chưa xác nhận thu hồi phiên ở máy chủ.',
            ),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        tab = 0;
        error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    if (starting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!api.signedIn) return AuthScreen(api: api, initialMessage: error);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: RefreshIndicator(
              onRefresh: reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      const Brand(),
                      const Spacer(),
                      IconButton(
                        onPressed: loading ? null : reload,
                        tooltip: 'Làm mới tài khoản',
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (loading) const LinearProgressIndicator(),
                  if (error != null) ...[
                    Notice(error!, failure: true),
                    TextButton(onPressed: reload, child: const Text('Thử lại')),
                    const SizedBox(height: 16),
                  ],
                  if (!api.profileLoaded)
                    const Notice(
                      'Chưa tải được tài khoản. Hãy kiểm tra kết nối và thử lại.',
                    ),
                  if (tab == 0)
                    HomeScreen(
                      api: api,
                      onOpenAccount: () => setState(() => tab = 2),
                    )
                  else if (tab == 1)
                    const OrdersScreen()
                  else
                    AccountScreen(api: api, onLogout: logout),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: NavigationBar(
                backgroundColor: Colors.white.withValues(alpha: .9),
                selectedIndex: tab,
                onDestinationSelected: (v) => setState(() => tab = v),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    label: 'Trang chủ',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    label: 'Đơn của tôi',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    label: 'Tài khoản',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
