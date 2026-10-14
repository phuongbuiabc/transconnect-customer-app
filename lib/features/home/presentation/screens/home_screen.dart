import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/app/theme/app_theme.dart';
import 'package:transconnect_customer_app/shared/widgets/panel.dart';
import 'package:transconnect_customer_app/features/home/presentation/widgets/service_card.dart';
import 'package:transconnect_customer_app/app/session/customer_session_controller.dart';

class HomeScreen extends StatelessWidget {
  final CustomerSessionController api;
  final VoidCallback onOpenAccount;
  const HomeScreen({super.key, required this.api, required this.onOpenAccount});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Xin chào, ' + (api.user?['fullName'] as String? ?? 'bạn'),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE52027), Color(0xFFC01218)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.explore_outlined, color: gold, size: 44),
            SizedBox(height: 24),
            Text(
              'Kết nối những\nhành trình Việt',
              style: TextStyle(
                fontSize: 28,
                height: 1.2,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Khám phá định hướng dịch vụ VIEGO, đồng hành cùng bạn trên mỗi chặng đường.',
              style: TextStyle(color: Colors.white, height: 1.5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Khám phá dịch vụ',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        'Các dịch vụ đang được phát triển. Hiện chưa mở đặt chuyến.',
        style: TextStyle(height: 1.5, color: Color(0xFF636366)),
      ),
      const SizedBox(height: 16),
      const ServiceCard(
        icon: Icons.directions_bus_outlined,
        title: 'Xe khách',
        description:
            'Kết nối hành khách trên các tuyến cố định và hành trình liên tuyến.',
      ),
      const ServiceCard(
        icon: Icons.local_shipping_outlined,
        title: 'Xe tải chở hàng',
        description:
            'Định hướng vận chuyển hàng hóa theo chuyến hoặc ghép tải.',
      ),
      const ServiceCard(
        icon: Icons.airport_shuttle_outlined,
        title: 'Xe hợp đồng',
        description:
            'Định hướng thuê xe trọn chuyến cho gia đình, nhóm và doanh nghiệp.',
      ),
      if (!api.verified) ...[
        const SizedBox(height: 8),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hoàn tất tài khoản',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Xác thực email để hoàn tất thông tin đăng ký.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onOpenAccount,
                child: const Text('Xác thực ngay'),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
