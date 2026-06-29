import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/values/app_constants.dart';
import 'history_controller.dart';
import '../../controllers/tip_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('history'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        final list = controller.historyList;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: AppSizes.iconXXL * 2, color: Colors.grey.withValues(alpha: 0.5)),
                SizedBox(height: AppSizes.paddingL),
                Text('no_history'.tr, style: TextStyle(fontSize: AppSizes.fontL, color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(AppSizes.paddingL),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final DateTime date = DateTime.parse(item['date']);
            final tipController = Get.find<TipController>();

            return Dismissible(
              key: Key('${item['id']}_$index'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await Get.dialog<bool>(
                  AlertDialog(
                    title: Text('delete_item'.tr),
                    content: Text('are_you_sure'.tr),
                    actions: [
                      TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) => controller.deleteItem(index),
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: AppSizes.paddingXL),
                margin: EdgeInsets.only(bottom: AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: EdgeInsets.only(bottom: AppSizes.paddingM),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  side: BorderSide(color: AppColors.getCardBorderColor(context)),
                ),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                  tilePadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingS),
                  leading: Container(
                    padding: EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryLight(context),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor, size: AppSizes.iconL),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tipController.formatMoney(
                                ((item['bill'] as num) + (item['tipAmount'] as num)).toDouble(), 
                                item['currency']
                              ),
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: AppSizes.fontXL),
                            ),
                            if (item['reason'] != null && (item['reason'] as String).isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: AppSizes.paddingXS / 2),
                                child: Text(
                                  item['reason'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppSizes.fontS, 
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingS, vertical: AppSizes.paddingXS),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: AppSizes.fontM, color: Colors.grey[600]),
                            SizedBox(width: AppSizes.paddingXS),
                            Text(
                              '${item['people']}',
                              style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                    style: TextStyle(fontSize: AppSizes.fontXS, color: Colors.grey),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(AppSizes.paddingL, 0, AppSizes.paddingL, AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          SizedBox(height: AppSizes.paddingS),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            children: [
                              _buildInfoRow(context, 'bill_amount'.tr, tipController.formatMoney((item['bill'] as num).toDouble(), item['currency'])),
                              _buildInfoRow(context, 'tip_amount'.tr, tipController.formatMoney((item['tipAmount'] as num).toDouble(), item['currency'])),
                              _buildInfoRow(context, 'total_amount'.tr, tipController.formatMoney(((item['bill'] as num) + (item['tipAmount'] as num)).toDouble(), item['currency']), isBold: true),
                              _buildInfoRow(context, 'per_person'.tr, tipController.formatMoney((item['totalPerPerson'] as num).toDouble(), item['currency']), isBold: true),
                            ],
                          ),
                          if (item['isCustomSplit'] == true && item['peopleList'] != null) ...[
                            SizedBox(height: AppSizes.paddingM),
                            Text('people_details'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontM)),
                            SizedBox(height: AppSizes.paddingS),
                            Container(
                              padding: EdgeInsets.all(AppSizes.paddingM),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              ),
                              child: Column(
                                children: (item['peopleList'] as List).map((p) {
                                  double amount = ((item['bill'] as num).toDouble() + (item['tipAmount'] as num).toDouble()) * ((p['percentage'] as num).toDouble() / 100);
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline, size: AppSizes.fontM, color: Colors.grey),
                                            SizedBox(width: AppSizes.paddingS),
                                            Text(p['name'], style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(tipController.formatMoney(amount, item['currency']), style: TextStyle(fontSize: AppSizes.fontS, fontWeight: FontWeight.bold)),
                                            Text('${p['percentage']}%', style: TextStyle(fontSize: AppSizes.fontXS, color: Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                          SizedBox(height: AppSizes.paddingL),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionIcon(context, Icons.edit_outlined, 'edit'.tr, Colors.orange, () => controller.loadItemToCalculator(item)),
                              _buildActionIcon(context, Icons.share_outlined, 'share'.tr, Colors.green, () {
                                final msg = controller.getHistoryShareMessage(item);
                                tipController.shareToWhatsApp(msg);
                              }),
                              _buildActionIcon(context, Icons.content_copy_outlined, 'copy'.tr, Colors.teal, () {
                                final msg = controller.getHistoryShareMessage(item);
                                Clipboard.setData(ClipboardData(text: msg));
                                _showToast('success'.tr, 'copied_to_clipboard'.tr);
                              }),
                              _buildActionIcon(context, Icons.qr_code_2_outlined, 'qr'.tr, Colors.purple, () {
                                final msg = controller.getHistoryShareMessage(item);
                                _showQRCodeBottomSheet(context, msg);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Get.offAllNamed('/home');
          if (index == 2) Get.offAllNamed('/settings');
        },
        selectedItemColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.calculate), label: 'calculator'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: 'history'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'settings'.tr),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: AppSizes.fontXS, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: AppSizes.fontM, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Theme.of(context).primaryColor : null)),
      ],
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: AppSizes.iconM),
            SizedBox(height: AppSizes.paddingXS),
            Text(label, style: TextStyle(fontSize: AppSizes.fontXS, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showToast(String title, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      textColor: Colors.white,
      fontSize: AppSizes.fontM,
    );
  }

  void _showQRCodeBottomSheet(BuildContext context, String data) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(AppSizes.paddingXXL, AppSizes.paddingM, AppSizes.paddingXXL, AppSizes.paddingXXL),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.iconXXL,
                height: 4.0, // Fixed small height for handle
                margin: EdgeInsets.only(bottom: AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Text('qr_code'.tr, style: TextStyle(fontSize: AppSizes.fontXL, fontWeight: FontWeight.bold)),
              SizedBox(height: AppSizes.paddingXL),
              Screenshot(
                controller: controller.qrScreenshotController,
                child: Container(
                  padding: EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    size: 200.0, // Fixed size for QR
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.paddingL),
              Text('scan_me'.tr, style: TextStyle(fontSize: AppSizes.fontM, color: Colors.grey)),
              SizedBox(height: AppSizes.paddingXXL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.shareQRCode(),
                      icon: const Icon(Icons.share),
                      label: Text('share'.tr),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 48.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: Size(0, 48.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
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
    );
  }

  void _showClearAllDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('clear_history'.tr),
        content: Text('are_you_sure'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              controller.clearAllHistory();
              Get.back();
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
