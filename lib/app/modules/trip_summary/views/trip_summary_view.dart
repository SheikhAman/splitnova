import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../controllers/tip_controller.dart';
import '../../../data/models/history_model.dart';
import '../controllers/trip_summary_controller.dart';

class TripSummaryView extends GetView<TripSummaryController> {
  const TripSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final tipController = Get.find<TipController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.trip.value?.name ?? 'trip_summary'.tr)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  controller.renameTrip();
                  break;
                case 'edit_bills':
                  controller.editBills();
                  break;
                case 'settle':
                  controller.toggleSettled();
                  break;
                case 'ungroup':
                  controller.ungroupTrip();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'rename', child: Text('rename'.tr)),
              PopupMenuItem(value: 'edit_bills', child: Text('add_remove_bills'.tr)),
              PopupMenuItem(
                value: 'settle',
                child: Obx(() => Text(
                  (controller.trip.value?.isSettled ?? false) ? 'reopen'.tr : 'settle'.tr,
                )),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'ungroup',
                child: Text('ungroup'.tr, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final trip = controller.trip.value;
        if (trip == null) return const Center(child: CircularProgressIndicator());

        final result = controller.aggregation.value;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingL),
          child: RepaintBoundary(
            key: controller.summaryKey,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor, // Ensure background is solid for image capture
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, trip, result),
                  if (result.hasMixedCurrencies) _buildMixedCurrencyWarning(),
                  _buildSectionTitle('grand_total_summary'.tr),
                  ...result.grandTotals.entries.map((entry) => _buildTotalCard(context, tipController, entry.key, entry.value)),
                  _buildSectionTitle('per_person_summary'.tr),
                  _buildPerPersonList(context, tipController, result),
                  _buildSectionTitle('bills_breakdown'.tr),
                  _buildBillsBreakdown(context),
                  SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        );
      }),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildHeader(BuildContext context, trip, result) {
    final dateRange = (result.earliestDate != null && result.latestDate != null)
        ? "${DateFormat.yMMMd().format(result.earliestDate!)} - ${DateFormat.yMMMd().format(result.latestDate!)}"
        : "";

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Color(trip.colorValue ?? Colors.blue.toARGB32()).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Color(trip.colorValue ?? Colors.blue.toARGB32()).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(trip.colorValue ?? Colors.blue.toARGB32()),
            child: Text(trip.emoji ?? '✈️', style: TextStyle(fontSize: 30)),
          ),
          SizedBox(width: AppSizes.paddingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(trip.name,
                          style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.bold)),
                    ),
                    if (trip.isSettled)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Text('settled'.tr.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                Text(dateRange, style: TextStyle(color: Colors.grey, fontSize: AppSizes.fontS)),
                Text('${trip.billIds.length} ${'bills'.tr}', style: TextStyle(color: Colors.grey, fontSize: AppSizes.fontS)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixedCurrencyWarning() {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.paddingM),
      padding: EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber[800]),
          SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text('mixed_currencies_warning'.tr,
                style: TextStyle(fontSize: AppSizes.fontS, color: Colors.amber[900])),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.paddingL, bottom: AppSizes.paddingS),
      child: Text(title,
          style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTotalCard(BuildContext context, TipController tipController, String currency, double amount) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingS),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        side: BorderSide(color: AppColors.getCardBorderColor(context)),
      ),
      child: ListTile(
        title: Text(currency, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(tipController.formatMoney(amount, currency),
            style: TextStyle(fontSize: AppSizes.fontL, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor)),
      ),
    );
  }

  Widget _buildPerPersonList(BuildContext context, TipController tipController, result) {
    return Column(
      children: result.perPersonTotals.entries.map<Widget>((entry) {
        final currency = entry.key;
        final list = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.hasMixedCurrencies)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(currency, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ...list.map((p) => Card(
              margin: EdgeInsets.only(bottom: AppSizes.paddingS),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                side: BorderSide(color: AppColors.getCardBorderColor(context)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.getPrimaryLight(context),
                  child: Text(p.displayName[0].toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
                title: Text(p.displayName, style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${p.sharePercentage.toStringAsFixed(1)}% ${'of_total'.tr}"),
                trailing: Text(tipController.formatMoney(p.totalAmount, p.currency),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ),
            )),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBillsBreakdown(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.referencedBills.length,
      itemBuilder: (context, index) {
        final item = controller.referencedBills[index];
        return _ReadOnlyHistoryItem(item: item);
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.exportPdf(),
              icon: Icon(Icons.picture_as_pdf),
              label: Text('pdf'.tr),
            ),
          ),
          SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.showShareOptions(),
              icon: Icon(Icons.share),
              label: Text('share'.tr),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyHistoryItem extends StatelessWidget {
  final HistoryItem item;
  const _ReadOnlyHistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final tipController = Get.find<TipController>();
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        side: BorderSide(color: AppColors.getCardBorderColor(context)),
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
          key: PageStorageKey('trip_history_${item.id}'),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          tilePadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingS),
          leading: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
          title: Text(
            tipController.formatMoney(item.bill + item.tipAmount, item.currency),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: AppSizes.fontL),
          ),
          subtitle: Text(DateFormat.yMMMd().format(item.date)),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSizes.paddingL, 0, AppSizes.paddingL, AppSizes.paddingL),
              child: Column(
                children: [
                  _row('bill'.tr, tipController.formatMoney(item.bill, item.currency)),
                  _row('tip'.tr, tipController.formatMoney(item.tipAmount, item.currency)),
                  if (item.reason != null && item.reason!.isNotEmpty)
                    _row('note'.tr, item.reason!),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
