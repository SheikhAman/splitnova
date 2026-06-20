import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';

class MaintenanceView extends StatelessWidget {
  final String message;

  const MaintenanceView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Non-dismissible
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL + AppSizes.paddingS),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXXL),
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryLight(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: AppSizes.iconXXL * 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: AppSizes.paddingXXL * 1.5),
              Text(
                'under_maintenance'.tr,
                style: TextStyle(
                  fontSize: AppSizes.fontXXXL + 2,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.paddingL),
              Text(
                message.isEmpty ? 'maintenance_message_default'.tr : message,
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.paddingXXL * 2),
              SizedBox(
                width: AppSizes.iconXXL,
                height: AppSizes.iconXXL,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: AppSizes.paddingXXL),
              Text(
                'check_back_later'.tr,
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

