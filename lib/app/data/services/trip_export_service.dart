import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../models/trip_model.dart';
import 'trip_aggregation_service.dart';

class TripExportService {
  static Future<void> exportToPdf(TripModel trip, TripAggregationResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(trip.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        (result.earliestDate != null && result.latestDate != null)
                            ? "${DateFormat.yMMMd().format(result.earliestDate!)} - ${DateFormat.yMMMd().format(result.latestDate!)}"
                            : "",
                        style: pw.TextStyle(color: PdfColors.grey),
                      ),
                    ],
                  ),
                  pw.Text(trip.emoji ?? '✈️', style: pw.TextStyle(fontSize: 40)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('grand_total_summary'.tr, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            ...result.grandTotals.entries.map((entry) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(entry.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(entry.value.toStringAsFixed(2), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 20),
            pw.Text('per_person_summary'.tr, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            ...result.perPersonTotals.entries.map((entry) {
              final currency = entry.key;
              final list = entry.value;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (result.hasMixedCurrencies)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
                      child: pw.Text(currency, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
                    ),
                  pw.TableHelper.fromTextArray(
                    headers: ['name_text'.tr, 'total'.tr, 'share_percent'.tr],
                    data: list.map((p) => [
                      p.displayName,
                      p.totalAmount.toStringAsFixed(2),
                      "${p.sharePercentage.toStringAsFixed(1)}%"
                    ]).toList(),
                  ),
                ],
              );
            }),
            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Text('generated_by'.trParams({'app': 'SplitNova'}), style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
            ),
            pw.Center(
              child: pw.Text('tagline'.tr, style: pw.TextStyle(color: PdfColors.grey500, fontSize: 8)),
            ),
          ];
        },
      ),
    );

    final filename = "${trip.name.replaceAll(RegExp(r'[^\w\s]+'), '').trim()}_Summary.pdf";
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }

  static String getTripShareMessage(TripModel trip, TripAggregationResult result) {
    String msg = "${'share_header'.tr} ${'trip_summary'.tr}: ${trip.name}\n";
    if (result.earliestDate != null && result.latestDate != null) {
      msg += "📅 ${DateFormat.yMMMd().format(result.earliestDate!)} - ${DateFormat.yMMMd().format(result.latestDate!)}\n";
    }
    msg += "━━━━━━━━━━━━━━━━\n";
    
    msg += "💰 ${'grand_total_summary'.tr}:\n";
    result.grandTotals.forEach((currency, amount) {
      msg += "- $currency: ${amount.toStringAsFixed(2)}\n";
    });
    
    msg += "━━━━━━━━━━━━━━━━\n";
    msg += "👥 ${'per_person_summary'.tr}:\n";
    
    result.perPersonTotals.forEach((currency, people) {
      if (result.hasMixedCurrencies) msg += "[$currency]\n";
      for (var p in people) {
        msg += "👤 ${p.displayName}: ${p.totalAmount.toStringAsFixed(2)} (${p.sharePercentage.toStringAsFixed(1)}%)\n";
      }
    });

    msg += "━━━━━━━━━━━━━━━━\n";
    msg += "${'share_footer'.tr}\n";
    msg += "${'tagline'.tr}";
    
    return msg;
  }
}
