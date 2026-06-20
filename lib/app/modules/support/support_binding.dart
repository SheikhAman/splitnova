import 'package:get/get.dart';
import 'package:splitnova/app/modules/support/controllers/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController());
  }
}
