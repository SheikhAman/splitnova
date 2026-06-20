import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/firebase_service.dart';
import '../../services/app_update_service.dart';
import '../../data/models/config_models.dart';
import '../../controllers/tip_controller.dart';
import '../../widgets/update_dialog.dart';
import '../../core/values/app_constants.dart';
import '../config_screens/views/force_update_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsController extends GetxController {
  final _firebaseService = Get.find<FirebaseService>();
  final _updateService = Get.find<AppUpdateService>();
  final tipController = Get.find<TipController>();

  final RxMap configs = {}.obs;
  final RxBool isLoading = false.obs;
  final RxString appVersion = '1.0.0'.obs;
  final Rx<UpdateStatus> updateStatus = UpdateStatus.noUpdate.obs;

  // Observable settings from TipController
  late RxDouble defaultTip;
  late RxInt defaultPeople;

  @override
  void onInit() {
    super.onInit();
    defaultTip = tipController.defaultTip;
    defaultPeople = tipController.defaultPeople;
    _initializeData();
  }

  void _initializeData() {
    // 1. Set version immediately
    _firebaseService.getAppVersion().then((v) => appVersion.value = v);

    // 2. Use data already fetched by FirebaseService (from splash or cache)
    _syncConfigs();
    
    // Listen for background updates from FirebaseService if any
    ever(_firebaseService.supportConfig.obs, (_) => _syncConfigs());
  }

  void _syncConfigs() {
    final support = _firebaseService.supportConfig;
    if (support != null) {
      configs['donation'] = support.donation;
      configs['social'] = support.social;
      configs['contact'] = support.contact;
      configs['about'] = support.about;
    }
    
    final app = _firebaseService.appConfig;
    if (app != null) {
      configs['app'] = app;
    }
  }

  /// Manually refresh data if user wants to, but without a full-screen block
  Future<void> refreshSettings() async {
    try {
      await _firebaseService.refreshConfigs();
      _syncConfigs();
    } catch (e) {
      // Silent fail for background refresh
    }
  }

  void shareApp() {
    final AppConfig? app = configs['app'];
    if (app != null && app.playStoreUrl.isNotEmpty) {
      final String message = '${'share_app_message'.tr}\n\n${app.playStoreUrl}';
      tipController.shareGeneral(message);
    } else {
      Get.snackbar('error'.tr, 'share_failed'.tr);
    }
  }

  void updateDefaultTip(double val) => tipController.updateDefaultTip(val);
  void updateDefaultPeople(int val) => tipController.updateDefaultPeople(val);
  void updateDefaultCurrency(String val) => tipController.updateDefaultCurrency(val);

  Future<void> launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_launch_url'.tr);
    }
  }

  Future<void> sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    launchURL(emailLaunchUri.toString());
  }

  void copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'success'.tr,
      'copied_to_clipboard'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkForUpdateManually() async {
    // Check internet first — no plugin needed
    final bool isConnected = await _hasInternetConnection();

    if (!isConnected) {
      _showToast('check_update_offline_message'.tr, AppColors.errorRed);
      return;
    }

    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await _firebaseService.refreshConfigs().timeout(const Duration(seconds: 5));

      final appConfig = _firebaseService.appConfig;
      final updateInfo = await _updateService.checkForUpdate(appConfig);

      if (Get.isDialogOpen ?? false) Get.back();

      if (updateInfo.status == UpdateStatus.noUpdate) {
        _showToast('up_to_date_message'.tr, Get.theme.primaryColor);
      } else if (updateInfo.status == UpdateStatus.forceUpdate) {
        Get.offAll(() => ForceUpdateView(
          message: updateInfo.updateMessage,
          playStoreUrl: updateInfo.playStoreUrl,
        ));
      } else {
        _showUpdateAvailableDialog(updateInfo);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showToast('check_update_offline_message'.tr, AppColors.errorRed);
    }
  }

  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: AppSizes.fontM,
    );
  }


  void _showUpdateAvailableDialog(UpdateInfo info) {
    Get.dialog(
      UpdateDialog(
        updateMessage: info.updateMessage,
        onUpdate: () => launchURL(info.playStoreUrl),
      ),
    );
  }
}
