import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';
  final _colorKey = 'primaryColor';

  RxBool isDarkMode = true.obs;
  Rx<Color> primaryColor = const Color(0xFF00BFA5).obs;

  final List<Color> colorPalette = [
    const Color(0xFF00BFA5), // Teal
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Rose
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink
    const Color(0xFFF97316), // Orange
    const Color(0xFF64748B), // Slate
  ];

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read(_key) ?? true;
    int? colorValue = _box.read(_colorKey);
    if (colorValue != null) {
      primaryColor.value = Color(colorValue);
    }
    updateTheme();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write(_key, isDarkMode.value);
    updateTheme();
  }

  void setPrimaryColor(Color color) {
    primaryColor.value = color;
    _box.write(_colorKey, color.value);
    updateTheme();
  }

  void updateTheme() {
    // Only use Get.changeTheme if ScreenUtil is ready
    try {
      Get.changeTheme(AppTheme.getTheme(isDarkMode.value, primaryColor.value));
    } catch (e) {
      debugPrint('ThemeController: ScreenUtil not yet ready, theme update deferred.');
    }
    
    // Update System UI Overlays
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode.value ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode.value ? const Color(0xFF1A1A2E) : Colors.white,
      systemNavigationBarIconBrightness: isDarkMode.value ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  ThemeData get currentTheme => AppTheme.getTheme(isDarkMode.value, primaryColor.value);
}
