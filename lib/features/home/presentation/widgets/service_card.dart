import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/shared/theme/app_theme.dart';
import 'package:transconnect_customer_app/shared/widgets/panel.dart';

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title, description;
  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDECEC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: red, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(height: 1.5, color: Color(0xFF636366)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đang phát triển',
                  style: TextStyle(
                    color: red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
