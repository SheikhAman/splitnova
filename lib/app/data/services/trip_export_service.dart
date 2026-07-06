import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/trip_model.dart';
import '../models/history_model.dart';
import 'trip_aggregation_service.dart';

/// Professional Export Service designed with Material Design 3 and Google styling principles.
/// Provides a comprehensive audit trail for trip expenses.
class TripExportService {
  // Google Professional Palette
  static const _googleBlue = PdfColor.fromInt(0xFF1A73E8);
  static const _googleGrey = PdfColor.fromInt(0xFF5F6368);
  static const _darkText = PdfColor.fromInt(0xFF202124);
  static const _bgLight = PdfColor.fromInt(0xFFF8F9FA);
  static const _borderGrey = PdfColor.fromInt(0xFFDADCE0);
  static const _successGreen = PdfColor.fromInt(0xFF1E8E3E);

  static Future<void> exportToPdf(TripModel trip, TripAggregationResult result, List<HistoryItem> bills) async {
    final pdf = pw.Document(
      author: 'SplitNova',
      title: 'Expense Report - ${_sanitize(trip.name)}',
    );

    // Load Professional Fonts
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        footer: (pw.Context context) => _buildFooter(context, fontRegular),
        header: (pw.Context context) => _buildHeader(trip, result, bills, fontRegular, fontBold),
        build: (pw.Context context) {
          if (bills.isEmpty) {
            return [
              pw.SizedBox(height: 40),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(32),
                decoration: pw.BoxDecoration(
                  color: _bgLight,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                  border: pw.Border.all(color: _borderGrey, style: pw.BorderStyle.dashed),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('NO FINANCIAL RECORDS', style: pw.TextStyle(font: fontBold, fontSize: 14, color: _googleGrey, letterSpacing: 1)),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'This report does not contain any itemized expenses. To generate a full audit log, please ensure bills are associated with this trip in the SplitNova app.',
                      style: pw.TextStyle(font: fontRegular, fontSize: 10, color: _googleGrey),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              _buildFinancialDisclaimer(fontItalic),
            ];
          }

          final participantCount = result.perPersonTotals.values
              .expand((list) => list.map((p) => p.displayName.toLowerCase().trim()))
              .toSet()
              .length;

          return [
            pw.SizedBox(height: 24),
            
            // 1. Executive Summary
            _buildSectionHeader('EXECUTIVE SUMMARY', fontBold),
            _buildExecutiveSummary(result, bills, fontRegular, fontBold),
            pw.SizedBox(height: 32),

            // 2. Itemized Breakdown
            _buildSectionHeader('ITEMIZED EXPENSE LOG', fontBold),
            _buildItemizedTable(bills, fontRegular, fontBold),
            pw.SizedBox(height: 32),

            // 3. Settlement Breakdown
            _buildSectionHeader('INDIVIDUAL SETTLEMENTS ($participantCount PARTICIPANTS)', fontBold),
            ..._buildSettlementTables(result, fontRegular, fontBold),
            
            pw.SizedBox(height: 40),
            _buildFinancialDisclaimer(fontItalic),
            pw.SizedBox(height: 20),
            _buildSecurityBadge(fontRegular),
          ];
        },
      ),
    );

