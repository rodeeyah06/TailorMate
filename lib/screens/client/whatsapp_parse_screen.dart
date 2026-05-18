import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/models/client.dart';
import 'package:tailormate/models/measurement.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/services/ai_service.dart';

class WhatsAppParseScreen extends StatefulWidget {
  const WhatsAppParseScreen({super.key});

  @override
  State<WhatsAppParseScreen> createState() =>
      _WhatsAppParseScreenState();
}

class _WhatsAppParseScreenState extends State<WhatsAppParseScreen> {
  final _textController = TextEditingController();
  Map<String, dynamic>? _parsed;
  bool _isParsing = false;
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bustCtrl;
  late TextEditingController _underbustCtrl;
  late TextEditingController _nippleCtrl;
  late TextEditingController _waistCtrl;
  late TextEditingController _hipsCtrl;
  late TextEditingController _shoulderCtrl;
  late TextEditingController _sleeveCtrl;
  late TextEditingController _sleeveLenCtrl;
  late TextEditingController _fullLenCtrl;
  late TextEditingController _halfLenCtrl;
  late TextEditingController _thighCtrl;
  late TextEditingController _neckCtrl;
  late TextEditingController _backCtrl;
  late TextEditingController _notesCtrl;

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _pinkBlush = Color(0xFFFBEAF0);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _bustCtrl = TextEditingController();
    _underbustCtrl = TextEditingController();
    _nippleCtrl = TextEditingController();
    _waistCtrl = TextEditingController();
    _hipsCtrl = TextEditingController();
    _shoulderCtrl = TextEditingController();
    _sleeveCtrl = TextEditingController();
    _sleeveLenCtrl = TextEditingController();
    _fullLenCtrl = TextEditingController();
    _halfLenCtrl = TextEditingController();
    _thighCtrl = TextEditingController();
    _neckCtrl = TextEditingController();
    _backCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bustCtrl.dispose();
    _underbustCtrl.dispose();
    _nippleCtrl.dispose();
    _waistCtrl.dispose();
    _hipsCtrl.dispose();
    _shoulderCtrl.dispose();
    _sleeveCtrl.dispose();
    _sleeveLenCtrl.dispose();
    _fullLenCtrl.dispose();
    _halfLenCtrl.dispose();
    _thighCtrl.dispose();
    _neckCtrl.dispose();
    _backCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _fillControllers(Map<String, dynamic> data) {
    _nameCtrl.text = data['name']?.toString() ?? '';
    _phoneCtrl.text = data['phone']?.toString() ?? '';
    _bustCtrl.text = data['bust']?.toString() ?? '';
    _underbustCtrl.text = data['underbust']?.toString() ?? '';
    _nippleCtrl.text = data['nipple_to_nipple']?.toString() ?? '';
    _waistCtrl.text = data['waist']?.toString() ?? '';
    _hipsCtrl.text = data['hips']?.toString() ?? '';
    _shoulderCtrl.text = data['shoulder']?.toString() ?? '';
    _sleeveCtrl.text = data['sleeve']?.toString() ?? '';
    _sleeveLenCtrl.text = data['sleeve_length']?.toString() ?? '';
    _fullLenCtrl.text = data['full_length']?.toString() ?? '';
    _halfLenCtrl.text = data['half_length']?.toString() ?? '';
    _thighCtrl.text = data['thigh']?.toString() ?? '';
    _neckCtrl.text = data['neck']?.toString() ?? '';
    _backCtrl.text = data['back']?.toString() ?? '';
    _notesCtrl.text = data['notes']?.toString() ?? '';
  }

