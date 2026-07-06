import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../controllers/tip_controller.dart';
import '../../../data/models/history_model.dart';
import '../history_controller.dart';

class HistoryListItem extends StatelessWidget {
  final HistoryItem item;
  final HistoryController controller;
  final VoidCallback onShowQRCode;
  final Function(String message) onShowToast;

  const HistoryListItem({
    super.key,
    required this.item,
    required this.controller,
    required this.onShowQRCode,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    final tipController = Get.find<TipController>();

    return Obx(() {
      final isSelected = controller.selectedIds.contains(item.id);
      return GestureDetector(
        onLongPress: () => controller.toggleSelection(item.id),
        onTap: () {
          if (controller.isSelectionMode.value) {
            controller.toggleSelection(item.id);
          }
        },
        child: Stack(
          children: [
            Card(
              margin: EdgeInsets.only(bottom: AppSizes.paddingM),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : AppColors.getCardBorderColor(context),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: const ExpansionTileThemeData(
                    shape: RoundedRectangleBorder(side: BorderSide.none),
                    collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
                  ),
                ),
                child: ExpansionTile(
                  // Use a very specific key to avoid collision with scrollable children state
                  key: PageStorageKey('history_tile_v5_${item.id}'),
                  maintainState: true,
                  enabled: !controller.isSelectionMode.value,
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                  tilePadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL, vertical: AppSizes.paddingS),
                  leading: Container(
                    padding: EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryLight(context),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(Icons.receipt_long,
                        color: Theme.of(context).primaryColor, size: AppSizes.iconL),
                  ),
                  title: _buildTitle(context, tipController),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(item.date),
                    style: TextStyle(fontSize: AppSizes.fontXS, color: Colors.grey),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          AppSizes.paddingL, 0, AppSizes.paddingL, AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          SizedBox(height: AppSizes.paddingS),
                          _buildDetailsGrid(context, tipController),
                          if (item.isCustomSplit && item.peopleList != null)
                            _buildCustomSplitDetails(context, tipController),
                          SizedBox(height: AppSizes.paddingL),
                          _buildActionButtons(context, tipController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isSelectionMode.value)
              Positioned(
                top: AppSizes.paddingS,
                right: AppSizes.paddingS,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  child: Icon(
                    Icons.check,
                    size: AppSizes.iconS,
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTitle(BuildContext context, TipController tipController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tipController.formatMoney(item.bill + item.tipAmount, item.currency),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: AppSizes.fontXL),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.reason != null && item.reason!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.paddingXS / 2),
                  child: Text(
                    item.reason!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: AppSizes.fontS,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingS, vertical: AppSizes.paddingXS),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline,
                  size: AppSizes.fontM, color: Colors.grey[600]),
              SizedBox(width: AppSizes.paddingXS),
              Text(
                '${item.people}',
                style: TextStyle(
                    fontSize: AppSizes.fontS,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(BuildContext context, TipController tipController) {
    return GridView.count(
      key: PageStorageKey('history_details_grid_${item.id}'),
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      children: [
        _buildInfoRow(context, 'bill_amount'.tr,
            tipController.formatMoney(item.bill, item.currency)),
        _buildInfoRow(context, 'tip_amount'.tr,
            tipController.formatMoney(item.tipAmount, item.currency)),
        _buildInfoRow(
            context,
            'total_amount'.tr,
            tipController.formatMoney(item.bill + item.tipAmount, item.currency),
            isBold: true),
        _buildInfoRow(
            context,
            'per_person'.tr,
            tipController.formatMoney(item.totalPerPerson, item.currency),
            isBold: true),
      ],
    );
  }

  Widget _buildCustomSplitDetails(BuildContext context, TipController tipController) {
    final double totalAmount = item.bill + item.tipAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSizes.paddingM),
        Text('people_details'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontM)),
        SizedBox(height: AppSizes.paddingS),
        Container(
          padding: EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Column(
            children: item.peopleList!.map((p) {
              double amount = totalAmount * (p.percentage / 100);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: AppSizes.fontM, color: Colors.grey),
                          SizedBox(width: AppSizes.paddingS),
                          Expanded(
                            child: Text(
                              p.name,
                              style: TextStyle(
                                  fontSize: AppSizes.fontS,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(tipController.formatMoney(amount, item.currency),
                            style: TextStyle(
                                fontSize: AppSizes.fontS,
                                fontWeight: FontWeight.bold)),
                        Text('${p.percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: AppSizes.fontXS, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, TipController tipController) {
    return Row(
      children: [
        Expanded(
          child: _buildActionIcon(
            context,
            Icons.edit_outlined,
            'edit'.tr,
            Colors.orange,
            () => controller.loadItemToCalculator(item),
          ),
        ),
        SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: _buildActionIcon(
            context,
            Icons.share_outlined,
            'share'.tr,
            Colors.green,
            () {
              final msg = controller.getHistoryShareMessage(item);
              tipController.shareToWhatsApp(msg);
            },
          ),
        ),
        SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: _buildActionIcon(
            context,
            Icons.content_copy_outlined,
            'copy'.tr,
            Colors.teal,
            () {
              final msg = controller.getHistoryShareMessage(item);
              Clipboard.setData(ClipboardData(text: msg));
              onShowToast('copied_to_clipboard'.tr);
            },
          ),
        ),
        SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: _buildActionIcon(
            context,
            Icons.qr_code_2_outlined,
            'qr'.tr,
            Colors.purple,
            onShowQRCode,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: AppSizes.fontXS, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Theme.of(context).primaryColor : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: AppSizes.paddingS, horizontal: AppSizes.paddingXS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: AppSizes.iconM),
            SizedBox(height: AppSizes.paddingXS),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: AppSizes.fontXS,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
