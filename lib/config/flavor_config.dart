/// Flavor configuration for different build environments
enum Flavor {
  dev,
  staging,
  production,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String appName;
  final String packageId;
  final bool enableLogging;
  
  static FlavorConfig? _instance;
  
  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required String appName,
    required String packageId,
    bool enableLogging = false,
  }) {
    _instance ??= FlavorConfig._internal(
      flavor,
      name,
      appName,
      packageId,
      enableLogging,
    );
    return _instance!;
  }
  
  FlavorConfig._internal(
    this.flavor,
    this.name,
    this.appName,
    this.packageId,
    this.enableLogging,
  );
  
  static FlavorConfig get instance {
    return _instance!;
  }
  
  static bool get isDevelopment => _instance?.flavor == Flavor.dev;
  static bool get isStaging => _instance?.flavor == Flavor.staging;
  static bool get isProduction => _instance?.flavor == Flavor.production;
}
