import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/values/app_constants.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF009688),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF009688), 
              Color(0xFF004D40),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Smart Logo size for a premium look
                Container(
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 150.0,
                    height: 150.0,
                  ),
                )
                .animate()
                .fade(duration: const Duration(milliseconds: 800))
                .scale(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),
                
                SizedBox(height: AppSizes.paddingXXL * 1.5),

                Text(
                  'SPLITNOVA',
                  style: TextStyle(
                    fontSize: AppSizes.fontXXXL + 4,
                    fontWeight: FontWeight.w200, // Modern thin weight
                    color: Colors.white,
                    letterSpacing: 12, // Professional spacing
                  ),
                )
                .animate()
                .fade(delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 800))
                .slideY(begin: 0.2, end: 0),
                
                SizedBox(height: AppSizes.paddingM),
                
                Text(
                  'SPLIT SMART • TIP EASY',
                  style: TextStyle(
                    fontSize: AppSizes.fontXS - 1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fade(delay: const Duration(milliseconds: 1400), duration: const Duration(milliseconds: 800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

