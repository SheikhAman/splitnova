import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_constants.dart';
import 'controllers/support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('support_contact'.tr),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasData.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.config.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: AppSizes.iconXXL + AppSizes.paddingS, color: Colors.grey),
                SizedBox(height: AppSizes.paddingL),
                Text('nothing_to_show'.tr, style: TextStyle(fontSize: AppSizes.fontXL, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          children: [
            if (controller.config.donation.isNotEmpty)
              _buildSection(
                context,
                title: 'donate'.tr,
                icon: Icons.volunteer_activism_rounded,
                children: controller.config.donation.toMap().entries.map((e) {
                  final key = e.key.toLowerCase();
                  if (['bkash', 'nagad', 'rocket'].contains(key)) {
                    return _buildCopyTile(context, e.key.tr, e.value);
                  } else {
                    return _buildLinkTile(context, e.key.tr, e.value, Icons.open_in_new_rounded);
                  }
                }).toList(),
              ),
            if (controller.config.social.isNotEmpty)
              _buildSection(
                context,
                title: 'follow_us'.tr,
                icon: Icons.share_rounded,
                children: controller.config.social.toMap().entries.map((e) {
                  return _buildLinkTile(context, e.key.tr, e.value, Icons.link_rounded);
                }).toList(),
              ),
            if (controller.config.contact.isNotEmpty)
              _buildSection(
                context,
                title: 'contact_us'.tr,
                icon: Icons.contact_support_rounded,
                children: controller.config.contact.toMap().entries.map((e) {
                  return _buildLinkTile(context, e.key.tr, e.value, 
                    e.key.toLowerCase().contains('email') ? Icons.email_rounded : Icons.language_rounded);
                }).toList(),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: AppSizes.iconM, color: Theme.of(context).primaryColor),
            SizedBox(width: AppSizes.paddingS + 2),
            Text(
              title,
              style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
        SizedBox(height: AppSizes.paddingM),
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            side: BorderSide(color: AppColors.getCardBorderColor(context)),
          ),
          child: Column(children: children),
        ),
        SizedBox(height: AppSizes.paddingXXL),
      ],
    );
  }

  Widget _buildCopyTile(BuildContext context, String label, String value) {
    return ListTile(
      title: Text(label, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: TextStyle(fontSize: AppSizes.fontXL - 3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
      trailing: ElevatedButton(
        onPressed: () => controller.copyToClipboard(value, label),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          minimumSize: const Size(60, 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusS)),
        ),
        child: Text('copy_label'.tr, style: TextStyle(fontSize: AppSizes.fontS)),
      ),
    );
  }

  Widget _buildLinkTile(BuildContext context, String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: AppSizes.iconM, color: Theme.of(context).primaryColor.withValues(alpha: 0.7)),
      title: Text(label, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: AppSizes.fontS + 2, color: Colors.grey),
      onTap: () => controller.launchURL(value),
    );
  }
}

