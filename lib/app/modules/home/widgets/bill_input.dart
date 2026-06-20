import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../controllers/tip_controller.dart';
import '../home_controller.dart';

class BillInput extends GetView<HomeController> {
  const BillInput({super.key});

  @override
  Widget build(BuildContext context) {
    final tipController = Get.find<TipController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'bill_amount'.tr,
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            Row(
              children: [
                Text(
                  'add_note'.tr,
                  style: TextStyle(fontSize: AppSizes.fontS, color: Colors.grey),
                ),
                Obx(() => Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: tipController.isReasonEnabled.value,
                    onChanged: (val) => tipController.isReasonEnabled.value = val,
                    activeColor: Theme.of(context).primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSizes.paddingS),
        TextField(
          controller: tipController.billController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enableSuggestions: false,
          autocorrect: false,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: TextStyle(fontSize: AppSizes.fontXXXL, fontWeight: FontWeight.bold),
          onChanged: tipController.updateBill,
          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
          decoration: InputDecoration(
            prefixIcon: GestureDetector(
              onTap: () => _showCurrencyPicker(context, tipController),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                child: Obx(() => Text(
                  tipController.currencySymbol,
                  style: TextStyle(fontSize: AppSizes.fontXXXL, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                )),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: IconButton(
              icon: Obx(() => Icon(
                Icons.mic,
                color: controller.isListening.value ? Colors.red : Theme.of(context).primaryColor,
              )),
              onPressed: () {
                if (controller.isListening.value) {
                  controller.stopListening();
                } else {
                  controller.startListening();
                }
              },
            ),
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: AppSizes.fontXXXL,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        Obx(() => tipController.isReasonEnabled.value
            ? Padding(
                padding: EdgeInsets.only(top: AppSizes.paddingM),
                child: TextField(
                  controller: tipController.reasonController,
                  onChanged: (val) => tipController.billReason.value = val,
                  enableSuggestions: false,
                  autocorrect: false,
                  spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                  decoration: InputDecoration(
                    hintText: 'note_hint'.tr,
                    prefixIcon: Icon(Icons.edit_note, size: AppSizes.iconM),
                    suffixIcon: Obx(() => tipController.billReason.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: AppSizes.iconS),
                            onPressed: tipController.clearReason,
                          )
                        : const SizedBox.shrink()),
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  void _showCurrencyPicker(BuildContext context, TipController controller) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(AppSizes.paddingXL, AppSizes.paddingM, AppSizes.paddingXL, AppSizes.paddingXL),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.0,
              height: 4.0,
              margin: EdgeInsets.only(bottom: AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            Text('default_currency'.tr, style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.bold)),
            SizedBox(height: AppSizes.paddingS),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: controller.currencies.keys.map((code) {
                  return ListTile(
                    title: Text('$code (${controller.currencies[code]})'),
                    onTap: () {
                      controller.updateCurrency(code);
                      Get.back();
                    },
                    trailing: controller.selectedCurrency.value == code 
                        ? Icon(Icons.check, color: Theme.of(context).primaryColor) 
                        : null,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
