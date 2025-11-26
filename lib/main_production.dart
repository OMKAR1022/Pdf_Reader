import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main.dart' as app;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig(
    flavor: Flavor.production,
    name: 'PROD',
    appName: 'Free PDF Maker',
    packageId: 'com.freepdfmaker',
    enableLogging: false,
  );
  
  app.main();
}
