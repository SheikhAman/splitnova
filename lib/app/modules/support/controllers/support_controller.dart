import 'package:get/get.dart';
import '../../../services/firebase_service.dart';
import '../../../data/models/config_models.dart';
import '../../../core/values/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class SupportController extends GetxController {
  final _firebaseService = Get.find<FirebaseService>();
  
  final isLoading = true.obs;
  late SupportConfig config;
  final hasData = false.obs;

  @override
  void onInit() {
    super.onInit();
    config = SupportConfig.empty();
    fetchSupportConfig();
  }

  Future<void> fetchSupportConfig() async {
    isLoading.value = true;
    try {
      config = await _firebaseService.getSupportConfig();
      if (!config.isEmpty) {
        hasData.value = true;
      }
    } catch (e) {
      debugPrint('SupportController Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'could_not_launch_url'.tr);
    }
  }

  void copyToClipboard(String? text, String label) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: '$label ${'copied_to_clipboard'.tr}',
      backgroundColor: AppColors.successGreen,
    );
  }
}
