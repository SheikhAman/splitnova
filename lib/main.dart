import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/controllers/theme_controller.dart';
import 'app/controllers/language_controller.dart';
import 'app/controllers/tip_controller.dart';
import 'app/services/firebase_service.dart';
import 'translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await GetStorage.init();
  
  // 1. Put FirebaseService immediately so it's available for Get.find()
  // It handles its own internal initialization asynchronously.
  Get.put(FirebaseService(), permanent: true);

  // 2. Initialize essential controllers
  Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(TipController(), permanent: true);

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const SplitNovaApp());
}

class SplitNovaApp extends StatelessWidget {
  const SplitNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit helps with responsive UI across different screen sizes
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        final themeController = Get.find<ThemeController>();
        final languageController = Get.find<LanguageController>();

        return Obx(() => GetMaterialApp(
          title: "SplitNova",
          debugShowCheckedModeBanner: false,
          
          // Theme Configuration
          theme: themeController.currentTheme,
          
          // Localization / Internationalization (i18n)
          translations: AppTranslations(),
          locale: languageController.locale,
          fallbackLocale: const Locale('en', 'US'),
          
          // Routing
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        ));
      },
    );
  }
}
