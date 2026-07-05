import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/history_model.dart';
import '../../../controllers/trip_controller.dart';
import '../../../controllers/tip_controller.dart';
import '../../../data/services/trip_aggregation_service.dart';
import '../../../routes/app_pages.dart';
import '../history_controller.dart';

class TripListItem extends StatelessWidget {
  final TripModel trip;
  final HistoryController controller;

  const TripListItem({
    super.key,
    required this.trip,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final tipController = Get.find<TipController>();
    
    // Calculate aggregate for the card
    final allHistory = controller.historyList
        .map((e) => HistoryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    
    final referencedBills = allHistory
        .where((h) => trip.billIds.contains(h.id))
        .toList();

    final result = TripAggregationService.aggregate(referencedBills);

    return InkWell(
      onTap: () => Get.toNamed(Routes.TRIP_SUMMARY, arguments: trip.id),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Card(
        margin: EdgeInsets.only(bottom: AppSizes.paddingM),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: BorderSide(
            color: trip.colorValue != null 
                ? Color(trip.colorValue!).withValues(alpha: 0.5) 
                : AppColors.getCardBorderColor(context)
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: (trip.colorValue != null ? Color(trip.colorValue!) : Colors.orange).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Text(trip.emoji ?? '✈️', style: TextStyle(fontSize: AppSizes.iconM)),
                  ),
                  SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '${trip.billIds.length} ${'bills'.tr} • ${DateFormat('MMM dd, yyyy').format(DateTime.parse(trip.createdAt))}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (trip.isSettled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text('settled'.tr.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('grand_total'.tr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  _buildTotalDisplay(tipController, result),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalDisplay(TipController tipController, TripAggregationResult result) {
    if (result.hasMixedCurrencies) {
      return Text('mixed_currencies_warning'.tr.split('—').first.trim(), 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange));
    }
    
    if (result.grandTotals.isEmpty) {
      return const Text('---', style: TextStyle(fontWeight: FontWeight.bold));
    }

    final entry = result.grandTotals.entries.first;
    return Text(
      tipController.formatMoney(entry.value, entry.key),
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
    );
  }
}
