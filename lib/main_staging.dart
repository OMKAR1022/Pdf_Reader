import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main.dart' as app;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig(
    flavor: Flavor.staging,
    name: 'STAGING',
    appName: 'PDF Maker Staging',
    packageId: 'com.freepdfmaker.staging',
    enableLogging: true,
  );
  
  app.main();
}
