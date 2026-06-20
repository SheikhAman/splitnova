import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../routes/app_pages.dart';
import '../../services/firebase_service.dart';
import '../../services/app_update_service.dart';
import '../config_screens/views/maintenance_view.dart';
import '../config_screens/views/force_update_view.dart';

class SplashController extends GetxController {
  final _firebaseService = Get.find<FirebaseService>();
  final _updateService = Get.put(AppUpdateService());

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 1. Fetch/Refresh data in the background (with timeout in service)
      // This will update the in-memory config in FirebaseService
      await _firebaseService.refreshConfigs().catchError((e) {
        debugPrint('Splash - Silent Refresh Error: $e');
      });
      
      final appConfig = _firebaseService.appConfig;
      
      if (appConfig != null) {
        // 2. Check Maintenance Mode
        if (appConfig.maintenance) {
          Get.offAll(() => MaintenanceView(message: appConfig.maintenanceMessage));
          return;
        }

        // 3. Check for Updates
        final updateInfo = await _updateService.checkForUpdate(appConfig);
        
        // Ensure minimum branding visibility (1.5 seconds)
        final elapsed = stopwatch.elapsedMilliseconds;
        if (elapsed < 1500) {
          await Future.delayed(Duration(milliseconds: 1500 - elapsed));
        }

        if (updateInfo.status == UpdateStatus.forceUpdate) {
          Get.offAll(() => ForceUpdateView(
            message: updateInfo.updateMessage,
            playStoreUrl: updateInfo.playStoreUrl,
          ));
          return;
        } else if (updateInfo.status == UpdateStatus.optionalUpdate) {
          Get.offAllNamed(Routes.HOME, arguments: {'optionalUpdate': updateInfo});
          return;
        }
      }
    } catch (e) {
      debugPrint('SplashController Error: $e');
    }

    // Fallback/Default path
    final remaining = 1500 - stopwatch.elapsedMilliseconds;
    if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));
    Get.offAllNamed(Routes.HOME);
  }
}
