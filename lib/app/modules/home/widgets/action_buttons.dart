import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../../../controllers/tip_controller.dart';
import '../home_controller.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActionButtons extends GetView<HomeController> {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final tipController = Get.find<TipController>();

    return Obx(() {
      final List<Map<String, dynamic>> buttons = [
        {
          'icon': Icons.refresh,
          'label': 'reset'.tr,
          'color': Colors.orange,
          'onTap': () => tipController.reset(),
        },
        {
          'icon': Icons.share,
          'label': 'share'.tr,
          'color': Colors.green,
          'onTap': () {
            if (tipController.validateBill()) {
              tipController.shareToWhatsApp();
            }
          },
        },
        {
          'icon': Icons.image,
          'label': 'save_image'.tr,
          'color': Colors.blue,
          'onTap': () {
            if (tipController.validateBill()) {
              controller.captureAndSave();
            }
          },
        },
        {
          'icon': Icons.copy,
          'label': 'copy'.tr,
          'color': Colors.teal,
          'onTap': () {
            if (tipController.validateBill()) {
              Clipboard.setData(ClipboardData(text: tipController.shareMessage));
              Fluttertoast.showToast(
                msg: 'copied_to_clipboard'.tr,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.teal.withOpacity(0.8),
                textColor: Colors.white,
                fontSize: AppSizes.fontM,
              );
            }
          },
        },
        {
          'icon': Icons.qr_code,
          'label': 'qr'.tr,
          'color': Colors.purple,
          'onTap': () {
            if (tipController.validateBill()) {
              _showQRCodeBottomSheet(context, tipController.shareMessage);
            }
          },
        },
        {
          'icon': tipController.editingHistoryId.value != null ? Icons.update : Icons.save_alt,
          'label': tipController.editingHistoryId.value != null ? 'update'.tr : 'save_history'.tr,
          'color': tipController.editingHistoryId.value != null ? Colors.red : Colors.indigo,
          'onTap': () {
            if (tipController.validateBill()) {
              tipController.saveToHistory();
            }
          },
        },
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSizes.paddingS,
          crossAxisSpacing: AppSizes.paddingS,
          childAspectRatio: 1.1,
        ),
        itemCount: buttons.length,
        itemBuilder: (context, index) {
          final btn = buttons[index];
          return _buildActionButton(
            context,
            btn['icon'],
            btn['label'],
            btn['color'],
            btn['onTap'],
          );
        },
      );
    });
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconL),
          ),
          SizedBox(height: AppSizes.paddingXS),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showQRCodeBottomSheet(BuildContext context, String data) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(AppSizes.paddingXXL, AppSizes.paddingM, AppSizes.paddingXXL, AppSizes.paddingXXL),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 4.0,
                margin: EdgeInsets.only(bottom: AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Text('qr_code'.tr, style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.bold)),
              SizedBox(height: AppSizes.paddingXL),
              Container(
                padding: EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Screenshot(
                  controller: controller.qrScreenshotController,
                  child: QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.paddingL),
              Text('scan_me'.tr, style: TextStyle(fontSize: AppSizes.fontM, color: Colors.grey)),
              SizedBox(height: AppSizes.paddingXXL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.shareQRCode(),
                      icon: const Icon(Icons.share),
                      label: Text('share'.tr),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: const Size(0, 48.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                        elevation: 0,
                      ),
                      child: Text('close'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
