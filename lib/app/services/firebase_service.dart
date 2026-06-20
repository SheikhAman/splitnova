import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../data/models/config_models.dart';

class FirebaseService extends GetxService {
  FirebaseFirestore? _firestore;
  final GetStorage _storage = GetStorage();
  PackageInfo? _packageInfo;

  static const String _keyAppConfig = 'cached_app_config';
  static const String _keySupportConfig = 'cached_support_config';

  final _isInitialized = false.obs;
  bool get isReady => _isInitialized.value;

  // In-memory config storage
  final Rxn<AppConfig> _appConfig = Rxn<AppConfig>();
  final Rxn<SupportConfig> _supportConfig = Rxn<SupportConfig>();

  AppConfig? get appConfig => _appConfig.value;
  SupportConfig? get supportConfig => _supportConfig.value;

  @override
  void onInit() {
    super.onInit();
    // Load cache into memory immediately on startup
    _loadFromCache();
  }

  void _loadFromCache() {
    final cachedAppData = _storage.read(_keyAppConfig);
    if (cachedAppData != null) {
      _appConfig.value = AppConfig.fromMap(Map<String, dynamic>.from(cachedAppData));
    }
    
    final cachedSupportData = _storage.read(_keySupportConfig);
    if (cachedSupportData != null) {
      _supportConfig.value = SupportConfig.fromMap(Map<String, dynamic>.from(cachedSupportData));
    } else {
      _supportConfig.value = SupportConfig.empty();
    }
  }

  /// Ensures Firebase and local services are initialized before any operation
  Future<void> _ensureInitialized() async {
    if (_isInitialized.value) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _firestore = FirebaseFirestore.instance;
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized.value = true;
    } catch (e) {
      debugPrint('FirebaseService - Initialization Error: $e');
    }
  }

  /// Fetches and updates in-memory config from network
  Future<void> refreshConfigs() async {
    await _ensureInitialized();
    if (_firestore == null || _packageInfo == null) return;

    try {
      // Fetch in parallel for speed
      final results = await Future.wait([
        _firestore!.collection('apps').doc(_packageInfo!.packageName).get(),
        _firestore!.collection('config').doc('donation').get(),
        _firestore!.collection('config').doc('social').get(),
        _firestore!.collection('config').doc('contact').get(),
        _firestore!.collection('config').doc('about').get(),
      ]).timeout(const Duration(seconds: 10));

      // Update AppConfig
      if (results[0].exists && results[0].data() != null) {
        final config = AppConfig.fromMap(results[0].data()!);
        _appConfig.value = config;
        _storage.write(_keyAppConfig, config.toMap());
      }

      // Update SupportConfig
      final supportConfig = SupportConfig(
        donation: results[1].exists ? DonationConfig.fromMap(results[1].data()!) : DonationConfig.empty(),
        social: results[2].exists ? SocialConfig.fromMap(results[2].data()!) : SocialConfig.empty(),
        contact: results[3].exists ? ContactConfig.fromMap(results[3].data()!) : ContactConfig.empty(),
        about: results[4].exists ? AboutConfig.fromMap(results[4].data()!) : AboutConfig.empty(),
      );
      
      _supportConfig.value = supportConfig;
      _storage.write(_keySupportConfig, supportConfig.toMap());
      
    } catch (e) {
      debugPrint('FirebaseService - Refresh Error: $e');
      // If error (timeout/offline), we already have cache in memory, so no action needed.
      rethrow; // Re-throw to let callers handle (e.g. Splash or manual check)
    }
  }

  // Legacy support or specific fetches if needed
  Future<AppConfig?> getAppConfig() async {
    if (_appConfig.value == null) await _ensureInitialized();
    return _appConfig.value;
  }

  Future<SupportConfig> getSupportConfig() async {
    if (_supportConfig.value == null) await _ensureInitialized();
    return _supportConfig.value ?? SupportConfig.empty();
  }

  Future<String> getAppVersion() async {
    await _ensureInitialized();
    if (_packageInfo == null) return '1.0.0';
    return '${_packageInfo!.version}+${_packageInfo!.buildNumber}';
  }
}
