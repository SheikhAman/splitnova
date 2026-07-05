import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/trip_model.dart';

class TripController extends GetxController {
  final _box = GetStorage();
  final String _storageKey = 'trips_storage';
  
  var trips = <TripModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrips();
  }

  void loadTrips() {
    final List<dynamic>? storedTrips = _box.read(_storageKey);
    if (storedTrips != null) {
      trips.value = storedTrips
          .map((e) => TripModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  void createTrip(String name, List<String> billIds, {String? emoji, int? colorValue}) {
    if (name.trim().isEmpty) return;

    final newTrip = TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      billIds: billIds,
      emoji: emoji,
      colorValue: colorValue,
      createdAt: DateTime.now().toIso8601String(),
      isSettled: false,
    );

    trips.insert(0, newTrip);
    _saveTrips();

    Get.snackbar(
      'success'.tr,
      'grouped_as'.trParams({'name': name}),
      mainButton: TextButton(
        onPressed: () {
          deleteTrip(newTrip.id);
          if (Get.isSnackbarOpen) Get.back();
        },
        child: Text('undo'.tr, style: const TextStyle(color: Colors.orange)),
      ),
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void updateTrip(String id, {String? name, List<String>? billIds, bool? isSettled, String? emoji, int? colorValue}) {
    int index = trips.indexWhere((t) => t.id == id);
    if (index != -1) {
      trips[index] = trips[index].copyWith(
        name: name,
        billIds: billIds,
        isSettled: isSettled,
        emoji: emoji,
        colorValue: colorValue,
      );
      _saveTrips();
    }
  }

  void deleteTrip(String id) {
    trips.removeWhere((t) => t.id == id);
    _saveTrips();
  }

  TripModel? getTripById(String id) {
    return trips.firstWhereOrNull((t) => t.id == id);
  }

  void _saveTrips() {
    _box.write(_storageKey, trips.map((t) => t.toMap()).toList());
  }
}
