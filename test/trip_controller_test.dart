import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:splitnova/app/controllers/trip_controller.dart';
import 'package:splitnova/app/data/models/trip_model.dart';
import 'package:mockito/mockito.dart';

void main() async {
  await GetStorage.init('TestBox');
  final box = GetStorage('TestBox');

  group('TripController Tests', () {
    late TripController controller;

    setUp(() async {
      await box.erase();
      controller = TripController();
      Get.put(controller);
    });

    tearDown(() {
      Get.delete<TripController>();
    });

    test('Initial trips should be empty', () {
      expect(controller.trips.isEmpty, true);
    });

    test('Create trip should add to list and persist', () async {
      controller.createTrip('Test Trip', ['1', '2'], emoji: '🚗', colorValue: 0xFF00FF00);
      
      expect(controller.trips.length, 1);
      expect(controller.trips[0].name, 'Test Trip');
      expect(controller.trips[0].billIds, ['1', '2']);
      expect(controller.trips[0].emoji, '🚗');
      
      // Verify persistence
      final newController = TripController();
      newController.loadTrips();
      expect(newController.trips.length, 1);
      expect(newController.trips[0].name, 'Test Trip');
    });

    test('Delete trip should remove from list', () {
      controller.createTrip('Test Trip', ['1', '2']);
      final id = controller.trips[0].id;
      
      controller.deleteTrip(id);
      expect(controller.trips.isEmpty, true);
    });

    test('Update trip should modify existing trip', () {
      controller.createTrip('Old Name', ['1']);
      final id = controller.trips[0].id;
      
      controller.updateTrip(id, name: 'New Name', isSettled: true);
      
      expect(controller.trips[0].name, 'New Name');
      expect(controller.trips[0].isSettled, true);
    });
  });
}
