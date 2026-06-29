import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  // Base Sizes (unscaled)
  static const double _basePaddingXS = 4.0;
  static const double _basePaddingS = 8.0;
  static const double _basePaddingM = 12.0;
  static const double _basePaddingL = 16.0;
  static const double _basePaddingXL = 20.0;
  static const double _basePaddingXXL = 24.0;

  static const double _baseFontXS = 10.0;
  static const double _baseFontS = 12.0;
  static const double _baseFontM = 14.0;
  static const double _baseFontL = 16.0;
  static const double _baseFontXL = 18.0;
  static const double _baseFontXXL = 20.0;
  static const double _baseFontXXXL = 24.0;

  static const double _baseRadiusS = 8.0;
  static const double _baseRadiusM = 12.0;
  static const double _baseRadiusL = 16.0;
  static const double _baseRadiusXL = 20.0;
  static const double _baseRadiusXXL = 24.0;

  static const double _baseIconS = 16.0;
  static const double _baseIconM = 20.0;
  static const double _baseIconL = 24.0;
  static const double _baseIconXL = 32.0;
  static const double _baseIconXXL = 40.0;

  // Scaled Sizes (using getters to ensure ScreenUtil is initialized)
  static double get paddingXS => _basePaddingXS.w;
  static double get paddingS => _basePaddingS.w;
  static double get paddingM => _basePaddingM.w;
  static double get paddingL => _basePaddingL.w;
  static double get paddingXL => _basePaddingXL.w;
  static double get paddingXXL => _basePaddingXXL.w;

  static double get fontXS => _baseFontXS.sp;
  static double get fontS => _baseFontS.sp;
  static double get fontM => _baseFontM.sp;
  static double get fontL => _baseFontL.sp;
  static double get fontXL => _baseFontXL.sp;
  static double get fontXXL => _baseFontXXL.sp;
  static double get fontXXXL => _baseFontXXXL.sp;

  static double get radiusS => _baseRadiusS.r;
  static double get radiusM => _baseRadiusM.r;
  static double get radiusL => _baseRadiusL.r;
  static double get radiusXL => _baseRadiusXL.r;
  static double get radiusXXL => _baseRadiusXXL.r;

  static double get iconS => _baseIconS.sp;
  static double get iconM => _baseIconM.sp;
  static double get iconL => _baseIconL.sp;
  static double get iconXL => _baseIconXL.sp;
  static double get iconXXL => _baseIconXXL.sp;
}

class AppColors {
  static const Color warningAmber = Color(0xFFFFC107);
  static final Color warningAmberLight = warningAmber.withValues(alpha: 0.1);
  static final Color warningAmberBorder = warningAmber.withValues(alpha: 0.2);
  
  static const Color successGreen = Colors.green;
  static const Color errorRed = Colors.redAccent;
  
  static Color getCardBorderColor(BuildContext context) => 
      Theme.of(context).dividerColor.withValues(alpha: 0.05);
      
  static Color getPrimaryLight(BuildContext context) => 
      Theme.of(context).primaryColor.withValues(alpha: 0.1);
}
