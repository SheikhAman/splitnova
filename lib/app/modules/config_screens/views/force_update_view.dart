import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/values/app_constants.dart';

class ForceUpdateView extends StatelessWidget {
  final String message;
  final String playStoreUrl;

  const ForceUpdateView({
    super.key,
    required this.message,
    required this.playStoreUrl,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents back gesture/button
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL + AppSizes.paddingS),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXXL),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  size: AppSizes.iconXXL + AppSizes.paddingL,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: AppSizes.paddingXXL * 1.5),
              Text(
                'new_version_available'.tr,
                style: TextStyle(
                  fontSize: AppSizes.fontXXXL,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.paddingL),
              Text(
                message.isEmpty ? 'update_message_default'.tr : message,
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.paddingXL),
              Container(
                padding: EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.warningAmber.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.warningAmber, size: AppSizes.iconM),
                        SizedBox(width: AppSizes.paddingS),
                        Text(
                          'data_loss_warning_title'.tr,
                          style: TextStyle(color: AppColors.warningAmber, fontWeight: FontWeight.bold, fontSize: AppSizes.fontM),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.paddingS),
                    Text(
                      'data_loss_warning_message'.tr,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: AppSizes.fontS),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.paddingXXL * 2),
              ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(playStoreUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'update_now'.tr,
                  style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

