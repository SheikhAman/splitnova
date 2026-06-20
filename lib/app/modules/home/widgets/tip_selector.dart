import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../controllers/tip_controller.dart';

class TipSelector extends StatelessWidget {
  const TipSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TipController>();
    final List<double> tipPercentages = [5, 10, 15, 20, 25];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'select_tip'.tr,
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(height: AppSizes.paddingM),
        Wrap(
          spacing: AppSizes.paddingS,
          runSpacing: AppSizes.paddingS,
          children: [
            ...tipPercentages.map((tip) => Obx(() {
                  bool isSelected = controller.tipPercent.value == tip && !controller.isCustomTip.value;
                  return _buildTipButton(
                    context,
                    tip.toInt().toString() + "%",
                    isSelected,
                    () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.updateTip(tip);
                    },
                  );
                })),
            Obx(() => _buildTipButton(
                  context,
                  'custom'.tr,
                  controller.isCustomTip.value,
                  () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _showCustomTipBottomSheet(context, controller);
                  },
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildTipButton(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : (Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : (Get.isDarkMode ? Colors.white24 : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (Get.isDarkMode ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontM,
          ),
        ),
      ),
    );
  }

  void _showCustomTipBottomSheet(BuildContext context, TipController controller) {
    Get.bottomSheet(
      isScrollControlled: true,
      SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(AppSizes.paddingXL, AppSizes.paddingXL, AppSizes.paddingXL, MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingXL),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
          ),
          child: SingleChildScrollView(
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
                Text('custom'.tr, style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.bold)),
                SizedBox(height: AppSizes.paddingXL),
                Obx(() => ToggleButtons(
                      isSelected: [!controller.isFixedTip.value, controller.isFixedTip.value],
                      onPressed: (index) => controller.toggleTipType(index == 1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).primaryColor,
                      constraints: BoxConstraints(minWidth: 80.0, minHeight: 36.0),
                      children: [
                        Text("%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontL)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                          child: Text(controller.currencySymbol, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontL)),
                        ),
                      ],
                    )),
                SizedBox(height: AppSizes.paddingXL),
                Obx(() => !controller.isFixedTip.value 
                  ? Slider(
                      value: controller.tipPercent.value.clamp(0.0, 100.0).toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) => controller.setCustomTip(value),
                    )
                  : const SizedBox.shrink()),
                SizedBox(height: AppSizes.paddingS),
                Obx(() => SizedBox(
                  width: 150.0,
                  child: TextField(
                    controller: controller.tipTextController,
                    enableSuggestions: false,
                    autocorrect: false,
                    spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onTap: () {
                      if (controller.tipTextController.text == '0') {
                        controller.tipTextController.clear();
                      }
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: AppSizes.fontXXXL + 8, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    decoration: InputDecoration(
                      hintText: "0",
                      prefixText: controller.isFixedTip.value ? controller.currencySymbol : null,
                      suffixText: controller.isFixedTip.value ? null : "%",
                      prefixStyle: TextStyle(fontSize: AppSizes.fontXXXL, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      suffixStyle: TextStyle(fontSize: AppSizes.fontXXXL, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: (val) => controller.updateTipFromText(val),
                  ),
                )),
                SizedBox(height: AppSizes.paddingXL),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: Size(double.infinity, 50.0),
                  ),
                  child: Text('close'.tr, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
