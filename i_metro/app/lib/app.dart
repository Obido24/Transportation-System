import 'package:flutter/material.dart';

import 'app_messenger.dart';
import 'routes.dart';
import 'widgets/global_connectivity_overlay.dart';

class IMetroApp extends StatelessWidget {
  const IMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I-Metro',
      scaffoldMessengerKey: appMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E3B2E)),
        useMaterial3: true,
      ),
      builder: (context, child) => GlobalConnectivityOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
