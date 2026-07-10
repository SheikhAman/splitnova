import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../controllers/tip_controller.dart';
import '../../controllers/trip_controller.dart';
import '../../routes/app_pages.dart';
import '../../data/models/history_model.dart';

class HistoryController extends GetxController {
  final _box = GetStorage();
  var historyList = <dynamic>[].obs;
  final qrScreenshotController = ScreenshotController();

  // Tab management (0: Bills, 1: Trips)
  var selectedTab = 0.obs;

  // Selection Mode States
  var isSelectionMode = false.obs;
  var selectedIds = <String>[].obs;

  // Suggestion State
  var suggestionIds = <String>[].obs;
  final String _dismissedSuggestionsKey = 'dismissed_suggestions';

  // Coach Mark State
  var showGroupHint = false.obs;
  final String _hintKey = 'has_seen_group_hint';

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    _checkCoachMark();
    _checkSuggestions();

    // Listen for changes in history storage to keep the UI synced
    _box.listenKey('history', (value) {
      loadHistory();
      _checkCoachMark();
      _checkSuggestions();
    });

    final tripController = Get.find<TripController>();
    ever(tripController.trips, (_) => _checkSuggestions());
  }

  void _checkSuggestions() {
    final tripController = Get.find<TripController>();
    final allHistory = historyList
        .map((e) => HistoryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final ungrouped = allHistory.where((h) {
      return !tripController.trips.any((t) => t.billIds.contains(h.id));
    }).toList();

    if (ungrouped.length < 3) {
      suggestionIds.clear();
      return;
    }

    // Sort by date to check window
    ungrouped.sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i <= ungrouped.length - 3; i++) {
      for (int j = i + 2; j < ungrouped.length; j++) {
        final window = ungrouped.sublist(i, j + 1);
        final first = window.first.date;
        final last = window.last.date;

        if (last.difference(first).inHours <= 72) {
          // Check common people
          final commonPeople = _findCommonPeople(window);
          if (commonPeople.length >= 2) {
            final ids = window.map((h) => h.id).toList();
            if (!_isSuggestionDismissed(ids)) {
              suggestionIds.value = ids;
              return;
            }
          }
        }
      }
    }
    suggestionIds.clear();
  }

  List<String> _findCommonPeople(List<HistoryItem> items) {
    if (items.isEmpty) return [];
    
    Map<String, int> counts = {};
    for (var item in items) {
      if (item.peopleList == null) continue;
      final names = item.peopleList!.map((p) => p.name.trim().toLowerCase()).toSet();
      for (var name in names) {
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }

    return counts.entries
        .where((e) => e.value == items.length)
        .map((e) => e.key)
        .toList();
  }

  bool _isSuggestionDismissed(List<String> ids) {
    final sig = _getSuggestionSignature(ids);
    final List<dynamic> dismissed = _box.read(_dismissedSuggestionsKey) ?? [];
    return dismissed.contains(sig);
  }

  String _getSuggestionSignature(List<String> ids) {
    final sorted = List<String>.from(ids)..sort();
    return sha1.convert(utf8.encode(sorted.join(','))).toString();
  }

  void dismissSuggestion() {
    if (suggestionIds.isEmpty) return;
    final sig = _getSuggestionSignature(suggestionIds);
    final List<dynamic> dismissed = _box.read(_dismissedSuggestionsKey) ?? [];
    dismissed.add(sig);
    _box.write(_dismissedSuggestionsKey, dismissed);
    suggestionIds.clear();
  }

  void groupSuggested() {
    if (suggestionIds.isEmpty) return;
    selectedIds.value = List<String>.from(suggestionIds);
    isSelectionMode.value = true;
    suggestionIds.clear();
    // In Phase 2, the UI shows a "Create Group" button when selection mode is active
  }

  void loadHistory() {
    historyList.value = _box.read('history') ?? [];
  }

  void _checkCoachMark() {
    bool hasSeen = _box.read(_hintKey) ?? false;
    if (!hasSeen && historyList.length >= 2) {
      showGroupHint.value = true;
    } else {
      showGroupHint.value = false;
    }
  }

  void dismissCoachMark() {
    showGroupHint.value = false;
    _box.write(_hintKey, true);
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedIds.clear();
    } else {
      // If we turned it on manually via AppBar icon, we don't select anything yet
    }
    if (isSelectionMode.value) dismissCoachMark();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedIds.add(id);
      isSelectionMode.value = true;
      dismissCoachMark();
    }
  }

  void deleteSelectedItems() {
    final List<dynamic> backup = List.from(historyList);
    final idsToRemove = Set.from(selectedIds);
    
    historyList.removeWhere((item) => idsToRemove.contains(item['id'].toString()));
    _box.write('history', historyList.toList());
    
    _showUndoDeleteToast(backup);
    
    selectedIds.clear();
    isSelectionMode.value = false;
  }

  void _showUndoDeleteToast(List<dynamic> backup) {
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Expanded(
            child: Text(
              'items_deleted'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Container(
            height: 16,
            width: 1,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          GestureDetector(
            onTap: () {
              historyList.value = backup;
              _box.write('history', backup);
              if (Get.isSnackbarOpen) Get.back();
            },
            child: Text(
              'undo'.tr.toUpperCase(),
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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

  void deleteItem(int index) {
    historyList.removeAt(index);
    _box.write('history', historyList.toList());
  }

  void clearAllHistory() {
    historyList.clear();
    _box.write('history', []);
  }

  void loadItemToCalculator(HistoryItem item) {
    final tipController = Get.find<TipController>();
    tipController.loadHistoryItem(item.toMap());
    
    // Switch to calculator tab in the home shell
    tipController.selectedIndex.value = 0;
  }

  String getHistoryShareMessage(HistoryItem item) {
    final format = NumberFormat.simpleCurrency(name: item.currency);
    final double totalBill = item.bill + item.tipAmount;
    
    String tipStr = item.isFixedTip 
        ? format.format(item.tipAmount) 
        : "${item.tipPercent.toStringAsFixed(0)}% (${format.format(item.tipAmount)})";

    String msg = "${'share_header'.tr}\n";
    
    if (item.reason != null && item.reason!.isNotEmpty) {
      msg += "📝 ${'note'.tr}: ${item.reason}\n";
    }
    
    msg += "━━━━━━━━━━━━━━━━\n"
        "${'share_bill'.tr}: ${format.format(item.bill)}\n"
        "${'share_tip'.tr}: $tipStr\n"
        "${'share_people'.tr}: ${item.people}\n"
        "━━━━━━━━━━━━━━━━\n";

    if (item.isCustomSplit && item.peopleList != null) {
      for (var p in item.peopleList!) {
        double amount = totalBill * (p.percentage / 100);
        msg += "👤 ${p.name}: ${format.format(amount)}\n";
      }
    } else {
      msg += "💵 ${'total_per_person'.tr}: ${format.format(item.totalPerPerson)}\n";
    }

    msg += "━━━━━━━━━━━━━━━━\n"
        "${'share_footer'.tr}\n"
        "${'tagline'.tr}";
    return msg;
  }

  Future<void> shareQRCode() async {
    try {
      final Uint8List? image = await qrScreenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/SplitNova_History_QR.png';
        final file = File(path);
        await file.writeAsBytes(image);
        await Share.shareXFiles([XFile(path)], text: 'share_qr_message'.tr);
      }
    } catch (e) {
      debugPrint('Error sharing QR from history: $e');
    }
  }
}
