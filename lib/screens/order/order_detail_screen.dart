import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/models/expense.dart';
import 'package:tailormate/models/order.dart';
import 'package:tailormate/models/shopping_item.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/services/ai_service.dart';
import 'package:tailormate/services/pdf_service.dart';


class OrderDetailScreen extends StatefulWidget {
  final TailorOrder order;
  final String clientName;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.clientName,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late TailorOrder _order;
  List<Expense> _expenses = [];
  List<ShoppingItem> _shoppingItems = [];
  bool _loading = true;
  bool _analyzingDress = false;
  double _total = 0;
  String? _dressImagePath;
  String? _dressAnalysis;
  String? _complexity;
  String? _tailorNotes;
  final _shoppingNoteController = TextEditingController();

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _pinkBlush = Color(0xFFFBEAF0);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadData();
  }

  @override
  void dispose() {
    _shoppingNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<ClientProvider>();
    final expenses = await provider.getExpensesForOrder(_order.id!);
    final items = await provider.getShoppingItemsForOrder(_order.id!);
    final total = await provider.getTotalForOrder(_order.id!);
    setState(() {
      _expenses = expenses;
      _shoppingItems = items;
      _total = total;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String status) async {
    final provider = context.read<ClientProvider>();
    final updated = _order.copyWith(status: status);
    await provider.updateOrder(updated);
    setState(() => _order = updated);
  }

  Future<void> _deleteOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete order?',
            style: GoogleFonts.playfairDisplay(fontSize: 18)),
        content: Text(
          'This will permanently delete this order.',
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
      await context.read<ClientProvider>().deleteOrder(_order.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  // ── PICK DRESS IMAGE ──
  Future<void> _pickDressImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select dress image',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, color: _black)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _pinkBlush,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: _pink, size: 18),
              ),
              title: Text('Take a photo',
                  style: GoogleFonts.dmSans(fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _pinkBlush,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: _pink, size: 18),
              ),
              title: Text('Choose from gallery',
                  style: GoogleFonts.dmSans(fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _dressImagePath = picked.path;
        _dressAnalysis = null;
      });
      await _analyzeDress();
    }
  }

  // ── ANALYZE DRESS ──
  Future<void> _analyzeDress() async {
    if (_dressImagePath == null) return;
    setState(() => _analyzingDress = true);

    // store provider BEFORE any await
    final provider = context.read<ClientProvider>();

    try {
      final result = await AiService.analyzeDress(
        imagePath: _dressImagePath!,
        outfitName: _order.outfitName,
        fabric: _order.fabric,
      );

      // clear old expenses
      for (final e in _expenses) {
        await provider.deleteExpense(e.id!);
      }

      // save new AI expenses
      final expenses = result['expenses'] as List<dynamic>? ?? [];
      for (final e in expenses) {
        final expense = Expense(
          orderId: _order.id!,
          description: '${e['description']} (${e['quantity'] ?? ''})',
          amount: (e['amount'] as num).toDouble(),
        );
        await provider.addExpense(expense);
      }

      // save shopping list
      final shoppingList =
          result['shopping_list'] as List<dynamic>? ?? [];
      for (final item in shoppingList) {
        final shopItem = ShoppingItem(
          orderId: _order.id!,
          item: item.toString(),
        );
        await provider.addShoppingItem(shopItem);
      }

      setState(() {
        _dressAnalysis = result['dress_analysis'] as String?;
        _complexity = result['complexity'] as String?;
        _tailorNotes = result['tailor_notes'] as String?;
      });

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _analyzingDress = false);
    }
  }

  // ── ADD MANUAL EXPENSE ──
  void _addManualExpense() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Expense',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, color: _black)),
            const SizedBox(height: 16),
            _sheetField('Description', descCtrl,
                hint: 'e.g. Extra lace, buttons'),
            const SizedBox(height: 10),
            _sheetField('Amount (₦)', amountCtrl,
                keyboard: TextInputType.number,
                hint: 'e.g. 5000'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  if (descCtrl.text.isEmpty ||
                      amountCtrl.text.isEmpty) return;
                  final provider = context.read<ClientProvider>();
                  await provider.addExpense(Expense(
                    orderId: _order.id!,
                    description: descCtrl.text.trim(),
                    amount:
                    double.tryParse(amountCtrl.text.trim()) ??
                        0,
                  ));
                  if (mounted) Navigator.pop(ctx);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text('Add',
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ADD SHOPPING NOTE ──
  void _addShoppingNote() {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add to Market List',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, color: _black)),
            const SizedBox(height: 8),
            Text('Write what you need to buy',
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFFB090A0))),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              maxLines: 3,
              autofocus: true,
              style:
              GoogleFonts.dmSans(fontSize: 14, color: _black),
              decoration: InputDecoration(
                hintText:
                'e.g. 4 yards ankara from Balogun\n1 invisible zip\nGold rhinestones x2 packs',
                hintStyle: GoogleFonts.dmSans(
                    color: const Color(0xFFD0B0C0),
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
                filled: true,
                fillColor: _cream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _pinkSoft),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _pinkSoft),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: _pink, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  final provider = context.read<ClientProvider>();
                  // each line becomes a separate item
                  final lines = ctrl.text
                      .split('\n')
                      .where((l) => l.trim().isNotEmpty)
                      .toList();
                  for (final line in lines) {
                    await provider.addShoppingItem(ShoppingItem(
                      orderId: _order.id!,
                      item: line.trim(),
                    ));
                  }
                  if (mounted) Navigator.pop(ctx);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text('Add to list',
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No due date';
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFED93B1);
      case 'in_progress': return const Color(0xFFEFD27B);
      case 'done': return const Color(0xFF7BC47F);
      default: return const Color(0xFFED93B1);
    }
  }

  Color _complexityColor(String? c) {
    switch (c) {
      case 'simple': return const Color(0xFF7BC47F);
      case 'medium': return const Color(0xFFEFD27B);
      case 'complex': return const Color(0xFFED93B1);
      case 'highly complex': return Colors.red.shade300;
      default: return const Color(0xFFED93B1);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                top: 44, left: 16, right: 16, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1F28),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF4A2E40)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFFED93B1), size: 12),
                      ),
                    ),
                    // status buttons in header
                    Row(
                      children: [
                        _statusBtn('pending', 'Pending'),
                        const SizedBox(width: 6),
                        _statusBtn('in_progress', 'In Progress'),
                        const SizedBox(width: 6),
                        _statusBtn('done', 'Done'),
                      ],
                    ),
                    GestureDetector(
                      onTap: _deleteOrder,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1F28),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF4A2E40)),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFED93B1), size: 14),
                      ),
                    ),
                  ],
                ),
          GestureDetector(
          onTap: () => PdfService.printOrderReceipt(
      order: _order,
      clientName: widget.clientName,
      clientPhone: null,
      total: _total,
    ),
    child: Container(
    width: 30, height: 30,
    decoration: BoxDecoration(
    color: const Color(0xFF2C1F28),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFF4A2E40)),
    ),
    child: const Icon(
    Icons.receipt_outlined,
    color: Color(0xFFED93B1),
    size: 14,
    ),
    ),
    ),

                const SizedBox(height: 8),
                Text(
                  _order.outfitName,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(widget.clientName,
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: const Color(0xFF9A7F8A))),
                    const SizedBox(width: 10),
                    if (_order.dueDate != null)
                      _metaChip(Icons.calendar_today_outlined,
                          _formatDate(_order.dueDate)),
                    const SizedBox(width: 6),
                    if (_order.price != null)
                      _metaChip(Icons.payments_outlined,
                          '₦${_order.price!.toStringAsFixed(0)}'),
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // ── DRESS IMAGE ANALYZER ──
                  _sectionHeader('AI Cost Estimator',
                      icon: Icons.auto_awesome,
                      onAdd: null),
                  const SizedBox(height: 10),

                  if (_analyzingDress)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(12),
                        border: Border.all(color: _pinkSoft),
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                              color: _pink),
                          const SizedBox(height: 12),
                          Text(
                            'Analyzing dress...\nEstimating Nigerian market costs',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: const Color(
                                    0xFFB090A0)),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // dress image picker
                    GestureDetector(
                      onTap: _pickDressImage,
                      child: Container(
                        width: double.infinity,
                        height: _dressImagePath != null
                            ? 200
                            : 100,
                        decoration: BoxDecoration(
                          color: _pinkBlush,
                          borderRadius:
                          BorderRadius.circular(12),
                          border: Border.all(
                              color: _pinkSoft,
                              width: 1.5),
                          image: _dressImagePath != null
                              ? DecorationImage(
                            image: FileImage(File(
                                _dressImagePath!)),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _dressImagePath == null
                            ? Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons
                                  .add_photo_alternate_outlined,
                              color: _pink,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to upload dress photo',
                              style:
                              GoogleFonts.dmSans(
                                fontSize: 13,
                                color: _pink,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'AI will analyze and estimate costs',
                              style:
                              GoogleFonts.dmSans(
                                fontSize: 11,
                                color: const Color(
                                    0xFFB090A0),
                              ),
                            ),
                          ],
                        )
                            : Align(
                          alignment:
                          Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: _pickDressImage,
                            child: Container(
                              margin:
                              const EdgeInsets.all(
                                  8),
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5),
                              decoration: BoxDecoration(
                                color: _pink,
                                borderRadius:
                                BorderRadius.circular(
                                    8),
                              ),
                              child: Text(
                                'Change photo',
                                style:
                                GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // dress analysis result
                    if (_dressAnalysis != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1F28),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFFED93B1),
                                    size: 14),
                                const SizedBox(width: 6),
                                Text('AI Analysis',
                                    style:
                                    GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: const Color(
                                          0xFF9A7F8A),
                                      fontWeight:
                                      FontWeight.w500,
                                    )),
                                const Spacer(),
                                if (_complexity != null)
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 8,
                                        vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                      _complexityColor(
                                          _complexity)
                                          .withValues(
                                          alpha: .2),
                                      borderRadius:
                                      BorderRadius
                                          .circular(6),
                                    ),
                                    child: Text(
                                      _complexity!
                                          .toUpperCase(),
                                      style:
                                      GoogleFonts.dmSans(
                                        fontSize: 9,
                                        fontWeight:
                                        FontWeight.w500,
                                        color:
                                        _complexityColor(
                                            _complexity),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _dressAnalysis!,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: const Color(
                                      0xFF9A7F8A),
                                  height: 1.5),
                            ),
                            if (_tailorNotes != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding:
                                const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _pinkBlush,
                                  borderRadius:
                                  BorderRadius.circular(
                                      6),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    const Icon(
                                        Icons.lightbulb_outline,
                                        color: _pink,
                                        size: 13),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _tailorNotes!,
                                        style:
                                        GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: _pink,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 20),

                  // ── EXPENSE BREAKDOWN ──
                  _sectionHeader(
                    'Expense Breakdown',
                    icon: Icons.receipt_long_outlined,
                    onAdd: _addManualExpense,
                  ),
                  const SizedBox(height: 10),

                  _expenses.isEmpty
                      ? _emptyState(
                      'Upload a dress photo above to auto-generate expenses\nor tap + to add manually')
                      : Column(
                    children: [
                      ..._expenses.map((e) =>
                          Container(
                            margin:
                            const EdgeInsets.only(
                                bottom: 6),
                            padding: const EdgeInsets
                                .symmetric(
                                horizontal: 14,
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(
                                  10),
                              border: Border.all(
                                  color: _pinkSoft),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.description,
                                    style: GoogleFonts
                                        .dmSans(
                                      fontSize: 13,
                                      color: _black,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₦${e.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts
                                      .playfairDisplay(
                                    fontSize: 14,
                                    color: _pink,
                                  ),
                                ),
                                const SizedBox(
                                    width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final provider = context.read<ClientProvider>();
                                    await provider.deleteExpense(e.id!);
                                    _loadData();
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: Color(
                                        0xFFB090A0),
                                  ),
                                ),
                              ],
                            ),
                          )),

                      // total
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12),
                        decoration: BoxDecoration(
                          color: _black,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            Text('Estimated Total',
                                style:
                                GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.w500,
                                )),
                            Text(
                              '₦${_total.toStringAsFixed(0)}',
                              style: GoogleFonts
                                  .playfairDisplay(
                                fontSize: 20,
                                color: const Color(
                                    0xFFF4C0D1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── MARKET SHOPPING LIST ──
                  _sectionHeader(
                    'Market List',
                    icon: Icons.shopping_bag_outlined,
                    onAdd: _addShoppingNote,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap items to mark as bought ✓',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFFB090A0),
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),

                  _shoppingItems.isEmpty
                      ? _emptyState(
                      'No items yet — tap + to add what to buy at the market')
                      : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9F5),
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                          color: _pinkSoft),
                    ),
                    child: Column(
                      children: [
                        // notepad header
                        Container(
                          padding: const EdgeInsets
                              .symmetric(
                              horizontal: 14,
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: _pink,
                            borderRadius:
                            const BorderRadius.only(
                              topLeft:
                              Radius.circular(11),
                              topRight:
                              Radius.circular(11),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons
                                      .shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Shopping list — ${_shoppingItems.where((i) => i.isBought).length}/${_shoppingItems.length} bought',
                                style:
                                GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // items
                        ..._shoppingItems.map(
                              (item) => InkWell(
                                onTap: () async {
                                  final provider = context.read<ClientProvider>();
                                  await provider.toggleShoppingItem(
                                      item.id!, !item.isBought);
                                  _loadData();
                                },
                            child: Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 14,
                                  vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color:
                                      _pinkSoft
                                          .withValues(
                                          alpha:
                                          .5)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration:
                                    BoxDecoration(
                                      color: item
                                          .isBought
                                          ? _pink
                                          : Colors.white,
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          5),
                                      border: Border.all(
                                        color: item
                                            .isBought
                                            ? _pink
                                            : _pinkSoft,
                                      ),
                                    ),
                                    child: item.isBought
                                        ? const Icon(
                                      Icons
                                          .check_rounded,
                                      size: 12,
                                      color: Colors
                                          .white,
                                    )
                                        : null,
                                  ),
                                  const SizedBox(
                                      width: 12),
                                  Expanded(
                                    child: Text(
                                      item.item,
                                      style: GoogleFonts
                                          .dmSans(
                                        fontSize: 13,
                                        color: item
                                            .isBought
                                            ? const Color(
                                            0xFFB090A0)
                                            : _black,
                                        decoration: item
                                            .isBought
                                            ? TextDecoration
                                            .lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final provider = context.read<ClientProvider>();
                                      await provider.deleteShoppingItem(item.id!);
                                      _loadData();
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: Color(
                                          0xFFB090A0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _sectionHeader(String title,
      {required IconData icon, required VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: _pink, size: 16),
            const SizedBox(width: 6),
            Text(title,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 16, color: _black)),
          ],
        ),
        if (onAdd != null)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _pinkBlush,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('+ Add',
                  style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: _pink,
                      fontWeight: FontWeight.w500)),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pinkSoft),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFFB090A0),
              fontStyle: FontStyle.italic)),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1F28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A2E40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF9A7F8A)),
          const SizedBox(width: 5),
          Text(text,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF9A7F8A))),
        ],
      ),
    );
  }

  Widget _statusBtn(String status, String label) {
    final isSelected = _order.status == status;
    return GestureDetector(
      onTap: () => _updateStatus(status),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? _statusColor(status).withValues(alpha: .2)
              : const Color(0xFF2C1F28),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? _statusColor(status)
                : const Color(0xFF4A2E40),
          ),
        ),
        child: Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? _statusColor(status)
                    : const Color(0xFF9A7F8A))),
      ),
    );
  }

  Widget _sheetField(
      String label,
      TextEditingController controller, {
        String? hint,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFFB090A0),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: GoogleFonts.dmSans(fontSize: 13, color: _black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
                color: const Color(0xFFD0B0C0),
                fontSize: 12,
                fontStyle: FontStyle.italic),
            filled: true,
            fillColor: _cream,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pinkSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pinkSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: _pink, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}


