import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_constants.dart';

class UpdateDialog extends StatelessWidget {
  final String updateMessage;
  final VoidCallback onUpdate;
  final String? playStoreUrl;

  const UpdateDialog({
    super.key,
    required this.updateMessage,
    required this.onUpdate,
    this.playStoreUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusXXL)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryLight(context),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.rocket_launch_rounded, color: Theme.of(context).primaryColor, size: AppSizes.iconXXL),
            ),
            SizedBox(height: AppSizes.paddingL),
            Text(
              'new_version_available'.tr,
              style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.paddingM),
            Text(
              updateMessage.isEmpty ? 'update_message_default'.tr : updateMessage,
              style: TextStyle(fontSize: AppSizes.fontM, color: Colors.grey[600], height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.paddingXL),
            Container(
              padding: EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.warningAmberLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.warningAmberBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: AppSizes.iconM),
                  SizedBox(width: AppSizes.paddingS + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'data_loss_warning_title'.tr,
                          style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.bold, color: Colors.amber[900]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'data_loss_warning_message'.tr,
                          style: TextStyle(fontSize: AppSizes.fontXS + 1, color: Colors.amber[800], height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.paddingXXL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'later'.tr,
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: AppSizes.fontM),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'update_now'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontM,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
