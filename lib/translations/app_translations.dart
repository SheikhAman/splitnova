import 'package:get/get.dart';
import 'en.dart';
import 'bn.dart';

/// AppTranslations handles the localization of the application.
/// 'l10n' is shorthand for 'localization' (l + 10 letters + n).
/// It provides a centralized way to manage translation strings for multiple languages.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en,
    'bn_BD': bn,
  };
}
