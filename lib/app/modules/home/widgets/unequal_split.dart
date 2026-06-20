import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import 'package:flutter/services.dart';
import '../../../controllers/tip_controller.dart';

class UnequalSplit extends StatelessWidget {
  const UnequalSplit({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TipController>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'people_details'.tr,
              style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                controller.addPerson();
              },
              icon: const Icon(Icons.add),
              label: Text('add_person'.tr),
            ),
          ],
        ),
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.peopleList.length,
              itemBuilder: (context, index) {
                final person = controller.peopleList[index];
                return Padding(
                  key: ValueKey(person.id),
                  padding: EdgeInsets.only(bottom: AppSizes.paddingS),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: person.nameController,
                          enableSuggestions: false,
                          autocorrect: false,
                          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                          decoration: InputDecoration(
                            hintText: "${'person_text'.tr} ${person.index + 1}",
                          ),
                          onChanged: (val) => person.name.value = val,
                        ),
                      ),
                      SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: TextField(
                          controller: person.percentController,
                          enableSuggestions: false,
                          autocorrect: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            suffixText: '%',
                            suffixStyle: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.bold),
                            contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingS, vertical: AppSizes.paddingM),
                          ),
                          onChanged: (val) {
                            person.percentage.value = double.tryParse(val) ?? 0.0;
                          },
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.remove_circle_outline, color: Colors.red.withOpacity(0.7), size: AppSizes.iconM),
                        onPressed: () => controller.removePerson(index),
                      ),
                    ],
                  ),
                );
              },
            )),
        Obx(() {
          double total = controller.peopleList.fold(0, (sum, p) => sum + p.percentage.value);
          if ((total - 100).abs() > 0.1 && controller.peopleList.isNotEmpty) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: AppSizes.paddingS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warningAmber, size: AppSizes.fontM),
                  SizedBox(width: AppSizes.paddingS),
                  Text(
                    'total_must_be_100'.tr + ' (${total.toStringAsFixed(1)}%)',
                    style: TextStyle(color: AppColors.warningAmber, fontSize: AppSizes.fontS, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
