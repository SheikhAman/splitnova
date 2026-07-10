import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../data/models/trip_model.dart';
import 'tip_controller.dart';
import '../modules/history/history_controller.dart';

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

    _showSuccessToast(name);
    _navigateToTrips();
  }

  void _showSuccessToast(String name) {
    Get.rawSnackbar(
      messageText: Text(
        'grouped_as'.trParams({'name': name}),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 50),
      borderRadius: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      duration: const Duration(seconds: 2),
      isDismissible: true,
    );
  }

  void _navigateToTrips() {
    final tipController = Get.find<TipController>();
    final historyController = Get.find<HistoryController>();
    
    tipController.selectedIndex.value = 1; // History Tab
    historyController.selectedTab.value = 1; // Trips Sub-Tab
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
    final tripToDelete = trips.firstWhereOrNull((t) => t.id == id);
    if (tripToDelete == null) return;

    final int index = trips.indexOf(tripToDelete);
    trips.removeAt(index);
    _saveTrips();
    trips.refresh();

    _showUndoDeleteTripToast(tripToDelete, index);
  }

  void _showUndoDeleteTripToast(TripModel trip, int index) {
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Expanded(
            child: Text(
              'trip_deleted'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Container(height: 14, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 10)),
          GestureDetector(
            onTap: () {
              trips.insert(index, trip);
              _saveTrips();
              if (Get.isSnackbarOpen) Get.back();
            },
            child: Text(
              'undo'.tr.toUpperCase(),
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 50),
      borderRadius: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      duration: const Duration(seconds: 4),
    );
  }

  TripModel? getTripById(String id) {
    return trips.firstWhereOrNull((t) => t.id == id);
  }

  void _saveTrips() {
    _box.write(_storageKey, trips.map((t) => t.toMap()).toList());
  }
}
