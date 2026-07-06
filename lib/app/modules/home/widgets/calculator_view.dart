import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home_controller.dart';
import '../../../controllers/tip_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/values/app_constants.dart';
import '../../../widgets/update_dialog.dart';
import 'bill_input.dart';
import 'tip_selector.dart';
import 'people_counter.dart';
import 'unequal_split.dart';
import 'result_card.dart';
import 'action_buttons.dart';

class CalculatorView extends GetView<HomeController> {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final tipController = Get.find<TipController>();
    final themeController = Get.find<ThemeController>();

    // Show optional update dialog if received from Splash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Object? args = Get.arguments;
      if (args is Map) {
        final optionalUpdate = args['optionalUpdate'];
        if (optionalUpdate != null) {
          _showOptionalUpdateDialog(optionalUpdate);
          try {
            args.remove('optionalUpdate');
          } catch (e) {
            debugPrint('Error removing optionalUpdate argument: $e');
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: AppSizes.iconXL,
            ),
            SizedBox(width: AppSizes.paddingM),
            Text('app_title'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Obx(() => Icon(themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode)),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            const BillInput(),
            SizedBox(height: AppSizes.paddingXXL),
            const TipSelector(),
            SizedBox(height: AppSizes.paddingXXL),
            const PeopleCounter(),
            SizedBox(height: AppSizes.paddingXXL),
            
            // Unequal Split Toggle
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('custom_split'.tr, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.bold)),
                Switch(
                  value: tipController.isCustomSplit.value,
                  onChanged: (val) => tipController.isCustomSplit.value = val,
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            )),
            
            Obx(() => tipController.isCustomSplit.value 
                ? const UnequalSplit() 
                : const SizedBox.shrink()),
            
            SizedBox(height: AppSizes.paddingXXL),
            
            Screenshot(
              controller: controller.screenshotController,
              child: const ResultCard(),
            ),
            
            SizedBox(height: AppSizes.paddingXXL),
            const ActionButtons(),
            SizedBox(height: AppSizes.paddingXXL * 1.5),
          ],
        ),
      ),
    );
  }

  void _showOptionalUpdateDialog(dynamic info) {
    Get.dialog(
      UpdateDialog(
        updateMessage: info.updateMessage,
        onUpdate: () async {
          final url = Uri.parse(info.playStoreUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
