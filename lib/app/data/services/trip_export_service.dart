import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/trip_model.dart';
import '../models/history_model.dart';
import 'trip_aggregation_service.dart';

/// Professional Export Service designed with Material Design 3 and Google styling principles.
/// Enhanced with embedded per-person breakdowns for maximum transparency.
class TripExportService {
  // Google Professional Palette
  static const _googleBlue = PdfColor.fromInt(0xFF1A73E8);
  static const _googleGrey = PdfColor.fromInt(0xFF5F6368);
  static const _darkText = PdfColor.fromInt(0xFF202124);
  static const _bgLight = PdfColor.fromInt(0xFFF8F9FA);
  static const _borderGrey = PdfColor.fromInt(0xFFDADCE0);
  static const _successGreen = PdfColor.fromInt(0xFF1E8E3E);
  static const _dividerGrey = PdfColor.fromInt(0xFFE8EAED);

  static Future<void> exportToPdf(TripModel trip, TripAggregationResult result, List<HistoryItem> bills) async {
    final pdf = pw.Document(
      author: 'SplitNova',
      title: 'Financial Report - ${_sanitize(trip.name)}',
    );

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        footer: (pw.Context context) => _buildFooter(context, fontRegular),
        header: (pw.Context context) => _buildHeader(trip, result, bills, fontRegular, fontBold),
        build: (pw.Context context) {
          if (bills.isEmpty) {
            return [
              pw.SizedBox(height: 60),
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
                    pw.Text('NO FINANCIAL DATA AVAILABLE', style: pw.TextStyle(font: fontBold, fontSize: 14, color: _googleGrey, letterSpacing: 1.2)),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'This report contains no itemized expenses. Ensure bills are associated with this trip in the app to generate a full audit trail.',
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
            pw.SizedBox(height: 20),
            
            // 1. Executive Summary
            _buildSectionHeader('EXECUTIVE SUMMARY', fontBold),
            _buildExecutiveSummary(result, bills, fontRegular, fontBold),
            pw.SizedBox(height: 32),

            // 2. Detailed Itemized Ledger (Embedded Splits)
            _buildSectionHeader('ITEMIZED FINANCIAL LEDGER', fontBold),
            _buildItemizedLedger(bills, fontRegular, fontBold),
            pw.SizedBox(height: 32),

            // 3. Settlement Summary
            _buildSectionHeader('SETTLEMENT SUMMARY ($participantCount PARTICIPANTS)', fontBold),
            ..._buildSettlementSummary(result, fontRegular, fontBold),
            
            pw.SizedBox(height: 40),
            _buildFinancialDisclaimer(fontItalic),
            pw.SizedBox(height: 24),
            _buildSecurityBadge(fontRegular),
          ];
        },
      ),
    );

