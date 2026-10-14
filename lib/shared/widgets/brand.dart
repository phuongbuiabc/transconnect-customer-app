import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/app/theme/app_theme.dart';

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        backgroundColor: red,
        child: Icon(Icons.route, color: gold),
      ),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIEGO',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          Text(
            'Hành trình Việt',
            style: TextStyle(fontSize: 11, color: Color(0xFF636366)),
          ),
        ],
      ),
    ],
  );
}
