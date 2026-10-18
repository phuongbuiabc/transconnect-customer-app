import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/shared/theme/app_theme.dart';
import 'package:transconnect_customer_app/shared/widgets/panel.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => const Panel(
    child: Column(
      children: [
        Icon(Icons.confirmation_number_outlined, size: 56, color: red),
        SizedBox(height: 20),
        Text(
          'Đặt chuyến chưa mở',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 12),
        Text(
          'VIEGO đang phát triển tính năng đặt chuyến và quản lý đơn. Hiện ứng dụng hỗ trợ tài khoản và xác thực email.',
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.5),
        ),
      ],
    ),
  );
}
