import 'package:get/get.dart';
import '../controllers/trip_summary_controller.dart';

class TripSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TripSummaryController>(TripSummaryController());
  }
}
