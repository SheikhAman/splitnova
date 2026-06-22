import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Person {
  final String id;
  final int index;
  RxString name;
  RxDouble percentage;
  final TextEditingController nameController;
  final TextEditingController percentController;
  
  Person({required this.id, required this.index, required double percent, String name = ""}) 
      : name = name.obs, 
        percentage = percent.obs,
        nameController = TextEditingController(text: name),
        percentController = TextEditingController(text: percent.toStringAsFixed(1));

  String get displayName => name.value.trim().isEmpty ? "${'person_text'.tr} ${index + 1}" : name.value;

  double getAmount(double totalBill) {
    return totalBill * (percentage.value / 100);
  }

  void dispose() {
    nameController.dispose();
    percentController.dispose();
  }
}

class TipController extends GetxController {
  final _box = GetStorage();
  
  var billAmount = 0.0.obs;
  var tipPercent = 15.0.obs;
  var tipFixedAmount = 0.0.obs;
  var isFixedTip = false.obs;
  var numberOfPeople = 1.obs;
  var isCustomTip = false.obs;
  var selectedCurrency = "USD".obs;
  var isCustomSplit = false.obs;
  var peopleList = <Person>[].obs;

  // Defaults for Settings
  var defaultTip = 15.0.obs;
  var defaultPeople = 1.obs;
  
  // Tracking if we are editing an existing history item
  var editingHistoryId = RxnString();
  
  // Reason / Note field states
  var isReasonEnabled = false.obs;
  var billReason = "".obs;
  final reasonController = TextEditingController();
  
  final billController = TextEditingController();
  final tipTextController = TextEditingController();
  final peopleTextController = TextEditingController();

  final Map<String, String> currencies = {
    'USD': '\$',
    'BDT': '৳',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'SAR': '﷼',
    'AED': 'د.إ',
  };

  void updateCurrency(String code) {
    selectedCurrency.value = code;
    _box.write('currency', code);
  }

  String get currencySymbol => currencies[selectedCurrency.value] ?? '\$';

  String formatMoney(double amount, [String? currencyCode]) {
    final code = currencyCode ?? selectedCurrency.value;
    final format = NumberFormat.simpleCurrency(name: code);
    return format.format(amount);
  }

  double get tipAmount => isFixedTip.value 
      ? tipFixedAmount.value 
      : billAmount.value * (tipPercent.value / 100);
      
  double get totalAmount => billAmount.value + tipAmount;
  double get tipPerPerson => tipAmount / numberOfPeople.value;
  double get totalPerPerson => totalAmount / numberOfPeople.value;

  @override
  void onInit() {
    super.onInit();
    selectedCurrency.value = _box.read('currency') ?? 'USD';
    
    defaultTip.value = (GetStorage().read('default_tip') ?? 15.0).toDouble();
    defaultPeople.value = _box.read('default_people') ?? 1;

    tipPercent.value = defaultTip.value;
    numberOfPeople.value = defaultPeople.value;
    
    tipTextController.text = tipPercent.value.toStringAsFixed(0);
    peopleTextController.text = numberOfPeople.value.toString();
    
    // Initialize people list
    syncPeopleList(numberOfPeople.value);

    // Sync numberOfPeople with peopleList length
    ever(numberOfPeople, (int count) {
      if (peopleList.length != count) {
        syncPeopleList(count);
      }
    });
  }

  void syncPeopleList(int count) {
    if (peopleList.length < count) {
      for (int i = peopleList.length; i < count; i++) {
        peopleList.add(Person(
          id: DateTime.now().microsecondsSinceEpoch.toString() + i.toString(),
          index: i,
          percent: 0
        ));
      }
    } else if (peopleList.length > count) {
      for (int i = count; i < peopleList.length; i++) {
        peopleList[i].dispose();
      }
      peopleList.removeRange(count, peopleList.length);
    }
    rebalancePercentages();
  }

  void rebalancePercentages() {
    if (peopleList.isEmpty) return;
    double equalShare = 100 / peopleList.length;
    for (var person in peopleList) {
      double val = double.parse(equalShare.toStringAsFixed(1));
      person.percentage.value = val;
      person.percentController.text = val.toString();
    }
    
    // Adjust last person to ensure sum is exactly 100
    if (peopleList.isNotEmpty) {
      double currentTotal = peopleList.fold(0, (sum, p) => sum + p.percentage.value);
      if ((100.0 - currentTotal).abs() > 0.01) {
        double val = double.parse((peopleList.last.percentage.value + (100.0 - currentTotal)).toStringAsFixed(1));
        peopleList.last.percentage.value = val;
        peopleList.last.percentController.text = val.toString();
      }
    }
  }

