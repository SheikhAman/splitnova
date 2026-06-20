import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/tip_controller.dart';
import '../../routes/app_pages.dart';

class HistoryController extends GetxController {
  final _box = GetStorage();
  var historyList = <dynamic>[].obs;
  final qrScreenshotController = ScreenshotController();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    
    // Listen for changes in history storage to keep the UI synced
    _box.listenKey('history', (value) {
      loadHistory();
    });
  }

  void loadHistory() {
    historyList.value = _box.read('history') ?? [];
  }

  void deleteItem(int index) {
    historyList.removeAt(index);
    _box.write('history', historyList.toList());
  }

  void clearAllHistory() {
    historyList.clear();
    _box.write('history', []);
  }

  void loadItemToCalculator(Map<String, dynamic> item) {
    final tipController = Get.find<TipController>();
    tipController.loadHistoryItem(item);
    Get.offAllNamed(Routes.HOME);
  }

  String getHistoryShareMessage(Map<String, dynamic> item) {
    final currency = item['currency'] ?? 'USD';
    final format = NumberFormat.simpleCurrency(name: currency);
    final double totalBill = ((item['bill'] as num) + (item['tipAmount'] as num)).toDouble();
    
    String tipStr = item['isFixedTip'] == true 
        ? format.format(item['tipAmount']) 
        : "${(item['tipPercent'] as num).toStringAsFixed(0)}% (${format.format(item['tipAmount'])})";

    String msg = "${'share_header'.tr}\n";
    
    if (item['reason'] != null && (item['reason'] as String).isNotEmpty) {
      msg += "📝 ${'note'.tr}: ${item['reason']}\n";
    }
    
    msg += "━━━━━━━━━━━━━━━━\n"
        "${'share_bill'.tr}: ${format.format(item['bill'])}\n"
        "${'share_tip'.tr}: $tipStr\n"
        "${'share_people'.tr}: ${item['people']}\n"
        "━━━━━━━━━━━━━━━━\n";

    if (item['isCustomSplit'] == true && item['peopleList'] != null) {
      final List<dynamic> pList = item['peopleList'];
      for (var p in pList) {
        double amount = totalBill * ((p['percentage'] as num) / 100);
        msg += "👤 ${p['name']}: ${format.format(amount)}\n";
      }
    } else {
      msg += "💵 ${'total_per_person'.tr}: ${format.format(item['totalPerPerson'])}\n";
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
