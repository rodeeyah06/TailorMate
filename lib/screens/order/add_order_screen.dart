import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/models/order.dart';
import 'package:tailormate/providers/client_provider.dart';

import '../../services/notification_service.dart';

class AddOrderScreen extends StatefulWidget {
  final int clientId;
  final String clientName;

  const AddOrderScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _outfitController = TextEditingController();
  final _fabricController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _dueDate;
  bool _isSaving = false;

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void dispose() {
    _outfitController.dispose();
    _fabricController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _pink,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ClientProvider>();

    try {
      final order = TailorOrder(
        clientId: widget.clientId,
        outfitName: _outfitController.text.trim(),
        fabric: _fabricController.text.trim().isEmpty
            ? null
            : _fabricController.text.trim(),
        price: _priceController.text.trim().isEmpty
            ? null
            : double.tryParse(_priceController.text.trim()),
        status: 'pending',
        dueDate: _dueDate?.toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await provider.addOrder(order);
      final savedOrders = await provider.getOrdersForClient(widget.clientId);
      if (savedOrders.isNotEmpty) {
        await NotificationService.scheduleOrderReminder(
            savedOrders.last);
      }
      if (mounted) Navigator.pop(context, true);
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(
        children: [
          // ── HEADER ──
          Container(
            color: _black,
            padding: const EdgeInsets.only(
                top: 52, left: 20, right: 20, bottom: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1F28),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF4A2E40)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFED93B1),
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Order',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.clientName,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF9A7F8A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── FORM ──
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Order Details'),
                    const SizedBox(height: 12),

                    _field('Outfit name', _outfitController,
                        required: true,
                        hint: 'e.g. Aso-oke agbada set'),
                    const SizedBox(height: 10),
                    _field('Fabric type', _fabricController,
                        hint: 'e.g. Ankara, Lace, Chiffon'),
                    const SizedBox(height: 10),
                    _field('Price (₦)', _priceController,
                        keyboard: TextInputType.number,
                        hint: 'e.g. 45000'),

                    const SizedBox(height: 20),
                    _sectionLabel('Due Date'),
                    const SizedBox(height: 12),

                    // date picker
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _pinkSoft),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: _pink, size: 16),
                            const SizedBox(width: 10),
                            Text(
                              _dueDate == null
                                  ? 'Select due date'
                                  : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: _dueDate == null
                                    ? const Color(0xFFC0A0B0)
                                    : _black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                            : Text(
                          'Save Order',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.playfairDisplay(fontSize: 16, color: _black)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _pinkSoft)),
      ],
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        bool required = false,
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
              fontWeight: FontWeight.w500,
              letterSpacing: .04,
            )),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          style: GoogleFonts.dmSans(fontSize: 13, color: _black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: const Color(0xFFD0B0C0),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: Colors.white,
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
              borderSide: const BorderSide(color: _pink, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
          validator: required
              ? (val) => val == null || val.trim().isEmpty
              ? 'Please enter $label'
              : null
              : null,
        ),
      ],
    );
  }
}