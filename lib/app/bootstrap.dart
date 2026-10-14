import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/core/config/app_config.dart';
import 'package:transconnect_customer_app/app/session/customer_session_controller.dart';
import 'package:transconnect_customer_app/app/customer_app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _CustomerBootstrap());
}

class _CustomerBootstrap extends StatefulWidget {
  const _CustomerBootstrap();
  @override
  State<_CustomerBootstrap> createState() => _CustomerBootstrapState();
}

class _CustomerBootstrapState extends State<_CustomerBootstrap> {
  late final CustomerSessionController controller;
  @override
  void initState() {
    super.initState();
    controller = CustomerSessionController(baseUrl: AppConfig.apiBaseUrl);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomerApp(api: controller);
}
