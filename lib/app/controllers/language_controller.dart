import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _box = GetStorage();
  final _key = 'language';

  RxString currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    currentLanguage.value = _box.read(_key) ?? 'en';
  }

  void toggleLanguage() {
    if (currentLanguage.value == 'en') {
      currentLanguage.value = 'bn';
      Get.updateLocale(const Locale('bn', 'BD'));
    } else {
      currentLanguage.value = 'en';
      Get.updateLocale(const Locale('en', 'US'));
    }
    _box.write(_key, currentLanguage.value);
  }

  Locale get locale => currentLanguage.value == 'en' 
      ? const Locale('en', 'US') 
      : const Locale('bn', 'BD');
}
