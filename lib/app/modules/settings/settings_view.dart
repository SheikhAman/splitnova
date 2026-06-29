import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_constants.dart';
import 'settings_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/language_controller.dart';
import '../../data/models/config_models.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final langController = Get.find<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        final hasData = controller.configs.isNotEmpty;
        
        if (controller.isLoading.value && !hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          children: [
            SizedBox(height: AppSizes.paddingXXL),
            _buildAppHeader(context),
            SizedBox(height: AppSizes.paddingL),
            
            _buildSectionTitle('appearance'.tr),
            _buildThemeSettings(context, themeController, langController),
            
            Padding(
              padding: EdgeInsets.only(top: AppSizes.paddingL, bottom: AppSizes.paddingS, left: AppSizes.paddingXS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'primary_color'.tr.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingS),
                  Obx(() => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: themeController.colorPalette.map((color) {
                      final isSelected = themeController.primaryColor.value.value == color.value;
                      return GestureDetector(
                        onTap: () => themeController.setPrimaryColor(color),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? (Get.isDarkMode ? Colors.white : Colors.black) : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected 
                              ? const Icon(Icons.check, color: Colors.white, size: 20) 
                              : null,
                        ),
                      );
                    }).toList(),
                  )),
                ],
              ),
            ),
            
            _buildSectionTitle('defaults'.tr),
            _buildDefaultSettings(context),

            SizedBox(height: AppSizes.paddingL),
            _buildSupportSection(context),
            _buildSocialSection(context),
            _buildContactSection(context),
            _buildAboutSection(context),
            _buildMoreSection(context),
            
            SizedBox(height: AppSizes.paddingXXL * 2),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXL, horizontal: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.getPrimaryLight(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        border: Border.all(color: AppColors.getPrimaryLight(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset('assets/images/app_logo.png', height: 48.0), 
          ),
          SizedBox(width: AppSizes.paddingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'app_title'.tr,
                  style: TextStyle(fontSize: AppSizes.fontXXL, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                Obx(() => Text(
                  '${'version'.tr} ${controller.appVersion.value}',
                  style: TextStyle(fontSize: AppSizes.fontS, color: Colors.grey[600], fontWeight: FontWeight.w500),
                )),
                SizedBox(height: AppSizes.paddingXS),
                InkWell(
                  onTap: controller.checkForUpdateManually,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: AppSizes.fontM, color: Get.theme.primaryColor),
                      SizedBox(width: AppSizes.paddingXS),
                      Text(
                        'check_for_update'.tr,
                        style: TextStyle(
                          fontSize: AppSizes.fontS, 
                          color: Get.theme.primaryColor, 
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.paddingL, bottom: AppSizes.paddingS, left: AppSizes.paddingXS),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: AppSizes.fontS,
          fontWeight: FontWeight.bold,
          color: Get.theme.primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, ThemeController theme, LanguageController lang) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        side: BorderSide(color: AppColors.getCardBorderColor(context)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: _buildIconContainer(context, Icons.dark_mode_outlined),
            title: Text('dark_mode'.tr, style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.w500)),
            trailing: Switch(
              value: theme.isDarkMode.value,
              onChanged: (val) => theme.toggleTheme(),
              activeColor: Get.theme.primaryColor,
            ),
          ),
          Divider(indent: 56.0, endIndent: AppSizes.paddingL, height: 1),
          ListTile(
            leading: _buildIconContainer(context, Icons.language_outlined),
            title: Text('language'.tr, style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.w500)),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingXS),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryLight(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                lang.currentLanguage.value == 'en' ? 'English' : 'বাংলা',
                style: TextStyle(color: Get.theme.primaryColor, fontWeight: FontWeight.bold, fontSize: AppSizes.fontS),
              ),
            ),
            onTap: lang.toggleLanguage,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSettings(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        side: BorderSide(color: AppColors.getCardBorderColor(context)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: _buildIconContainer(context, Icons.percent_rounded),
            title: Text('default_tip'.tr, style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.w500)),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<double>(
                value: controller.defaultTip.value,
                onChanged: (val) => controller.updateDefaultTip(val!),
                icon: Icon(Icons.keyboard_arrow_down, color: Get.theme.primaryColor),
                style: TextStyle(color: Get.theme.primaryColor, fontWeight: FontWeight.bold, fontSize: AppSizes.fontM),
                items: [5.0, 10.0, 15.0, 20.0, 25.0]
                    .map((e) => DropdownMenuItem(value: e, child: Text('${e.toInt()}%')))
                    .toList(),
              ),
            ),
          ),
          Divider(indent: 56.0, endIndent: AppSizes.paddingL, height: 1),
          ListTile(
            leading: _buildIconContainer(context, Icons.people_outline),
            title: Text('default_people'.tr, style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.w500)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircularButton(context, Icons.remove, () => controller.updateDefaultPeople((controller.defaultPeople.value - 1).clamp(1, 100))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: Text('${controller.defaultPeople.value}', style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.bold)),
                ),
                _buildCircularButton(context, Icons.add, () => controller.updateDefaultPeople((controller.defaultPeople.value + 1).clamp(1, 100))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: AppColors.getPrimaryLight(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusS), 
      ),
      child: Icon(icon, color: Get.theme.primaryColor, size: AppSizes.iconM),
    );
  }

  Widget _buildCircularButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingXS),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Get.theme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: AppSizes.iconS, color: Get.theme.primaryColor),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final DonationConfig? donation = controller.configs['donation'];
    if (donation == null) return const SizedBox();

    return _buildExpandableSection(
      context: context,
      title: 'support_development'.tr,
      icon: Icons.favorite_border_rounded,
      children: [
        if (donation.bkash.isNotEmpty)
          _buildCopyTile('bkash'.tr, donation.bkash, Icons.account_balance_wallet_rounded),
        if (donation.nagad.isNotEmpty)
          _buildCopyTile('nagad'.tr, donation.nagad, Icons.account_balance_wallet_rounded),
        if (donation.rocket.isNotEmpty)
          _buildCopyTile('rocket'.tr, donation.rocket, Icons.account_balance_wallet_rounded),
        if (donation.buyMeCoffee.isNotEmpty)
          _buildLinkTile('buy_me_coffee'.tr, donation.buyMeCoffee, Icons.coffee_rounded),
        if (donation.githubSponsors.isNotEmpty)
          _buildLinkTile('github_sponsors'.tr, donation.githubSponsors, Icons.favorite_rounded),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    final SocialConfig? social = controller.configs['social'];
    if (social == null || social.isEmpty) return const SizedBox();

    return _buildExpandableSection(
      context: context,
      title: 'follow_us'.tr,
      icon: Icons.share_outlined,
      children: [
        if (social.facebook.isNotEmpty) _buildLinkTile('facebook'.tr, social.facebook, Icons.facebook),
        if (social.github.isNotEmpty) _buildLinkTile('github'.tr, social.github, Icons.code),
        if (social.whatsapp.isNotEmpty) _buildLinkTile('whatsapp'.tr, 'https://wa.me/${social.whatsapp.replaceAll('+', '').replaceAll(' ', '')}', Icons.chat_outlined),
        if (social.twitter.isNotEmpty) _buildLinkTile('twitter'.tr, social.twitter, Icons.alternate_email),
        if (social.instagram.isNotEmpty) _buildLinkTile('instagram'.tr, social.instagram, Icons.camera_alt_outlined),
        if (social.youtube.isNotEmpty) _buildLinkTile('youtube'.tr, social.youtube, Icons.play_circle_outline),
        if (social.linkedin.isNotEmpty) _buildLinkTile('linkedin'.tr, social.linkedin, Icons.business),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final ContactConfig? contact = controller.configs['contact'];
    if (contact == null || contact.isEmpty) return const SizedBox();

    return _buildExpandableSection(
      context: context,
      title: 'contact_legal'.tr,
      icon: Icons.contact_support_outlined,
      children: [
        if (contact.email.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 2),
            leading: Icon(Icons.email_outlined, size: AppSizes.iconM, color: Get.theme.primaryColor.withValues(alpha: 0.8)),
            title: Text('email'.tr, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)),
            subtitle: Text(contact.email, style: TextStyle(fontSize: AppSizes.fontS, color: Colors.grey.withValues(alpha: 0.8))),
            trailing: SizedBox(
              width: AppSizes.iconM,
              height: AppSizes.iconM,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.keyboard_arrow_right_rounded),
                onPressed: () => controller.sendEmail(contact.email),
                color: Get.theme.primaryColor.withValues(alpha: 0.7),
              ),
            ),
            onTap: () => controller.sendEmail(contact.email),
            titleAlignment: ListTileTitleAlignment.center,
          ),
        if (contact.website.isNotEmpty) _buildLinkTile('website'.tr, contact.website, Icons.language_rounded),
        if (contact.privacyPolicy.isNotEmpty) _buildLinkTile('privacy_policy'.tr, contact.privacyPolicy, Icons.policy_outlined),
        if (contact.termsOfUse.isNotEmpty) _buildLinkTile('terms_of_use'.tr, contact.termsOfUse, Icons.description_outlined),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final AboutConfig? about = controller.configs['about'];
    if (about == null || about.isEmpty) return const SizedBox();

    return _buildExpandableSection(
      context: context,
      title: 'about'.tr,
      icon: Icons.info_outline,
      children: [
        if (about.developerName.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 2),
            leading: Icon(Icons.person_outline, size: AppSizes.iconM, color: Get.theme.primaryColor.withValues(alpha: 0.8)), 
            title: Text('developer'.tr, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)), 
            trailing: Text(about.developerName, style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.bold, color: Get.theme.primaryColor)),
            titleAlignment: ListTileTitleAlignment.center,
          ),
        if (about.publisherName.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 2),
            leading: Icon(Icons.business_center_outlined, size: AppSizes.iconM, color: Get.theme.primaryColor.withValues(alpha: 0.8)), 
            title: Text('publisher'.tr, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)), 
            trailing: Text(about.publisherName, style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.bold, color: Get.theme.primaryColor)),
            titleAlignment: ListTileTitleAlignment.center,
          ),
        if (about.githubRepo.isNotEmpty) _buildLinkTile('open_source_project'.tr, about.githubRepo, Icons.code),
        if (about.portfolioUrl.isNotEmpty) _buildLinkTile('developer_portfolio'.tr, about.portfolioUrl, Icons.web),
      ],
    );
  }

  Widget _buildMoreSection(BuildContext context) {
    final AppConfig? app = controller.configs['app'];

    return _buildExpandableSection(
      context: context,
      title: 'more'.tr,
      icon: Icons.more_horiz,
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 2),
          leading: Icon(Icons.star_outline, size: AppSizes.iconM, color: Get.theme.primaryColor.withValues(alpha: 0.8)),
          title: Text('rate_us'.tr, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)),
          trailing: SizedBox(
            width: AppSizes.iconM,
            height: AppSizes.iconM,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.keyboard_arrow_right_rounded),
              onPressed: () {
                if (app != null && app.playStoreUrl.isNotEmpty) {
                  controller.launchURL(app.playStoreUrl);
                }
              },
              color: Get.theme.primaryColor.withValues(alpha: 0.7),
            ),
          ),
          onTap: () {
            if (app != null && app.playStoreUrl.isNotEmpty) {
              controller.launchURL(app.playStoreUrl);
            }
          },
          titleAlignment: ListTileTitleAlignment.center,
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 2),
          leading: Icon(Icons.share_outlined, size: AppSizes.iconM, color: Get.theme.primaryColor.withValues(alpha: 0.8)),
          title: Text('share_app'.tr, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)),
          trailing: SizedBox(
            width: AppSizes.iconM,
            height: AppSizes.iconM,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.keyboard_arrow_right_rounded),
              onPressed: controller.shareApp,
              color: Get.theme.primaryColor.withValues(alpha: 0.7),
            ),
          ),
          onTap: controller.shareApp,
          titleAlignment: ListTileTitleAlignment.center,
        ),
      ],
    );
  }

  Widget _buildExpandableSection({required BuildContext context, required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: BorderSide(color: AppColors.getCardBorderColor(context)),
        ),
        child: Theme(
          data: Get.theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            leading: Container(
              padding: EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryLight(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(icon, color: Get.theme.primaryColor, size: AppSizes.iconM),
            ),
            title: Text(
              title, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: AppSizes.fontL,
                color: Get.isDarkMode ? Colors.white : Colors.black87,
              )
            ),
            iconColor: Get.theme.primaryColor,
            collapsedIconColor: Colors.grey,
            childrenPadding: EdgeInsets.zero,
            expandedAlignment: Alignment.topLeft,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildCopyTile(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 2),
      leading: Icon(icon, size: AppSizes.iconM, color: Get.theme.primaryColor.withValues(alpha: 0.8)),
      title: Text(title, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: TextStyle(fontSize: AppSizes.fontS, color: Colors.grey.withValues(alpha: 0.8))),
      trailing: SizedBox(
        width: AppSizes.iconM,
        height: AppSizes.iconM,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => controller.copyToClipboard(value),
          color: Get.theme.primaryColor.withValues(alpha: 0.7),
        ),
      ),
      titleAlignment: ListTileTitleAlignment.center,
    );
  }

  Widget _buildLinkTile(String title, String url, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 2),
      leading: Icon(icon, size: AppSizes.iconM, color: Get.theme.primaryColor.withValues(alpha: 0.8)),
      title: Text(title, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.w500)),
      subtitle: Text(url, style: TextStyle(fontSize: AppSizes.fontS, color: Colors.grey.withValues(alpha: 0.8)), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: SizedBox(
        width: AppSizes.iconM,
        height: AppSizes.iconM,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.open_in_new_rounded),
          onPressed: () => controller.launchURL(url),
          color: Get.theme.primaryColor.withValues(alpha: 0.7),
        ),
      ),
      onTap: () => controller.launchURL(url),
      titleAlignment: ListTileTitleAlignment.center,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: (index) {
        if (index == 0) Get.offAllNamed('/home');
        if (index == 1) Get.offAllNamed('/history');
      },
      selectedItemColor: Theme.of(context).primaryColor,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.calculate), label: 'calculator'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.history), label: 'history'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'settings'.tr),
      ],
    );
  }
}
