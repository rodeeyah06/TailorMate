import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tailormate/models/client.dart';
import 'package:tailormate/models/measurement.dart';
import 'package:tailormate/models/order.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/screens/client/edit_client_screen.dart';
import 'package:tailormate/screens/order/add_order_screen.dart';
import 'package:tailormate/screens/order/order_detail_screen.dart';
import 'package:tailormate/services/pdf_service.dart';

class ClientProfileScreen extends StatefulWidget {
  final Client client;
  const ClientProfileScreen({super.key, required this.client});

  @override
  State<ClientProfileScreen> createState() =>
      _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  Client? _client;
  Measurement? _latestMeasurement;
  List<Measurement> _history = [];
  List<TailorOrder> _orders = [];
  bool _loading = true;
  bool _showHistory = false;

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _pinkBlush = Color(0xFFFBEAF0);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<ClientProvider>();
    final freshClient =
    await provider.getClientById(widget.client.id!);
    final latest =
    await provider.getLatestMeasurement(widget.client.id!);
    final history =
    await provider.getMeasurementHistory(widget.client.id!);
    final orders =
    await provider.getOrdersForClient(widget.client.id!);
    setState(() {
      _client = freshClient ?? widget.client;
      _latestMeasurement = latest;
      _history = history;
      _orders = orders;
      _loading = false;
    });
  }

  Client get client => _client ?? widget.client;

  void _shareToWhatsApp() {
    final m = _latestMeasurement;
    final c = client;
    String text = '👗 *TailorMate — Client Measurements*\n\n';
    text += '*Name:* ${c.name}\n';
    if (c.phone != null) text += '*Phone:* ${c.phone}\n';
    text += '\n📏 *Measurements*\n';
    if (m != null) {
      if (m.bust != null) text += '• Bust: ${m.bust}"\n';
      if (m.underbust != null)
        text += '• Underbust: ${m.underbust}"\n';
      if (m.nipple_to_nipple!= null)
        text += '• Nipple to Nipple: ${m.nipple_to_nipple}"\n';
      if (m.waist != null) text += '• Waist: ${m.waist}"\n';
      if (m.hips != null) text += '• Hips: ${m.hips}"\n';
      if (m.shoulder != null)
        text += '• Shoulder: ${m.shoulder}"\n';
      if (m.sleeve != null) text += '• Sleeve: ${m.sleeve}"\n';
      if (m.sleeveLength != null)
        text += '• Sleeve Length: ${m.sleeveLength}"\n';
      if (m.fullLength != null)
        text += '• Full Length: ${m.fullLength}"\n';
      if (m.halfLength != null)
        text += '• Half Length: ${m.halfLength}"\n';
      if (m.thigh != null) text += '• Thigh: ${m.thigh}"\n';
      if (m.neck != null) text += '• Neck: ${m.neck}"\n';
      if (m.back != null) text += '• Back: ${m.back}"\n';
    }
    if (c.notes != null && c.notes!.isNotEmpty)
      text += '\n📝 *Notes:* ${c.notes}';
    Share.share(text);
  }

  void _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete client?',
            style: GoogleFonts.playfairDisplay(fontSize: 18)),
        content: Text(
          'This will permanently delete ${client.name} and all their data.',
          style: GoogleFonts.dmSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.dmSans(color: _pink)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context
          .read<ClientProvider>()
          .deleteClient(client.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = client.name.isNotEmpty
        ? client.name
        .trim()
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        : '?';

    return Scaffold(
      backgroundColor: _cream,
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: _pink))
          : Column(
        children: [
          // ── HEADER ──
          Container(
            color: _black,
            padding: const EdgeInsets.only(
                top: 52, left: 20, right: 20, bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1F28),
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                              color:
                              const Color(0xFF4A2E40)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFED93B1),
                          size: 14,
                        ),
                      ),
                    ),
                    Text('Client Record',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            color: Colors.white)),
                    GestureDetector(
                      onTap: _deleteClient,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1F28),
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                              color:
                              const Color(0xFF4A2E40)),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFED93B1),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _pink,
                        borderRadius:
                        BorderRadius.circular(14),
                        image: client.photoPath != null
                            ? DecorationImage(
                          image: FileImage(
                              File(client.photoPath!)),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: client.photoPath == null
                          ? Center(
                        child: Text(
                          initials.toUpperCase(),
                          style: GoogleFonts
                              .playfairDisplay(
                              fontSize: 18,
                              color: Colors.white),
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(client.name,
                              style:
                              GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  color: Colors.white)),
                          if (client.phone != null)
                            Text(client.phone!,
                                style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: const Color(
                                        0xFF9A7F8A))),
                          Text(
                            'Since ${client.createdAt.substring(0, 10)}',
                            style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color:
                                const Color(0xFF6A4A55),
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── ACTION BUTTONS ──
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        'Share',
                        Icons.share_outlined,
                        filled: true,
                        onTap: _shareToWhatsApp,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _actionBtn(
                        'Edit',
                        Icons.edit_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditClientScreen(
                              client: client,
                              latestMeasurement:
                              _latestMeasurement,
                            ),
                          ),
                        ).then((_) => _loadData()),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _actionBtn(
                        'Order',
                        Icons.receipt_long_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddOrderScreen(
                              clientId: client.id!,
                              clientName: client.name,
                            ),
                          ),
                        ).then((_) => _loadData()),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _actionBtn(
                        'PDF',
                        Icons.picture_as_pdf_outlined,
                        onTap: () =>
                            PdfService.printClientMeasurements(
                              client: client,
                              measurement: _latestMeasurement,
                              orders: _orders,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── BODY ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // measurements header
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Measurements',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 16, color: _black)),
                      Text(
                        'Updated ${client.updatedAt.substring(0, 10)}',
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: const Color(0xFFB090A0),
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── BOOK PAGE ──
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF6EE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _pinkSoft),
                    ),
                    child: Row(
                      children: [
                        // spine
                        Container(
                          width: 8,
                          height: 320,
                          decoration: const BoxDecoration(
                            color: _pink,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        // left measurements
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8),
                            child: Column(
                              children: [
                                _measRow('Bust',
                                    _latestMeasurement?.bust),
                                _measRow('Underbust',
                                    _latestMeasurement
                                        ?.underbust),
                                _measRow('Nip-Nip',
                                    _latestMeasurement
                                        ?.nipple_to_nipple),
                                _measRow('Waist',
                                    _latestMeasurement?.waist),
                                _measRow('Hips',
                                    _latestMeasurement?.hips),
                                _measRow('Back',
                                    _latestMeasurement?.back),
                                _measRow('Neck',
                                    _latestMeasurement?.neck),
                              ],
                            ),
                          ),
                        ),
                        // silhouette
                        SizedBox(
                          width: 80,
                          child: CustomPaint(
                            size: const Size(80, 300),
                            painter: _SilhouettePainter(),
                          ),
                        ),
                        // right measurements
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8),
                            child: Column(
                              children: [
                                _measRow('Shoulder',
                                    _latestMeasurement
                                        ?.shoulder),
                                _measRow('Sleeve',
                                    _latestMeasurement
                                        ?.sleeve),
                                _measRow('Slv Len',
                                    _latestMeasurement
                                        ?.sleeveLength),
                                _measRow('Full Len',
                                    _latestMeasurement
                                        ?.fullLength),
                                _measRow('Half Len',
                                    _latestMeasurement
                                        ?.halfLength),
                                _measRow('Thigh',
                                    _latestMeasurement
                                        ?.thigh),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── NOTES ──
                  if (client.notes != null &&
                      client.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(12),
                        border: Border(
                          left: const BorderSide(
                              color: _pink, width: 3),
                          top: BorderSide(color: _pinkSoft),
                          right:
                          BorderSide(color: _pinkSoft),
                          bottom:
                          BorderSide(color: _pinkSoft),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('Notes',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: _pink,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: .06)),
                          const SizedBox(height: 4),
                          Text(client.notes!,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color:
                                  const Color(0xFF5A3040),
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],

                  // ── HISTORY ──
                  if (_history.length > 1) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => setState(() =>
                      _showHistory = !_showHistory),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('History',
                              style:
                              GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  color: _black)),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3),
                            decoration: BoxDecoration(
                              color: _pinkBlush,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_history.length} records  ${_showHistory ? '▲' : '▼'}',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: _pink,
                                  fontWeight:
                                  FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showHistory) ...[
                      const SizedBox(height: 8),
                      ..._history.map(
                            (m) => Container(
                          margin: const EdgeInsets.only(
                              bottom: 6),
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                                color: _pinkSoft),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Text(
                                m.recordedAt
                                    .substring(0, 10),
                                style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: const Color(
                                        0xFF9A7F8A),
                                    fontStyle:
                                    FontStyle.italic),
                              ),
                              Text(
                                'Bust ${m.bust ?? '-'}" · Waist ${m.waist ?? '-'}"',
                                style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: const Color(
                                        0xFFB090A0)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],

                  // ── ORDERS ──
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Orders',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 16, color: _black)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddOrderScreen(
                              clientId: client.id!,
                              clientName: client.name,
                            ),
                          ),
                        ).then((_) => _loadData()),
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3),
                          decoration: BoxDecoration(
                            color: _pinkBlush,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Text('+ Add',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: _pink,
                                  fontWeight:
                                  FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _orders.isEmpty
                      ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                          color: _pinkSoft),
                    ),
                    child: Text(
                      'No orders yet — tap + Add to create one',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color:
                          const Color(0xFFB090A0),
                          fontStyle: FontStyle.italic),
                    ),
                  )
                      : Column(
                    children: _orders
                        .map(
                          (order) => GestureDetector(
                        onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailScreen(
                                      order: order,
                                      clientName:
                                      client.name,
                                    ),
                              ),
                            ).then(
                                    (_) => _loadData()),
                        child: Container(
                          margin:
                          const EdgeInsets.only(
                              bottom: 8),
                          padding:
                          const EdgeInsets.all(
                              12),
                          decoration: BoxDecoration(
                            color: _black,
                            borderRadius:
                            BorderRadius.circular(
                                12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.outfitName,
                                      style: GoogleFonts
                                          .dmSans(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight
                                            .w500,
                                        color: Colors
                                            .white,
                                      ),
                                    ),
                                  ),
                                  if (order.price !=
                                      null)
                                    Text(
                                      '₦${order.price!.toStringAsFixed(0)}',
                                      style: GoogleFonts
                                          .dmSans(
                                        fontSize: 14,
                                        color: const Color(
                                            0xFFF4C0D1),
                                        fontWeight:
                                        FontWeight
                                            .w500,
                                      ),
                                    ),
                                ],
                              ),
                              if (order.fabric !=
                                  null) ...[
                                const SizedBox(
                                    height: 4),
                                Text(
                                  order.fabric!,
                                  style: GoogleFonts
                                      .dmSans(
                                    fontSize: 11,
                                    color: const Color(
                                        0xFF9A7F8A),
                                  ),
                                ),
                              ],
                              if (order.dueDate !=
                                  null) ...[
                                const SizedBox(
                                    height: 4),
                                Text(
                                  'Due ${order.dueDate!.substring(0, 10)}',
                                  style: GoogleFonts
                                      .dmSans(
                                    fontSize: 10,
                                    color: const Color(
                                        0xFF7A5060),
                                    fontStyle:
                                    FontStyle
                                        .italic,
                                  ),
                                ),
                              ],
                              const SizedBox(
                                  height: 8),
                              Container(
                                padding: const EdgeInsets
                                    .symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration:
                                BoxDecoration(
                                  color: _pinkBlush,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      6),
                                ),
                                child: Text(
                                  order.status,
                                  style: GoogleFonts
                                      .dmSans(
                                    fontSize: 9,
                                    color: _pink,
                                    fontWeight:
                                    FontWeight
                                        .w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _measRow(String label, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 8,
                  color: const Color(0xFFB090A0),
                  letterSpacing: .04)),
          Text(
            value != null ? '${value}"' : '—',
            style: GoogleFonts.dmSans(
                fontSize: 15,
                color:
                value != null ? _pink : const Color(0xFFD0B0C0),
                fontWeight: FontWeight.w500),
          ),
          Container(height: 1, color: const Color(0xFFEDE4DC)),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon,
      {bool filled = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: filled ? _pink : const Color(0xFF2C1F28),
          borderRadius: BorderRadius.circular(10),
          border: filled
              ? null
              : Border.all(color: const Color(0xFF4A2E40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                filled ? Colors.white : const Color(0xFFF4C0D1),
                size: 12),
            const SizedBox(width: 3),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: filled
                        ? Colors.white
                        : const Color(0xFFF4C0D1))),
          ],
        ),
      ),
    );
  }
}

