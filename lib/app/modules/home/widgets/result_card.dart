import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../controllers/tip_controller.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TipController>();

    return Obx(() => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL + 4),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Upper Section: Summary & Details
          Padding(
            padding: EdgeInsets.fromLTRB(AppSizes.paddingXL, AppSizes.paddingXXL, AppSizes.paddingXL, AppSizes.paddingL),
            child: Column(
              children: [
                // 1. Note Tag (if enabled)
                if (controller.isReasonEnabled.value && controller.billReason.value.isNotEmpty)
                  _buildPremiumNote(controller.billReason.value),
                
                // 2. Bill & Tip Summary (Always visible in Custom Split)
                if (controller.isCustomSplit.value)
                  _buildSummarySection(context, controller)
                else
                  _buildStandardPerPerson(context, controller),
                
                SizedBox(height: AppSizes.paddingL),

                // 3. Scrollable People Area (Height-Constrained)
                if (controller.isCustomSplit.value)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(Colors.white30),
                        )
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        thickness: 4,
                        radius: Radius.circular(AppSizes.radiusS),
                        child: GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXS), // Symmetric padding for balance
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 52.0,
                            crossAxisSpacing: AppSizes.paddingS,
                            mainAxisSpacing: AppSizes.paddingS,
                          ),
                          itemCount: controller.peopleList.length,
                          itemBuilder: (context, index) {
                            final person = controller.peopleList[index];
                            return _buildPersonGridItem(controller, person);
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Professional Dashed Divider
          _buildDashedDivider(),
          
          // Footer: Grand Total
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXXL, vertical: AppSizes.paddingXL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'total_amount'.tr.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: AppSizes.fontXS + 1, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Text(
                        'grand_total'.tr,
                        style: TextStyle(
                          color: Colors.white54, 
                          fontSize: AppSizes.fontXS,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      controller.formatMoney(controller.totalAmount),
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: AppSizes.fontXXXL + 4, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPremiumNote(String note) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.paddingXXL),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingS + 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingXS + 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(Icons.description_rounded, color: Colors.white, size: AppSizes.fontXS + 4),
          ),
          SizedBox(width: AppSizes.paddingM),
          Flexible(
            child: Text(
              note,
              style: TextStyle(
                color: Colors.white, 
                fontSize: AppSizes.fontM - 1, 
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, TipController controller) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingXL - 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL - 2),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildSummaryItem('bill_amount'.tr, controller.formatMoney(controller.billAmount.value), Icons.receipt_long_rounded),
          Container(width: 1, height: 34.0, color: Colors.white10, margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXL - 2)),
          _buildSummaryItem('tip_amount'.tr, controller.formatMoney(controller.tipAmount), Icons.auto_awesome_rounded),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: Colors.white70, size: AppSizes.iconM - 4),
          ),
          SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label.toUpperCase(), 
                    style: TextStyle(
                      color: Colors.white54, 
                      fontSize: AppSizes.fontXS - 1, 
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ), 
                  ),
                ),
                SizedBox(height: 2.0),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value, 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: AppSizes.fontL - 1, 
                      fontWeight: FontWeight.w800,
                    ), 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardPerPerson(BuildContext context, TipController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXL, horizontal: AppSizes.paddingS + 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL - 2),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLargeResultItem('tip_per_person'.tr, controller.formatMoney(controller.tipPerPerson)),
          Container(width: 1, height: 40.0, color: Colors.white10),
          _buildLargeResultItem('total_per_person'.tr, controller.formatMoney(controller.totalPerPerson)),
        ],
      ),
    );
  }

  Widget _buildLargeResultItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(), 
            style: TextStyle(
              color: Colors.white60, 
              fontSize: AppSizes.fontXS, 
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )
          ),
          SizedBox(height: AppSizes.paddingS),
          Text(
            value, 
            style: TextStyle(
              color: Colors.white, 
              fontSize: AppSizes.fontXXXL, 
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildPersonGridItem(TipController controller, dynamic person) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                  person.displayName,
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w700, 
                    fontSize: AppSizes.fontXS + 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                SizedBox(height: 1.0),
                Obx(() => Text(
                  '${person.percentage.value}%',
                  style: TextStyle(
                    color: Colors.white38, 
                    fontSize: AppSizes.fontXS - 1,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Obx(() => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                controller.formatMoney(person.getAmount(controller.totalAmount)),
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w800, 
                  fontSize: AppSizes.fontS,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Row(
        children: List.generate(40, (index) => Expanded(
          child: Container(
            height: 1.5,
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              color: index % 2 == 0 ? Colors.white24 : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }
}
