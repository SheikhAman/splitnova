import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _box = GetStorage();
  final _key = 'language';

  final Map<String, Map<String, String>> languages = {
    'en': {'name': 'English', 'flag': '🇺🇸', 'locale': 'en_US'},
    'bn': {'name': 'বাংলা', 'flag': '🇧🇩', 'locale': 'bn_BD'},
    'hi': {'name': 'हिन्दी', 'flag': '🇮🇳', 'locale': 'hi_IN'},
    'zh': {'name': '中文', 'flag': '🇨🇳', 'locale': 'zh_CN'},
    'ja': {'name': '日本語', 'flag': '🇯🇵', 'locale': 'ja_JP'},
    'ko': {'name': '한국어', 'flag': '🇰🇷', 'locale': 'ko_KR'},
    'ar': {'name': 'العربية', 'flag': '🇸🇦', 'locale': 'ar_SA'},
    'id': {'name': 'Bahasa Indonesia', 'flag': '🇮🇩', 'locale': 'id_ID'},
    'vi': {'name': 'Tiếng Việt', 'flag': '🇻🇳', 'locale': 'vi_VN'},
    'th': {'name': 'ไทย', 'flag': '🇹🇭', 'locale': 'th_TH'},
  };

  RxString currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    currentLanguage.value = _box.read(_key) ?? 'en';
  }

  void changeLanguage(String langCode) {
    if (languages.containsKey(langCode)) {
      currentLanguage.value = langCode;
      _box.write(_key, langCode);
      
      final localeParts = languages[langCode]!['locale']!.split('_');
      Get.updateLocale(Locale(localeParts[0], localeParts[1]));
    }
  }

  Locale get locale {
    final lang = _box.read(_key) ?? 'en';
    final localeParts = (languages[lang]?['locale'] ?? 'en_US').split('_');
    return Locale(localeParts[0], localeParts[1]);
  }
}
