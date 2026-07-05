import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/values/app_constants.dart';
import 'history_controller.dart';
import '../../controllers/trip_controller.dart';
import 'widgets/history_list_item.dart';
import 'widgets/trip_list_item.dart';
import '../../data/models/history_model.dart';
import '../../data/models/trip_model.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (controller.isSelectionMode.value) {
            controller.toggleSelectionMode();
          } else {
            Get.back();
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _buildSuggestionBanner(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBillsList(context),
                    _buildTripsList(context),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(() => Text(
            controller.isSelectionMode.value
                ? '${controller.selectedIds.length} ${'selected'.tr}'
                : 'history'.tr,
          )),
      bottom: TabBar(
        tabs: [
          Tab(text: 'bills'.tr),
          Tab(text: 'trips'.tr),
        ],
      ),
      actions: [
        Obx(() {
          if (controller.isSelectionMode.value) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.group_add_outlined),
                  onPressed: () => _showCreateTripDialog(context),
                  tooltip: 'create_trip'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showDeleteConfirmation(context),
                  tooltip: 'delete_selected'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.toggleSelectionMode(),
                ),
              ],
            );
          }
          return IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => controller.toggleSelectionMode(),
            tooltip: 'selection_mode'.tr,
          );
        }),
      ],
    );
  }

  Widget _buildSuggestionBanner() {
    return Obx(() {
      if (controller.suggestionIds.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.blue.withValues(alpha: 0.1),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'group_suggestion_text'.trParams({
                  'n': controller.suggestionIds.length.toString(),
                }),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () => controller.groupSuggested(),
              child: Text('group'.tr),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => controller.dismissSuggestion(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBillsList(BuildContext context) {
    final tripController = Get.find<TripController>();
    return Obx(() {
      final bills = controller.historyList;
      final trips = tripController.trips;
      
      if (bills.isEmpty && trips.isEmpty) {
        return _buildEmptyState(Icons.history, 'no_history'.tr);
      }
      
      final List<dynamic> combinedList = [...trips, ...bills];
      
      return ListView.builder(
        padding: EdgeInsets.all(AppSizes.paddingL),
        itemCount: combinedList.length,
        itemBuilder: (context, index) {
          final item = combinedList[index];
          
          if (item is TripModel) {
            return TripListItem(
              trip: item,
              controller: controller,
            );
          }
          
          final itemMap = item as Map<String, dynamic>;
          final historyItem = HistoryItem.fromMap(itemMap);
          return HistoryListItem(
            item: historyItem,
            controller: controller,
            onShowQRCode: () => _showQRCodeBottomSheet(context, controller.getHistoryShareMessage(historyItem)),
            onShowToast: (msg) => _showToast(msg),
          );
        },
      );
    });
  }

  Widget _buildTripsList(BuildContext context) {
    final tripController = Get.find<TripController>();
    return Obx(() {
      final list = tripController.trips;
      if (list.isEmpty) {
        return _buildEmptyState(Icons.card_travel, 'no_trips'.tr);
      }
      return ListView.builder(
        padding: EdgeInsets.all(AppSizes.paddingL),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final trip = list[index];
          return TripListItem(
            trip: trip,
            controller: controller,
          );
        },
      );
    });
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconXXL * 2, color: Colors.grey.withValues(alpha: 0.5)),
          SizedBox(height: AppSizes.paddingL),
          Text(message, style: TextStyle(fontSize: AppSizes.fontL, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return Obx(() {
      if (controller.historyList.isNotEmpty && !controller.isSelectionMode.value) {
        return FloatingActionButton.extended(
          onPressed: () => _showClearAllConfirmation(context),
          label: Text('clear_all'.tr),
          icon: const Icon(Icons.delete_sweep_outlined),
          backgroundColor: Colors.red,
        );
      }
      return const SizedBox.shrink();
    });
  }

  void _showCreateTripDialog(BuildContext context) {
    if (controller.selectedIds.length < 2) {
      Get.snackbar(
        'error'.tr,
        'select_at_least_two_bills'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();
    final tripController = Get.find<TripController>();
    
    RxString selectedEmoji = '✈️'.obs;
    RxInt selectedColor = Colors.orange.toARGB32().obs;

    final List<String> emojis = ['✈️', '🍕', '🚗', '🏨', '🛍️', '🏖️', '⛰️', '🎉', '☕', '🍜'];
    final List<Color> colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.deepOrange,
    ];

    Get.dialog(
      AlertDialog(
        title: Text('create_trip'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'trip_name_hint'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                ),
                autofocus: true,
              ),
              SizedBox(height: AppSizes.paddingL),
              Text('select_emoji'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontM)),
              SizedBox(height: AppSizes.paddingS),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    return Obx(() => GestureDetector(
                      onTap: () => selectedEmoji.value = emojis[index],
                      child: Container(
                        margin: EdgeInsets.only(right: AppSizes.paddingS),
                        padding: EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: selectedEmoji.value == emojis[index] ? AppColors.getPrimaryLight(context) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          border: Border.all(
                            color: selectedEmoji.value == emojis[index] ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(emojis[index], style: TextStyle(fontSize: AppSizes.iconM)),
                      ),
                    ));
                  },
                ),
              ),
              SizedBox(height: AppSizes.paddingL),
              Text('select_color'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontM)),
              SizedBox(height: AppSizes.paddingS),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    return Obx(() => GestureDetector(
                      onTap: () => selectedColor.value = colors[index].toARGB32(),
                      child: Container(
                        width: 40,
                        margin: EdgeInsets.only(right: AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor.value == colors[index].toARGB32() ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            if (selectedColor.value == colors[index].toARGB32())
                              BoxShadow(color: colors[index].withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1),
                          ],
                        ),
                        child: selectedColor.value == colors[index].toARGB32()
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                      ),
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                tripController.createTrip(
                  nameController.text,
                  controller.selectedIds.toList(),
                  emoji: selectedEmoji.value,
                  colorValue: selectedColor.value,
                );
                controller.toggleSelectionMode();
                Get.back();
              }
            },
            child: Text('create'.tr),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_selected'.tr),
        content: Text('delete_selected_confirm'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              controller.deleteSelectedItems();
              Get.back();
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('clear_history'.tr),
        content: Text('clear_history_confirm'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              controller.clearAllHistory();
              Get.back();
            },
            child: Text('clear'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showQRCodeBottomSheet(BuildContext context, String data) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(AppSizes.paddingXXL, AppSizes.paddingM, AppSizes.paddingXXL, AppSizes.paddingXXL),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.iconXXL,
                height: 4.0,
                margin: EdgeInsets.only(bottom: AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Text('qr_code'.tr, style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.bold)),
              SizedBox(height: AppSizes.paddingXL),
              Screenshot(
                controller: controller.qrScreenshotController,
                child: Container(
                  padding: EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.paddingL),
              Text('scan_me'.tr, style: TextStyle(fontSize: AppSizes.fontM, color: Colors.grey)),
              SizedBox(height: AppSizes.paddingXXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.shareQRCode(),
                  icon: const Icon(Icons.share_outlined),
                  label: Text('share_qr'.tr),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(AppSizes.paddingL),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      textColor: Colors.white,
      fontSize: AppSizes.fontM,
    );
  }
}