  void addPerson() {
    numberOfPeople.value++;
    peopleTextController.text = numberOfPeople.value.toString();
  }

  void removePerson(int index) {
    if (peopleList.length > 1) {
      peopleList[index].dispose();
      peopleList.removeAt(index);
      numberOfPeople.value = peopleList.length;
      peopleTextController.text = numberOfPeople.value.toString();
      rebalancePercentages();
    } else {
      _showToast('error'.tr, 'min_person_reached'.tr);
    }
  }

  void updateBill(String value) {
    billAmount.value = double.tryParse(value) ?? 0.0;
  }

  void updateTip(double value) {
    tipPercent.value = value;
    isFixedTip.value = false;
    tipTextController.text = value.toStringAsFixed(0);
    isCustomTip.value = false;
  }

  void setCustomTip(double value) {
    tipPercent.value = value;
    isFixedTip.value = false;
    tipTextController.text = value.toStringAsFixed(0);
    isCustomTip.value = true;
  }

  void updateTipFromText(String value) {
    if (value.isEmpty) {
      if (isFixedTip.value) {
        tipFixedAmount.value = 0.0;
      } else {
        tipPercent.value = 0.0;
      }
      return;
    }
    
    double? val = double.tryParse(value);
    if (val != null) {
      if (isFixedTip.value) {
        tipFixedAmount.value = val;
      } else {
        tipPercent.value = val.clamp(0, 1000);
      }
      isCustomTip.value = true;
    }
  }

  void toggleTipType(bool isFixed) {
    isFixedTip.value = isFixed;
    if (isFixed) {
      tipTextController.text = tipFixedAmount.value.toStringAsFixed(0);
    } else {
      tipTextController.text = tipPercent.value.toStringAsFixed(0);
    }
  }

  void incrementPeople() {
    if (numberOfPeople.value < 1000) {
      numberOfPeople.value++;
      peopleTextController.text = numberOfPeople.value.toString();
    }
  }

  void decrementPeople() {
    if (numberOfPeople.value > 1) {
      numberOfPeople.value--;
      peopleTextController.text = numberOfPeople.value.toString();
    }
  }

  void updatePeopleFromText(String value) {
    if (value.isEmpty) {
      numberOfPeople.value = 1;
      return;
    }
    int? val = int.tryParse(value);
    if (val != null) {
      numberOfPeople.value = val.clamp(1, 1000);
    }
  }

  void updateDefaultTip(double val) {
    defaultTip.value = val;
    _box.write('default_tip', val);
  }

  void updateDefaultPeople(int val) {
    defaultPeople.value = val;
    _box.write('default_people', val);
  }

  void updateDefaultCurrency(String val) {
    updateCurrency(val);
  }

  void reset() {
    billAmount.value = 0.0;
    billController.clear();
    tipPercent.value = (_box.read('default_tip') ?? 15.0).toDouble();
    numberOfPeople.value = _box.read('default_people') ?? 1;
    tipFixedAmount.value = 0.0;
    isFixedTip.value = false;
    tipTextController.text = tipPercent.value.toStringAsFixed(0);
    peopleTextController.text = numberOfPeople.value.toString();
    isCustomTip.value = false;
    isCustomSplit.value = false;
    editingHistoryId.value = null; // Clear editing state on reset
    
    // Clear Reason/Note
    isReasonEnabled.value = false;
    clearReason();

    // Reset people details in the list
    for (var person in peopleList) {
      person.name.value = "";
      person.nameController.clear();
    }

    syncPeopleList(numberOfPeople.value);
  }