  Future<void> _parse() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _isParsing = true);
    try {
      final result = await AiService.parseMeasurements(
          _textController.text.trim());
      setState(() {
        _parsed = result;
        _fillControllers(result);
      });
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
      if (mounted) setState(() => _isParsing = false);
    }
  }

  double? _val(TextEditingController c) {
    if (c.text.trim().isEmpty) return null;
    return double.tryParse(c.text.trim());
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a client name',
              style: GoogleFonts.dmSans()),
          backgroundColor: _pink,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<ClientProvider>();

    try {
      final now = DateTime.now().toIso8601String();

      final client = Client(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final measurement = Measurement(
        clientId: 0,
        bust: _val(_bustCtrl),
        underbust: _val(_underbustCtrl),
        nipple_to_nipple: _val(_nippleCtrl),
        waist: _val(_waistCtrl),
        hips: _val(_hipsCtrl),
        shoulder: _val(_shoulderCtrl),
        sleeve: _val(_sleeveCtrl),
        sleeveLength: _val(_sleeveLenCtrl),
        fullLength: _val(_fullLenCtrl),
        halfLength: _val(_halfLenCtrl),
        thigh: _val(_thighCtrl),
        neck: _val(_neckCtrl),
        back: _val(_backCtrl),
        recordedAt: now,
      );

      await provider.addClient(client, measurement);
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
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1F28),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF4A2E40)),
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
                    Text('Import from WhatsApp',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18, color: Colors.white)),
                    Text(
                        'Paste message → AI extracts measurements',
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: const Color(0xFF9A7F8A))),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paste WhatsApp message',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFFB090A0),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _pinkSoft),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: 5,
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: _black),
                      decoration: InputDecoration(
                        hintText:
                        'e.g. "her bust is 38, waist na 32, hips 42, her name is Amaka"',
                        hintStyle: GoogleFonts.dmSans(
                            color: const Color(0xFFD0B0C0),
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isParsing ? null : _parse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isParsing
                          ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 16),
                          const SizedBox(width: 6),
                          Text('Extract with AI',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),

                  if (_parsed != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Color(0xFF7BC47F), size: 16),
                        const SizedBox(width: 6),
                        Text('AI extracted — review and confirm',
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(0xFF7BC47F),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _sectionLabel('Client Info'),
                    const SizedBox(height: 10),
                    _field('Name', _nameCtrl),
                    const SizedBox(height: 8),
                    _field('Phone', _phoneCtrl,
                        keyboard: TextInputType.phone),
                    const SizedBox(height: 8),
                    _field('Notes', _notesCtrl, maxLines: 2),

                    const SizedBox(height: 16),
                    _sectionLabel('Measurements'),
                    const SizedBox(height: 10),

                    _measRowPair('Bust', _bustCtrl,
                        'Underbust', _underbustCtrl),
                    const SizedBox(height: 8),
                    _measRowPair('Nipple-Nipple', _nippleCtrl,
                        'Waist', _waistCtrl),
                    const SizedBox(height: 8),
                    _measRowPair('Hips', _hipsCtrl,
                        'Shoulder', _shoulderCtrl),
                    const SizedBox(height: 8),
                    _measRowPair('Sleeve', _sleeveCtrl,
                        'Sleeve Length', _sleeveLenCtrl),
                    const SizedBox(height: 8),
                    _measRowPair('Full Length', _fullLenCtrl,
                        'Half Length', _halfLenCtrl),
                    const SizedBox(height: 8),
                    _measRowPair('Thigh', _thighCtrl,
                        'Neck', _neckCtrl),
                    const SizedBox(height: 8),
                    _measRowPair('Back', _backCtrl, '', null),

                    const SizedBox(height: 24),

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
                            color: Colors.white,
                            strokeWidth: 2)
                            : Text('Save Client',
                            style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
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
            style: GoogleFonts.playfairDisplay(
                fontSize: 15, color: _black)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _pinkSoft)),
      ],
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 10,
                color: const Color(0xFFB090A0),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: GoogleFonts.dmSans(fontSize: 13, color: _black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _pinkSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _pinkSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: _pink, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _measRowPair(
      String label1,
      TextEditingController ctrl1,
      String label2,
      TextEditingController? ctrl2,
      ) {
    return Row(
      children: [
        Expanded(child: _measFieldSmall(label1, ctrl1)),
        const SizedBox(width: 8),
        Expanded(
          child: ctrl2 != null
              ? _measFieldSmall(label2, ctrl2)
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _measFieldSmall(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 9,
                color: const Color(0xFFB090A0),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true),
          style: GoogleFonts.dmSans(
              fontSize: 14,
              color: _pink,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: '—',
            hintStyle: GoogleFonts.dmSans(
                color: const Color(0xFFD0B0C0), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _pinkSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _pinkSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: _pink, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }
}