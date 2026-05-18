import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tailormate/models/client.dart';
import 'package:tailormate/models/measurement.dart';
import 'package:tailormate/models/order.dart';

class PdfService {
  // ── CLIENT MEASUREMENT RECORD ──
  static Future<void> printClientMeasurements({
    required Client client,
    required Measurement? measurement,
    required List<TailorOrder> orders,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFD4537E),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TailorMate',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'Client Measurement Record',
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      DateTime.now()
                          .toIso8601String()
                          .substring(0, 10),
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // ── CLIENT INFO ──
              pw.Text(
                client.name,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (client.phone != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(client.phone!,
                    style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700)),
              ],

              pw.SizedBox(height: 16),
              pw.Divider(
                  color: const PdfColor.fromInt(0xFFF4C0D1)),
              pw.SizedBox(height: 16),

              // ── MEASUREMENTS ──
              pw.Text(
                'Measurements',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFFD4537E),
                ),
              ),
              pw.SizedBox(height: 10),

              if (measurement != null) ...[
                _measRow2Col('Bust', measurement.bust,
                    'Underbust', measurement.underbust),
                _measRow2Col('Nipple-Nipple',
                    measurement.nipple_to_nipple,
                    'Waist', measurement.waist),
                _measRow2Col('Hips', measurement.hips,
                    'Shoulder', measurement.shoulder),
                _measRow2Col('Sleeve', measurement.sleeve,
                    'Sleeve Length', measurement.sleeveLength),
                _measRow2Col('Full Length', measurement.fullLength,
                    'Half Length', measurement.halfLength),
                _measRow2Col('Thigh', measurement.thigh,
                    'Neck', measurement.neck),
                _measRow2Col('Back', measurement.back, '', null),
              ] else
                pw.Text('No measurements recorded',
                    style: const pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey)),

              // ── NOTES ──
              if (client.notes != null &&
                  client.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Divider(
                    color: const PdfColor.fromInt(0xFFF4C0D1)),
                pw.SizedBox(height: 10),
                pw.Text('Notes',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color:
                      const PdfColor.fromInt(0xFFD4537E),
                    )),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color:
                        const PdfColor.fromInt(0xFFD4537E),
                        width: 3,
                      ),
                    ),
                  ),
                  child: pw.Text(client.notes!,
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ],

              // ── ORDERS ──
              if (orders.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Divider(
                    color: const PdfColor.fromInt(0xFFF4C0D1)),
                pw.SizedBox(height: 10),
                pw.Text('Orders',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color:
                      const PdfColor.fromInt(0xFFD4537E),
                    )),
                pw.SizedBox(height: 8),
                ...orders.map(
                      (order) => pw.Container(
                    margin:
                    const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: const PdfColor.fromInt(
                              0xFFF4C0D1)),
                      borderRadius:
                      pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(order.outfitName,
                                style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    pw.FontWeight.bold)),
                            if (order.fabric != null)
                              pw.Text(order.fabric!,
                                  style: const pw.TextStyle(
                                      fontSize: 10,
                                      color:
                                      PdfColors.grey700)),
                            if (order.dueDate != null)
                              pw.Text(
                                  'Due: ${order.dueDate!.substring(0, 10)}',
                                  style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment:
                          pw.CrossAxisAlignment.end,
                          children: [
                            if (order.price != null)
                              pw.Text(
                                '₦${order.price!.toStringAsFixed(0)}',
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  pw.FontWeight.bold,
                                  color: const PdfColor
                                      .fromInt(0xFFD4537E),
                                ),
                              ),
                            pw.Text(order.status,
                                style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              pw.Spacer(),

              // ── FOOTER ──
              pw.Divider(
                  color: const PdfColor.fromInt(0xFFF4C0D1)),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Generated by TailorMate 🎀',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${client.name}_measurements.pdf',
    );
  }

  // ── ORDER RECEIPT ──
  static Future<void> printOrderReceipt({
    required TailorOrder order,
    required String clientName,
    required String? clientPhone,
    required double total,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFD4537E),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TailorMate',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'Order Receipt',
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      DateTime.now()
                          .toIso8601String()
                          .substring(0, 10),
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // ── CLIENT INFO ──
              pw.Text(
                'Bill To',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: const PdfColor.fromInt(0xFFD4537E),
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(clientName,
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold)),
              if (clientPhone != null) ...[
                pw.SizedBox(height: 3),
                pw.Text(clientPhone,
                    style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700)),
              ],

              pw.SizedBox(height: 16),
              pw.Divider(
                  color: const PdfColor.fromInt(0xFFF4C0D1)),
              pw.SizedBox(height: 16),

              // ── ORDER DETAILS ──
              pw.Text(
                'Order Details',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: const PdfColor.fromInt(0xFFD4537E),
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              _receiptRow('Outfit', order.outfitName),
              if (order.fabric != null)
                _receiptRow('Fabric', order.fabric!),
              if (order.dueDate != null)
                _receiptRow('Due Date',
                    order.dueDate!.substring(0, 10)),
              _receiptRow(
                  'Status', order.status.toUpperCase()),

              pw.SizedBox(height: 16),
              pw.Divider(
                  color: const PdfColor.fromInt(0xFFF4C0D1)),
              pw.SizedBox(height: 12),

              // ── TOTAL ──
              pw.Row(
                mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Amount',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '₦${total.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(
                          0xFFD4537E),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ── FOOTER ──
              pw.Divider(
                  color: const PdfColor.fromInt(0xFFF4C0D1)),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Thank you for your patronage! 🎀',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Generated by TailorMate',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${clientName}_receipt.pdf',
    );
  }

  // ── HELPERS ──
  static pw.Widget _measRow2Col(
      String label1,
      double? val1,
      String label2,
      double? val2,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color:
                    const PdfColor.fromInt(0xFFF4C0D1)),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(label1,
                      style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey)),
                  pw.Text(
                    val1 != null ? '${val1}"' : '—',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: val1 != null
                          ? const PdfColor.fromInt(
                          0xFFD4537E)
                          : PdfColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: label2.isNotEmpty
                ? pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: const PdfColor.fromInt(
                        0xFFF4C0D1)),
                borderRadius:
                pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(label2,
                      style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey)),
                  pw.Text(
                    val2 != null ? '${val2}"' : '—',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: val2 != null
                          ? const PdfColor.fromInt(
                          0xFFD4537E)
                          : PdfColors.grey,
                    ),
                  ),
                ],
              ),
            )
                : pw.SizedBox(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _receiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}