import 'package:get/get.dart';
import '../../controllers/tip_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TipController>(() => TipController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