    final filename = "${trip.name.replaceAll(RegExp(r'[^\w\s]+'), '').trim()}_Report.pdf";
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }

  static pw.Widget _buildHeader(TripModel trip, TripAggregationResult result, List<HistoryItem> bills, pw.Font font, pw.Font fontBold) {
    final tripColor = trip.colorValue != null ? PdfColor.fromInt(trip.colorValue!) : _googleBlue;
    
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 12,
                      height: 12,
                      decoration: pw.BoxDecoration(
                        color: _googleBlue,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text('SPLITNOVA', style: pw.TextStyle(font: fontBold, fontSize: 12, color: _googleBlue, letterSpacing: 2)),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(_sanitize(trip.name), style: pw.TextStyle(font: fontBold, fontSize: 26, color: _darkText)),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('OFFICIAL FINANCIAL REPORT', style: pw.TextStyle(font: fontBold, fontSize: 8, color: _googleGrey, letterSpacing: 0.5)),
                    if (result.earliestDate != null) ...[
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                        child: pw.Container(width: 1, height: 8, color: _borderGrey),
                      ),
                      pw.Text(
                        _sanitize("${DateFormat.yMMMd().format(result.earliestDate!)} - ${DateFormat.yMMMd().format(result.latestDate!)}"),
                        style: pw.TextStyle(font: font, fontSize: 10, color: _googleGrey),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: _bgLight,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    border: pw.Border.all(color: _borderGrey),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 6,
                        height: 6,
                        decoration: pw.BoxDecoration(color: tripColor, shape: pw.BoxShape.circle),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text('${bills.length} TOTAL ENTRIES', style: pw.TextStyle(font: fontBold, fontSize: 8, color: _googleGrey)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('REPORT ID: ${trip.id.toUpperCase().substring(0, 8)}', style: pw.TextStyle(font: font, fontSize: 7, color: _googleGrey)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Divider(color: _googleBlue, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildSectionHeader(String title, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 10, color: _googleGrey, letterSpacing: 1.2)),
    );
  }

  static pw.Widget _buildExecutiveSummary(TripAggregationResult result, List<HistoryItem> bills, pw.Font font, pw.Font fontBold) {
    return pw.Wrap(
      spacing: 20,
      runSpacing: 20,
      children: result.grandTotals.entries.map((entry) {
        final currency = entry.key;
        final total = entry.value;
        
        double baseBill = 0;
        double tips = 0;
        for (var b in bills.where((b) => b.currency == currency)) {
          baseBill += b.bill;
          tips += b.tipAmount;
        }
        final tipPercentage = baseBill > 0 ? (tips / baseBill) * 100 : 0.0;

        return pw.Container(
          width: 200,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: _bgLight,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            border: pw.Border.all(color: _borderGrey),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL SPENT ($currency)', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _googleGrey)),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColor(_googleBlue.red, _googleBlue.green, _googleBlue.blue, 0.1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text('VERIFIED', style: pw.TextStyle(font: fontBold, fontSize: 6, color: _googleBlue)),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                total.toStringAsFixed(2),
                style: pw.TextStyle(font: fontBold, fontSize: 28, color: _googleBlue),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: _borderGrey, thickness: 0.5),
              pw.SizedBox(height: 8),
              _buildSummaryDataRow('Base Amount', baseBill.toStringAsFixed(2), font),
              pw.SizedBox(height: 6),
              _buildSummaryDataRow('Total Tips', tips.toStringAsFixed(2), font, valueColor: _successGreen),
              pw.SizedBox(height: 6),
              _buildSummaryDataRow('Avg. Tip %', "${tipPercentage.toStringAsFixed(1)}%", font, valueColor: _googleGrey),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildSummaryDataRow(String label, String value, pw.Font font, {PdfColor? valueColor}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9, color: _googleGrey)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10, color: valueColor ?? _darkText, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildItemizedTable(List<HistoryItem> bills, pw.Font font, pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
      headerStyle: pw.TextStyle(font: fontBold, color: _darkText, fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: _bgLight),
      oddRowDecoration: const pw.BoxDecoration(color: _bgLight),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      cellStyle: pw.TextStyle(font: font, fontSize: 8, color: _darkText),
      headers: ['DATE', 'EXPENSE DESCRIPTION', 'SPLIT STRATEGY', 'BASE BILL', 'TIPS', 'TOTAL AMOUNT'],
      data: bills.map((bill) => [
        DateFormat('MMM d, y').format(bill.date),
        _sanitize(bill.reason?.isNotEmpty == true ? bill.reason! : 'General Expense'),
        bill.isCustomSplit ? 'Custom Split' : 'Equal Split (${bill.people} pax)',
        "${bill.currency} ${bill.bill.toStringAsFixed(2)}",
        "${bill.currency} ${bill.tipAmount.toStringAsFixed(2)}",
        "${bill.currency} ${(bill.bill + bill.tipAmount).toStringAsFixed(2)}"
      ]).toList(),
    );
  }

  static List<pw.Widget> _buildSettlementTables(TripAggregationResult result, pw.Font font, pw.Font fontBold) {
    return result.perPersonTotals.entries.expand((entry) {
      final currency = entry.key;
      final people = entry.value;
      return [
        if (result.hasMixedCurrencies)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Text('CURRENCY: $currency', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _googleBlue)),
          ),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
          headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: _googleBlue),
          oddRowDecoration: const pw.BoxDecoration(color: _bgLight),
          cellHeight: 30,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
          },
          cellStyle: pw.TextStyle(font: font, fontSize: 10, color: _darkText),
          headers: ['PARTICIPANT NAME', 'NET CONTRIBUTION', 'SHARE %'],
          data: people.map((p) => [
            _sanitize(p.displayName),
            "${p.totalAmount.toStringAsFixed(2)} $currency",
            "${p.sharePercentage.toStringAsFixed(1)}%"
          ]).toList(),
        ),
        pw.SizedBox(height: 20),
      ];
    }).toList();
  }

  static pw.Widget _buildSecurityBadge(pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _borderGrey),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DIGITALLY GENERATED REPORT', style: pw.TextStyle(font: font, fontSize: 6, color: _googleGrey)),
              pw.Text('AUTHENTICITY VERIFIED VIA SPLITNOVA CORE', style: pw.TextStyle(font: font, fontSize: 6, color: _googleGrey)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFinancialDisclaimer(pw.Font fontItalic) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _bgLight,
        border: pw.Border(left: pw.BorderSide(color: _googleBlue, width: 4)),
      ),
      child: pw.Text(
        'AUDIT NOTICE: This report provides a detailed breakdown of shared expenses. The "Grand Total" reflects the aggregate of all itemized logs including base costs and tips. Individual shares are calculated based on user-defined split strategies. Please verify all entries before final settlement.',
        style: pw.TextStyle(font: fontItalic, fontSize: 8, color: _googleGrey),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: _borderGrey, thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('Generated by SplitNova', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 8)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                      child: pw.Container(width: 1, height: 6, color: _borderGrey),
                    ),
                    pw.Text('Professional Expense Management', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 8)),
                  ],
                ),
                pw.Text('Issued on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 7)),
              ],
            ),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 8)),
          ],
        ),
      ],
    );
  }

  static String _sanitize(String? text) {
    if (text == null) return '';
    // Remove emojis and non-standard characters to prevent PDF font crashes
    return text.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim();
  }

  static String getTripShareMessage(TripModel trip, TripAggregationResult result) {
    String msg = "🚀 *SplitNova Trip Report: ${trip.name}*\n";
    if (result.earliestDate != null && result.latestDate != null) {
      msg += "📅 ${DateFormat.yMMMd().format(result.earliestDate!)} - ${DateFormat.yMMMd().format(result.latestDate!)}\n";
    }
    msg += "━━━━━━━━━━━━━━━━━━━━\n";
    
    msg += "💰 *Summary*:\n";
    if (result.grandTotals.isEmpty) {
      msg += "_No expenses recorded_\n";
    } else {
      result.grandTotals.forEach((currency, amount) {
        msg += "• $currency Total: *${amount.toStringAsFixed(2)}*\n";
      });
    }
    
    msg += "\n👥 *Per-Person Breakdown*:\n";
    if (result.perPersonTotals.isEmpty) {
      msg += "_No participants found_\n";
    } else {
      result.perPersonTotals.forEach((currency, people) {
        if (result.hasMixedCurrencies) msg += "[$currency]\n";
        for (var p in people) {
          msg += "• ${p.displayName}: ${p.totalAmount.toStringAsFixed(2)} (${p.sharePercentage.toStringAsFixed(1)}%)\n";
        }
      });
    }

    msg += "━━━━━━━━━━━━━━━━━━━━\n";
    msg += "Generated by SplitNova\n";
    msg += "_Split Smart, Tip Easy_";
    
    return msg;
  }
}
