import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_store.dart';
import 'utils/connectivity_service.dart';
import 'services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStore.init();
  await ConnectivityService.instance.initialize();
  await PushService.instance.initialize();
  runApp(const IMetroApp());
}
