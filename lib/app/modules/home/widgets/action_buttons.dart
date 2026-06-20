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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              Icons.refresh,
              'reset'.tr,
              Colors.orange,
              tipController.reset,
            ),
            _buildActionButton(
              context,
              Icons.share,
              'share'.tr,
              Colors.green,
              () {
                if (tipController.validateBill()) {
                  tipController.shareToWhatsApp();
                }
              },
            ),
            _buildActionButton(
              context,
              Icons.image,
              'save'.tr,
              Colors.blue,
              () {
                if (tipController.validateBill()) {
                  controller.captureAndSave();
                }
              },
            ),
          ],
        ),
        SizedBox(height: AppSizes.paddingL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              Icons.copy,
              'copy'.tr,
              Colors.teal,
              () {
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
            ),
            _buildActionButton(
              context,
              Icons.qr_code,
              'qr'.tr,
              Colors.purple,
              () {
                if (tipController.validateBill()) {
                  _showQRCodeBottomSheet(context, tipController.shareMessage);
                }
              },
            ),
            Obx(() => _buildActionButton(
              context,
              tipController.editingHistoryId.value != null ? Icons.update : Icons.save_alt,
              tipController.editingHistoryId.value != null ? 'update'.tr : 'history'.tr,
              tipController.editingHistoryId.value != null ? Colors.red : Colors.indigo,
              () {
                if (tipController.validateBill()) {
                  tipController.saveToHistory();
                }
              },
            )),
          ],
        ),
      ],
    );
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
          Text(label, style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.w500)),
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
