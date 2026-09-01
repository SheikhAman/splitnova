import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/values/app_constants.dart';
import '../data/models/config_models.dart';
import '../services/firebase_service.dart';

class SupportDeveloperModal extends StatelessWidget {
  const SupportDeveloperModal({super.key});

  static void show(BuildContext context) {
    Get.bottomSheet(
      const SupportDeveloperModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  DonationConfig get donationConfig {
    final firebaseService = Get.find<FirebaseService>();
    final config = firebaseService.supportConfig?.donation;
    if (config != null && config.isNotEmpty) {
      return config;
    }
    // Fallback defaults if Firestore is not yet populated
    return DonationConfig(
      bkash: '01700000000',
      nagad: '01700000000',
      rocket: '',
      buyMeCoffee: '',
      githubSponsors: '',
      paddleBackendUrl: '',
    );
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: '$label: ${'copied_to_clipboard'.tr}',
      backgroundColor: AppColors.successGreen,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final donation = donationConfig;
    final bkashNum = donation.bkash.isNotEmpty ? donation.bkash : '01700000000';
    final nagadNum = donation.nagad.isNotEmpty ? donation.nagad : '01700000000';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.70,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSizes.paddingXL,
        right: AppSizes.paddingXL,
        top: AppSizes.paddingL,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingXL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: AppSizes.paddingL),

          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.pink,
                  size: 28,
                ),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
              SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'support_dev_dialog_title'.tr,
                      style: TextStyle(
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'support_dev_dialog_desc'.tr,
                      style: TextStyle(
                        fontSize: AppSizes.fontS,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingL),

          // Bangladesh Payment Tiles (bKash & Nagad)
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'bd_payment_notice'.tr,
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingS),

                  // bKash Card
                  _buildPaymentMethodTile(
                    context,
                    title: 'bkash'.tr,
                    number: bkashNum,
                    badgeColor: const Color(0xFFE2136E),
                    badgeText: 'bKash',
                    accountType: 'account_type_personal'.tr,
                  ),
                  SizedBox(height: AppSizes.paddingM),

                  // Nagad Card
                  _buildPaymentMethodTile(
                    context,
                    title: 'nagad'.tr,
                    number: nagadNum,
                    badgeColor: const Color(0xFFF7931E),
                    badgeText: 'Nagad',
                    accountType: 'account_type_personal'.tr,
                  ),
                  SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context, {
    required String title,
    required String number,
    required Color badgeColor,
    required String badgeText,
    required String accountType,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.getCardBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: AppSizes.paddingXS),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        accountType,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _copyToClipboard(number, title),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text('copy_label'.tr, style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