  void loadHistoryItem(Map<String, dynamic> item) {
    editingHistoryId.value = item['id'];
    billAmount.value = (item['bill'] as num).toDouble();
    billController.text = item['bill'].toString();
    
    isFixedTip.value = item['isFixedTip'] ?? false;
    tipPercent.value = (item['tipPercent'] as num).toDouble();
    tipFixedAmount.value = (item['tipAmount'] as num).toDouble();

    // Custom tip logic
    final List<double> presets = [5, 10, 15, 20, 25];
    bool isPreset = !isFixedTip.value && presets.contains(tipPercent.value);
    isCustomTip.value = !isPreset;

    if (isFixedTip.value) {
      tipTextController.text = tipFixedAmount.value.toString();
    } else {
      tipTextController.text = tipPercent.value.toStringAsFixed(0);
    }

    numberOfPeople.value = item['people'];
    peopleTextController.text = item['people'].toString();
    selectedCurrency.value = item['currency'];
    
    if (item['reason'] != null && (item['reason'] as String).isNotEmpty) {
      isReasonEnabled.value = true;
      billReason.value = item['reason'];
      reasonController.text = item['reason'];
    } else {
      isReasonEnabled.value = false;
      clearReason();
    }

    if (item['isCustomSplit'] == true) {
      isCustomSplit.value = true;
      if (item['peopleList'] != null) {
        final List<dynamic> savedPeople = item['peopleList'];
        
        // Synchronously sync list before populating data
        syncPeopleList(savedPeople.length);
        
        for (int i = 0; i < savedPeople.length; i++) {
          if (i < peopleList.length) {
            final person = peopleList[i];
            final savedData = savedPeople[i];
            
            String savedName = savedData['name'] ?? "";
            
            // If it's the generic "Person X" name, we show it as hint, otherwise as text
            if (savedName.contains('Person') || savedName.contains('ব্যক্তি')) {
               person.name.value = "";
               person.nameController.clear();
            } else {
               person.name.value = savedName;
               person.nameController.text = savedName;
            }

            double pct = (savedData['percentage'] as num).toDouble();
            person.percentage.value = pct;
            person.percentController.text = pct.toString();
          }
        }
      }
    } else {
      isCustomSplit.value = false;
    }
  }

  @override
  void onClose() {
    for (var person in peopleList) {
      person.dispose();
    }
    super.onClose();
  }

  void clearReason() {
    reasonController.clear();
    billReason.value = "";
  }

  bool validateBill() {
    if (billAmount.value <= 0) {
      Fluttertoast.showToast(
        msg: 'enter_amount_error'.tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
    return true;
  }

  void saveToHistory() {
    if (!validateBill()) return;
    
    final historyItem = {
      'id': editingHistoryId.value ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'bill': billAmount.value.toDouble(),
      'tipPercent': tipPercent.value.toDouble(),
      'tipAmount': tipAmount,
      'isFixedTip': isFixedTip.value,
      'people': numberOfPeople.value.toInt(),
      'currency': selectedCurrency.value,
      'totalPerPerson': totalPerPerson.toDouble(),
      'reason': isReasonEnabled.value ? billReason.value : "",
      'isCustomSplit': isCustomSplit.value,
      'peopleList': isCustomSplit.value 
          ? peopleList.map((p) => {'name': p.displayName, 'percentage': p.percentage.value}).toList()
          : [],
    };
    
    final List<dynamic> history = List.from(_box.read('history') ?? []);
    
    if (editingHistoryId.value != null) {
      // Update existing item
      int index = history.indexWhere((item) => item['id'] == editingHistoryId.value);
      if (index != -1) {
        history[index] = historyItem;
        _showToast('success'.tr, 'history_updated'.tr);
      } else {
        // Fallback if not found
        history.insert(0, historyItem);
      }
    } else {
      // Save as new
      history.insert(0, historyItem);
      _showToast('success'.tr, 'saved_to_history'.tr);
    }
    
    _box.write('history', history);
    reset(); // Clear all fields after successful save
    editingHistoryId.value = null; // Clear editing state after save
  }

  void _showToast(String title, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  String get shareMessage {
    final format = NumberFormat.simpleCurrency(name: selectedCurrency.value);
    String tipStr = isFixedTip.value 
        ? format.format(tipAmount) 
        : tipPercent.value.toStringAsFixed(0) + "% (" + format.format(tipAmount) + ")";

    String msg = "${'share_header'.tr}\n";
    
    if (isReasonEnabled.value && billReason.value.isNotEmpty) {
      msg += "📝 ${'note'.tr}: ${billReason.value}\n";
    }
    
    msg += "━━━━━━━━━━━━━━━━\n"
        "${'share_bill'.tr}: ${format.format(billAmount.value)}\n"
        "${'share_tip'.tr}: $tipStr\n"
        "${'share_people'.tr}: ${numberOfPeople.value}\n"
        "━━━━━━━━━━━━━━━━\n";

    if (isCustomSplit.value) {
      for (var person in peopleList) {
        msg += "👤 ${person.displayName}: ${format.format(person.getAmount(totalAmount))}\n";
      }
    } else {
      msg += "💵 ${'total_per_person'.tr}: ${format.format(totalPerPerson)}\n";
    }

    msg += "━━━━━━━━━━━━━━━━\n"
        "${'share_footer'.tr}\n"
        "${'tagline'.tr}";
    return msg;
  }

  void shareToWhatsApp([String? message]) async {
    final url = "https://wa.me/?text=" + Uri.encodeComponent(message ?? shareMessage);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void shareGeneral([String? message]) {
    Share.share(message ?? shareMessage);
  }
}
