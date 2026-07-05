import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../controllers/trip_controller.dart';
import '../../history/history_controller.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/history_model.dart';
import '../../../data/services/trip_aggregation_service.dart';
import '../../../data/services/trip_export_service.dart';

class TripSummaryController extends GetxController {
  final TripController tripController = Get.find<TripController>();
  final HistoryController historyController = Get.find<HistoryController>();
  
  final GlobalKey summaryKey = GlobalKey();

  late String tripId;
  final Rxn<TripModel> trip = Rxn<TripModel>();
  final RxList<HistoryItem> referencedBills = <HistoryItem>[].obs;

  // Aggregation results
  final Rx<TripAggregationResult> aggregation = TripAggregationResult(
    grandTotals: {},
    perPersonTotals: {},
    hasMixedCurrencies: false,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    tripId = Get.arguments ?? '';
    loadData();

    // Listen to changes in trips or history
    ever(tripController.trips, (_) => loadData());
    ever(historyController.historyList, (_) => loadData());
  }

  void loadData() {
    final t = tripController.getTripById(tripId);
    if (t == null) {
      // Trip might have been deleted
      return;
    }
    trip.value = t;

    // Load underlying history entries
    final allHistory = historyController.historyList
        .map((e) => HistoryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    
    referencedBills.value = allHistory
        .where((h) => t.billIds.contains(h.id))
        .toList();

    // Check for dissolution prompt
    if (referencedBills.length <= 1) {
      _showDissolvePrompt();
    }

    // Run aggregation
    aggregation.value = TripAggregationService.aggregate(referencedBills);
  }

  void _showDissolvePrompt() {
    if (Get.isDialogOpen ?? false) return;
    
    Get.dialog(
      AlertDialog(
        title: Text('dissolve_trip_title'.tr),
        content: Text('dissolve_trip_message'.trParams({'n': referencedBills.length.toString()})),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              tripController.deleteTrip(tripId);
              Get.back(); // Close dialog
              Get.back(); // Go back to history
            },
            child: Text('dissolve'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void renameTrip() {
    final nameController = TextEditingController(text: trip.value?.name);
    Get.dialog(
      AlertDialog(
        title: Text('rename_trip'.tr),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'trip_name_hint'.tr,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                tripController.updateTrip(tripId, name: nameController.text.trim());
                Get.back();
              }
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void toggleSettled() {
    if (trip.value == null) return;
    tripController.updateTrip(tripId, isSettled: !trip.value!.isSettled);
  }

  void ungroupTrip() {
    Get.dialog(
      AlertDialog(
        title: Text('ungroup_trip_title'.tr),
        content: Text('ungroup_trip_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              tripController.deleteTrip(tripId);
              Get.back();
              Get.back();
            },
            child: Text('ungroup'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void editBills() {
    // For this phase, a simple selection dialog
    final allHistory = historyController.historyList
        .map((e) => HistoryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    
    var tempSelectedIds = List<String>.from(trip.value?.billIds ?? []).obs;

    Get.dialog(
      Obx(() => AlertDialog(
        title: Text('add_remove_bills'.tr),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allHistory.length,
            itemBuilder: (context, index) {
              final item = allHistory[index];
              final isSelected = tempSelectedIds.contains(item.id);
              return CheckboxListTile(
                title: Text(item.reason ?? 'bill'.tr),
                subtitle: Text(DateFormat.yMMMd().format(item.date)),
                value: isSelected,
                onChanged: (val) {
                  if (val == true) {
                    tempSelectedIds.add(item.id);
                  } else {
                    tempSelectedIds.remove(item.id);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              tripController.updateTrip(tripId, billIds: tempSelectedIds);
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      )),
    );
  }

  void exportPdf() async {
    if (trip.value == null) return;
    await TripExportService.exportToPdf(trip.value!, aggregation.value);
  }

  void exportImage() async {
    try {
      RenderRepaintBoundary? boundary = summaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filename = "${trip.value!.name.replaceAll(RegExp(r'[^\w\s]+'), '').trim()}_Summary.png";
      final imagePath = '${directory.path}/$filename';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(imagePath)], text: 'trip_summary_image'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_save_image'.tr);
    }
  }

  void shareText() {
    if (trip.value == null) return;
    final msg = TripExportService.getTripShareMessage(trip.value!, aggregation.value);
    Share.share(msg);
  }

  void showShareOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text('share_text'.tr),
              onTap: () {
                Get.back();
                shareText();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text('share_pdf'.tr),
              onTap: () {
                Get.back();
                exportPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text('share_image'.tr),
              onTap: () {
                Get.back();
                exportImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void showPlaceholder() {
    Get.snackbar('coming_soon'.tr, 'coming_in_next_update'.tr);
  }
}