    final filename = "${trip.name.replaceAll(RegExp(r'[^\w\s]+'), '').trim()}_Financial_Report.pdf";
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
                      width: 14,
                      height: 14,
                      decoration: pw.BoxDecoration(color: _googleBlue, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text('SPLITNOVA', style: pw.TextStyle(font: fontBold, fontSize: 14, color: _googleBlue, letterSpacing: 2.5)),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(_sanitize(trip.name), style: pw.TextStyle(font: fontBold, fontSize: 28, color: _darkText)),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('CERTIFIED FINANCIAL STATEMENT', style: pw.TextStyle(font: fontBold, fontSize: 8, color: _googleGrey, letterSpacing: 0.8)),
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
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: _bgLight,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                    border: pw.Border.all(color: _borderGrey),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(color: tripColor, shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 8),
                      pw.Text('${bills.length} ENTRIES', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _googleGrey)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('DOC-ID: ${trip.id.toUpperCase().substring(0, 8)}', style: pw.TextStyle(font: font, fontSize: 8, color: _googleGrey)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Divider(color: _googleBlue, thickness: 2),
      ],
    );
  }

  static pw.Widget _buildSectionHeader(String title, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 11, color: _googleGrey, letterSpacing: 1.5)),
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
          width: 230,
          padding: const pw.EdgeInsets.all(20),
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
                  pw.Text('GRAND TOTAL ($currency)', style: pw.TextStyle(font: fontBold, fontSize: 10, color: _googleGrey)),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: PdfColor(_googleBlue.red, _googleBlue.green, _googleBlue.blue, 0.1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text('VERIFIED', style: pw.TextStyle(font: fontBold, fontSize: 7, color: _googleBlue)),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(total.toStringAsFixed(2), style: pw.TextStyle(font: fontBold, fontSize: 32, color: _googleBlue)),
              pw.SizedBox(height: 16),
              pw.Divider(color: _dividerGrey, thickness: 1),
              pw.SizedBox(height: 12),
              _buildSummaryDataRow('Subtotal (Base)', baseBill.toStringAsFixed(2), font),
              pw.SizedBox(height: 8),
              _buildSummaryDataRow('Gratuity (Tips)', tips.toStringAsFixed(2), font, valueColor: _successGreen),
              pw.SizedBox(height: 8),
              _buildSummaryDataRow('Tip Avg.', "${tipPercentage.toStringAsFixed(1)}%", font, valueColor: _googleGrey),
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
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10, color: _googleGrey)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11, color: valueColor ?? _darkText, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildItemizedLedger(List<HistoryItem> bills, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _dividerGrey, width: 0.5),
        bottom: pw.BorderSide(color: _dividerGrey, width: 0.5),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(65),
        1: const pw.FlexColumnWidth(2.2),
        2: const pw.FlexColumnWidth(3.2),
        3: const pw.FixedColumnWidth(85),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: _bgLight,
            border: pw.Border(bottom: pw.BorderSide(color: _googleBlue, width: 2)),
          ),
          children: [
            _buildTableHeaderCell('DATE', fontBold),
            _buildTableHeaderCell('DESCRIPTION', fontBold),
            _buildTableHeaderCell('PARTICIPANT BREAKDOWN', fontBold),
            _buildTableHeaderCell('TOTAL', fontBold, align: pw.Alignment.centerRight),
          ],
        ),
        ...bills.map((bill) {
          final totalBill = bill.bill + bill.tipAmount;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: pw.Text(DateFormat('MMM d, y').format(bill.date), style: pw.TextStyle(font: font, fontSize: 8, color: _googleGrey)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_sanitize(bill.reason?.isNotEmpty == true ? bill.reason! : 'General Expense'), 
                        style: pw.TextStyle(font: fontBold, fontSize: 9, color: _darkText)),
                    pw.SizedBox(height: 3),
                    pw.Text(bill.isCustomSplit ? 'PRO-RATA SPLIT' : 'EQUAL (${bill.people} PAX)', 
                        style: pw.TextStyle(font: font, fontSize: 7, color: _googleGrey, letterSpacing: 0.5)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: _buildEmbeddedSplitSummary(bill, font, fontBold),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: pw.Text("${bill.currency} ${totalBill.toStringAsFixed(2)}", 
                    style: pw.TextStyle(font: fontBold, fontSize: 10, color: _googleBlue), textAlign: pw.TextAlign.right),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildEmbeddedSplitSummary(HistoryItem bill, pw.Font font, pw.Font fontBold) {
    final totalBill = bill.bill + bill.tipAmount;
    
    if (bill.isCustomSplit && bill.peopleList != null) {
      return pw.Wrap(
        spacing: 6,
        runSpacing: 4,
        children: bill.peopleList!.map((p) {
          final amount = totalBill * (p.percentage / 100);
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: pw.BoxDecoration(
              color: PdfColor(_dividerGrey.red, _dividerGrey.green, _dividerGrey.blue, 0.4),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: "${_sanitize(p.name)}: ", style: pw.TextStyle(font: font, fontSize: 7, color: _googleGrey)),
                  pw.TextSpan(text: "${bill.currency} ${amount.toStringAsFixed(2)}", style: pw.TextStyle(font: fontBold, fontSize: 7, color: _darkText)),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } else {
      final share = totalBill / bill.people;
      return pw.Text(
        "Each of ${bill.people} members contributed ${bill.currency} ${share.toStringAsFixed(2)}",
        style: pw.TextStyle(font: font, fontSize: 7.5, color: _googleGrey, fontStyle: pw.FontStyle.italic),
      );
    }
  }

  static pw.Widget _buildTableHeaderCell(String text, pw.Font fontBold, {pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Container(
        alignment: align,
        child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: _darkText, letterSpacing: 1.2)),
      ),
    );
  }

  static List<pw.Widget> _buildSettlementSummary(TripAggregationResult result, pw.Font font, pw.Font fontBold) {
    return result.perPersonTotals.entries.expand((entry) {
      final currency = entry.key;
      final people = entry.value;
      return [
        if (result.hasMixedCurrencies)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10, top: 12),
            child: pw.Text('SUMMARY ARCHIVE: $currency', style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: _googleBlue, letterSpacing: 1)),
          ),
        pw.Table(
          border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _googleBlue),
              children: [
                _buildSettlementHeaderCell('PARTICIPANT NAME', fontBold),
                _buildSettlementHeaderCell('TOTAL NET CONTRIBUTION', fontBold, align: pw.Alignment.centerRight),
                _buildSettlementHeaderCell('SHARE %', fontBold, align: pw.Alignment.centerRight),
              ],
            ),
            ...people.map((p) => pw.TableRow(
              children: [
                _buildSettlementCell(_sanitize(p.displayName), font),
                _buildSettlementCell("${p.totalAmount.toStringAsFixed(2)} $currency", fontBold, align: pw.Alignment.centerRight, color: _googleBlue),
                _buildSettlementCell("${p.sharePercentage.toStringAsFixed(1)}%", font, align: pw.Alignment.centerRight, color: _googleGrey),
              ],
            )),
          ],
        ),
        pw.SizedBox(height: 24),
      ];
    }).toList();
  }

  static pw.Widget _buildSettlementHeaderCell(String text, pw.Font fontBold, {pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: pw.Container(
        alignment: align,
        child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white, letterSpacing: 0.5)),
      ),
    );
  }

  static pw.Widget _buildSettlementCell(String text, pw.Font font, {pw.Alignment align = pw.Alignment.centerLeft, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: pw.Container(
        alignment: align,
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9.5, color: color ?? _darkText)),
      ),
    );
  }

  static pw.Widget _buildSecurityBadge(pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _borderGrey, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DIGITALLY SECURED FINANCIAL REPORT', style: pw.TextStyle(font: font, fontSize: 6.5, color: _googleGrey, letterSpacing: 0.5)),
              pw.SizedBox(height: 2),
              pw.Text('AUTHENTICITY VERIFIED VIA SPLITNOVA CORE ENGINE', style: pw.TextStyle(font: font, fontSize: 6.5, color: _googleGrey, letterSpacing: 0.5)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFinancialDisclaimer(pw.Font fontItalic) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _bgLight,
        border: pw.Border(left: pw.BorderSide(color: _googleBlue, width: 4)),
      ),
      child: pw.Text(
        'AUDIT NOTICE: This document provides a comprehensive reconciliation of shared financial obligations. Grand totals include base expenses and gratuities (tips). Individual share calculations are based on user-defined allocation strategies (Equal or Pro-Rata). Please verify all line items before initiating final settlement.',
        style: pw.TextStyle(font: fontItalic, fontSize: 8.5, color: _googleGrey, height: 1.4),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: _dividerGrey, thickness: 1),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('Generated via SplitNova', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 8)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                      child: pw.Container(width: 1, height: 8, color: _borderGrey),
                    ),
                    pw.Text('Professional Expense Management', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 8)),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Text('Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 7)),
              ],
            ),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: font, color: _googleGrey, fontSize: 8.5)),
          ],
        ),
      ],
    );
  }

  static String _sanitize(String? text) {
    if (text == null) return '';
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
