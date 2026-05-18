import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tailormate/models/client.dart';
import 'package:tailormate/models/measurement.dart';
import 'package:tailormate/models/order.dart';

class PdfService {
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
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TailorMate',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'Client Measurement Record',
                          style: const pw.TextStyle(
                            fontSize: 12,
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
                        fontSize: 11,
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
                        fontSize: 12, color: PdfColors.grey700)),
              ],

              pw.SizedBox(height: 16),
              pw.Divider(color: const PdfColor.fromInt(0xFFF4C0D1)),
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

              if (measurement != null)
                pw.GridView(
                  crossAxisCount: 3,
                  childAspectRatio: 3,
                  children: [
                    if (measurement.bust != null)
                      _measCell('Bust', '${measurement.bust}"'),
                    if (measurement.underbust != null)
                      _measCell(
                          'Underbust', '${measurement.underbust}"'),
                    if (measurement.nipple_to_nipple != null)
                      _measCell('Nip-Nip',
                          '${measurement.nipple_to_nipple}"'),
                    if (measurement.waist != null)
                      _measCell('Waist', '${measurement.waist}"'),
                    if (measurement.hips != null)
                      _measCell('Hips', '${measurement.hips}"'),
                    if (measurement.shoulder != null)
                      _measCell(
                          'Shoulder', '${measurement.shoulder}"'),
                    if (measurement.sleeve != null)
                      _measCell('Sleeve', '${measurement.sleeve}"'),
                    if (measurement.sleeveLength != null)
                      _measCell('Sleeve Length',
                          '${measurement.sleeveLength}"'),
                    if (measurement.fullLength != null)
                      _measCell('Full Length',
                          '${measurement.fullLength}"'),
                    if (measurement.halfLength != null)
                      _measCell('Half Length',
                          '${measurement.halfLength}"'),
                    if (measurement.thigh != null)
                      _measCell('Thigh', '${measurement.thigh}"'),
                    if (measurement.neck != null)
                      _measCell('Neck', '${measurement.neck}"'),
                    if (measurement.back != null)
                      _measCell('Back', '${measurement.back}"'),
                  ],
                )
              else
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
                      color: const PdfColor.fromInt(0xFFD4537E),
                    )),
                pw.SizedBox(height: 6),
                pw.Text(client.notes!,
                    style: const pw.TextStyle(fontSize: 12)),
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
                      color: const PdfColor.fromInt(0xFFD4537E),
                    )),
                pw.SizedBox(height: 8),
                ...orders.map(
                      (order) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: const PdfColor.fromInt(0xFFF4C0D1)),
                      borderRadius: pw.BorderRadius.circular(6),
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
                                    fontWeight: pw.FontWeight.bold)),
                            if (order.fabric != null)
                              pw.Text(order.fabric!,
                                  style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey700)),
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
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor.fromInt(
                                      0xFFD4537E),
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

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _measCell(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      margin: const pw.EdgeInsets.all(3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
            color: const PdfColor.fromInt(0xFFF4C0D1)),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 8, color: PdfColors.grey)),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFFD4537E),
              )),
        ],
      ),
    );
  }
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
              _receiptRow('Status', order.status.toUpperCase()),

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
                      color: const PdfColor.fromInt(0xFFD4537E),
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

  static pw.Widget _receiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 11, color: PdfColors.grey700)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}