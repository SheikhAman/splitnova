import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/values/app_constants.dart';
import '../../controllers/tip_controller.dart';

class HomeController extends GetxController {
  final tipController = Get.find<TipController>();
  final screenshotController = ScreenshotController();
  final qrScreenshotController = ScreenshotController();
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  var isListening = false.obs;
  
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    if (index == 0) Get.offNamed('/home');
    if (index == 1) Get.offNamed('/history');
    if (index == 2) Get.offNamed('/settings');
  }

  Future<void> startListening() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) => isListening.value = false,
      );
      
      if (available) {
        isListening.value = true;
        _speech.listen(
          onResult: (result) {
            String text = result.recognizedWords;
            double? amount = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
            if (amount != null) {
              tipController.billAmount.value = amount;
              tipController.billController.text = amount.toString();
            }
          },
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 3),
        );
      }
    } else {
      _showToast('mic_permission_required'.tr, Colors.redAccent);
    }
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
  }

  Future<void> captureAndSave() async {
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final result = await SaverGallery.saveImage(
          image,
          quality: 100,
          fileName: "SplitNova_${DateTime.now().millisecondsSinceEpoch}.png",
          androidRelativePath: "Pictures/SplitNova",
          skipIfExists: false,
        );
        
        if (result.isSuccess) {
          _showSuccessDialog(image);
        } else {
          _showToast('failed_save_image'.tr, Colors.redAccent);
        }
      }
    } catch (e) {
      _showToast('${'failed_save_image'.tr}: $e', Colors.redAccent);
    }
  }

  void _showSuccessDialog(Uint8List image) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusXXL)),
        backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: Colors.green, size: AppSizes.iconXXL + AppSizes.paddingS),
              ),
              SizedBox(height: AppSizes.paddingL),
              Text(
                'saved_to_gallery'.tr,
                style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.paddingXL),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: AppColors.getCardBorderColor(Get.context!)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: Image.memory(
                    image,
                    height: 180.0, // Specific height for preview
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.paddingXXL + AppSizes.paddingXS),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final directory = await getTemporaryDirectory();
                          final path = '${directory.path}/SplitNova_share.png';
                          final file = File(path);
                          await file.writeAsBytes(image);
                          await Share.shareXFiles([XFile(path)], text: 'share_header'.tr);
                        } catch (e) {
                          _showToast('Error: $e', Colors.redAccent);
                        }
                      },
                      icon: Icon(Icons.share_rounded, size: AppSizes.fontXL),
                      label: Text('share'.tr),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: BorderSide(color: Theme.of(Get.context!).primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM + 2)),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(Get.context!).primaryColor,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM + 2)),
                        elevation: 0,
                      ),
                      child: Text('close'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> shareQRCode() async {
    try {
      final Uint8List? image = await qrScreenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/SplitNova_QR.png';
        final file = File(path);
        await file.writeAsBytes(image);
        await Share.shareXFiles([XFile(path)], text: 'share_qr_message'.tr);
      }
    } catch (e) {
      _showToast('Error sharing QR: $e', Colors.redAccent);
    }
  }

  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: AppSizes.fontM,
    );
  }
}

