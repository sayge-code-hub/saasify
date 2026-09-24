import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:saasify/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Path URLs (/ticketing) instead of hash (/#/ticketing) for predictable deep links.
  usePathUrlStrategy();
  runApp(const SaasifyApp());
}
