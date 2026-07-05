import 'package:get/get.dart';
import 'en.dart';
import 'bn.dart';
import 'hi.dart';
import 'zh.dart';
import 'ja.dart';
import 'ko.dart';
import 'ar.dart';
import 'id.dart';
import 'vi.dart';
import 'th.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en,
    'bn_BD': bn,
    'hi_IN': hi,
    'zh_CN': zh,
    'ja_JP': ja,
    'ko_KR': ko,
    'ar_SA': ar,
    'id_ID': id,
    'vi_VN': vi,
    'th_TH': th,
  };
}
