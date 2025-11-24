import 'config/flavor_config.dart';
import 'main.dart' as app;

void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    appName: 'PDF Maker Dev',
    packageId: 'com.freepdfmaker.dev',
    enableLogging: true,
  );
  
  app.main();
}
