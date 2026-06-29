import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/values/app_constants.dart';

class UpdateView extends StatelessWidget {
  final String message;
  final String playStoreUrl;

  const UpdateView({
    super.key,
    required this.message,
    required this.playStoreUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.paddingXXL + AppSizes.paddingS),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
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
                Icons.update_rounded,
                size: AppSizes.iconXXL * 2,
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
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
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
    );
  }
}

