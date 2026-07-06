import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splitnova/app/controllers/tip_controller.dart';
import '../../../controllers/trip_controller.dart';
import '../../history/history_controller.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/history_model.dart';
import '../../../data/services/trip_aggregation_service.dart';
import '../../../data/services/trip_export_service.dart';
import '../../../core/values/app_constants.dart';

class TripSummaryController extends GetxController {
  final TripController tripController = Get.find<TripController>();
  final HistoryController historyController = Get.find<HistoryController>();
  final TipController tipController = Get.find<TipController>();
  
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
      // Trip might have been deleted (e.g. via Undo snackbar)
      if (Get.currentRoute == '/trip-summary') {
        Get.back();
      }
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDissolvePrompt();
      });
    }

    // Run aggregation
    aggregation.value = TripAggregationService.aggregate(referencedBills);
  }

  bool _isDissolveDialogShowing = false;
  void _showDissolvePrompt() {
    if (_isDissolveDialogShowing || trip.value == null) return;
    _isDissolveDialogShowing = true;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: Text('dissolve_trip_title'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('dissolve_trip_message'.trParams({'n': referencedBills.length.toString()})),
        actions: [
          TextButton(
            onPressed: () {
              _isDissolveDialogShowing = false;
              Get.back();
            },
            child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
            onPressed: () {
              _isDissolveDialogShowing = false;
              final idToDelete = tripId;
              Get.back(); // Close dialog
              tripController.deleteTrip(idToDelete);
            },
            child: Text('dissolve'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      barrierDismissible: false,
    ).then((_) => _isDissolveDialogShowing = false);
  }

  void renameTrip() {
    final nameController = TextEditingController(text: trip.value?.name);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: Text('rename'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('trip_name_label'.tr, style: TextStyle(fontSize: AppSizes.fontS, color: Colors.grey)),
            SizedBox(height: AppSizes.paddingS),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'trip_name_hint'.tr,
                filled: true,
                fillColor: Get.theme.primaryColor.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(AppSizes.paddingM),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                tripController.updateTrip(tripId, name: newName);
                Get.back();
              } else {
                Get.snackbar(
                  'error'.tr,
                  'enter_trip_name'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            child: Text('save'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: Text('ungroup'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('ungroup_trip_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
            onPressed: () {
              final idToDelete = tripId;
              Get.back(); // Close dialog
              tripController.deleteTrip(idToDelete);
            },
            child: Text('ungroup'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void editBills() {
    final allHistory = historyController.historyList
        .map((e) => HistoryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    var tempSelectedIds = List<String>.from(trip.value?.billIds ?? []).obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: Text('add_remove_bills'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingS),
                child: Text('select_bills_message'.tr, style: TextStyle(fontSize: AppSizes.fontS, color: Colors.grey)),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.5,
                ),
                child: allHistory.isEmpty 
                  ? Center(child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingXL),
                      child: Text('no_history'.tr),
                    ))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: allHistory.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = allHistory[index];
                        final amountStr = tipController.formatMoney(item.bill + item.tipAmount, item.currency);
                        
                        return Obx(() {
                          final isSelected = tempSelectedIds.contains(item.id);
                          return CheckboxListTile(
                            title: Text(
                              item.reason != null && item.reason!.isNotEmpty 
                                  ? item.reason! 
                                  : 'bill'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "${DateFormat('MMM dd').format(item.date)} • $amountStr",
                              style: TextStyle(fontSize: AppSizes.fontS),
                            ),
                            value: isSelected,
                            activeColor: Get.theme.primaryColor,
                            onChanged: (val) {
                              if (val == true) {
                                tempSelectedIds.add(item.id);
                              } else {
                                tempSelectedIds.remove(item.id);
                              }
                            },
                          );
                        });
                      },
                    ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
            onPressed: () {
              tripController.updateTrip(tripId, billIds: tempSelectedIds);
              Get.back();
            },
            child: Text('save'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void exportPdf() async {
    if (trip.value == null) return;
    await TripExportService.exportToPdf(trip.value!, aggregation.value, referencedBills);
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
