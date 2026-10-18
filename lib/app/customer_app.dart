import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:transconnect_customer_app/shared/theme/app_theme.dart';
import 'package:transconnect_customer_app/app/navigation/customer_shell.dart';
import 'package:transconnect_customer_app/app/session/customer_session_controller.dart';

class CustomerApp extends StatelessWidget {
  final CustomerSessionController api;
  const CustomerApp({super.key, required this.api});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VIEGO',
    debugShowCheckedModeBanner: false,
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(),
    home: CustomerShell(api: api),
  );
}
