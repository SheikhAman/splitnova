import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../controllers/tip_controller.dart';

class PeopleCounter extends StatelessWidget {
  const PeopleCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TipController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'number_of_people'.tr,
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            _buildCounterButton(
              context,
              Icons.remove,
              controller.decrementPeople,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXS), // Reduced padding for TextField
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: Get.isDarkMode ? Colors.white24 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person, 
                      color: Theme.of(context).primaryColor, 
                      size: AppSizes.iconL
                    ),
                    SizedBox(width: AppSizes.paddingS),
                    SizedBox(
                      width: 60.0,
                      child: TextField(
                        controller: controller.peopleTextController,
                        enableSuggestions: false,
                        autocorrect: false,
                        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onTap: () {
                          if (controller.peopleTextController.text == '0' || controller.peopleTextController.text == '1') {
                            controller.peopleTextController.clear();
                          }
                        },
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: AppSizes.fontXXL, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: "1",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => controller.updatePeopleFromText(val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCounterButton(
              context,
              Icons.add,
              controller.incrementPeople,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: Theme.of(context).primaryColor, width: 1),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: AppSizes.iconL),
      ),
    );
  }
}