// ── SILHOUETTE PAINTER ──
class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4537E)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = const Color(0xFFD4537E).withValues(alpha: .4)
      ..strokeWidth = .8
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;

    canvas.drawCircle(Offset(cx, 18), 10, paint);
    canvas.drawLine(Offset(cx, 28), Offset(cx, 35), paint);

    final shoulderPath = Path()
      ..moveTo(cx - 18, 42)
      ..quadraticBezierTo(cx - 20, 37, cx - 14, 35)
      ..lineTo(cx, 35)
      ..lineTo(cx + 14, 35)
      ..quadraticBezierTo(cx + 20, 37, cx + 18, 42);
    canvas.drawPath(shoulderPath, paint);

    final torsoLeft = Path()
      ..moveTo(cx - 18, 42)
      ..cubicTo(cx - 22, 55, cx - 20, 70, cx - 16, 82)
      ..cubicTo(cx - 14, 92, cx - 18, 105, cx - 16, 118)
      ..lineTo(cx - 14, 140);
    canvas.drawPath(torsoLeft, paint);

    final torsoRight = Path()
      ..moveTo(cx + 18, 42)
      ..cubicTo(cx + 22, 55, cx + 20, 70, cx + 16, 82)
      ..cubicTo(cx + 14, 92, cx + 18, 105, cx + 16, 118)
      ..lineTo(cx + 14, 140);
    canvas.drawPath(torsoRight, paint);

    final armLeft = Path()
      ..moveTo(cx - 18, 44)
      ..cubicTo(cx - 26, 60, cx - 28, 80, cx - 24, 98);
    canvas.drawPath(armLeft, paint);

    final armRight = Path()
      ..moveTo(cx + 18, 44)
      ..cubicTo(cx + 26, 60, cx + 28, 80, cx + 24, 98);
    canvas.drawPath(armRight, paint);

    canvas.drawCircle(Offset(cx - 22, 102), 4, paint);
    canvas.drawCircle(Offset(cx + 22, 102), 4, paint);
    canvas.drawLine(
        Offset(cx - 14, 140), Offset(cx - 12, 185), paint);
    canvas.drawLine(
        Offset(cx + 14, 140), Offset(cx + 12, 185), paint);
    canvas.drawLine(
        Offset(cx - 14, 185), Offset(cx - 20, 185), paint);
    canvas.drawLine(
        Offset(cx + 14, 185), Offset(cx + 20, 185), paint);

    _drawDashedLine(canvas, dashPaint, Offset(cx - 16, 57),
        Offset(cx + 16, 57));
    _drawDashedLine(canvas, dashPaint, Offset(cx - 14, 80),
        Offset(cx + 14, 80));
    _drawDashedLine(canvas, dashPaint, Offset(cx - 15, 102),
        Offset(cx + 15, 102));

    final dotPaint = Paint()
      ..color = const Color(0xFFD4537E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, 57), 2.5, dotPaint);
    canvas.drawCircle(Offset(cx, 80), 2.5, dotPaint);
    canvas.drawCircle(Offset(cx, 102), 2.5, dotPaint);
  }

  void _drawDashedLine(
      Canvas canvas, Paint paint, Offset start, Offset end) {
    const dashWidth = 3.0;
    const dashSpace = 2.5;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = (end - start).distance;
    final steps = dist / (dashWidth + dashSpace);
    for (int i = 0; i < steps; i++) {
      final t1 = i / steps;
      final t2 =
          (i + dashWidth / (dashWidth + dashSpace)) / steps;
      canvas.drawLine(
        Offset(start.dx + dx * t1, start.dy + dy * t1),
        Offset(start.dx + dx * t2, start.dy + dy * t2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}