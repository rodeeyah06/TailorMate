import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/models/client.dart';
import 'package:tailormate/models/measurement.dart';
import 'package:tailormate/providers/client_provider.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;
  final Measurement? latestMeasurement;

  const EditClientScreen({
    super.key,
    required this.client,
    this.latestMeasurement,
  });

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  // measurement controllers
  late TextEditingController _bustController;
  late TextEditingController _underbustController;
  late TextEditingController _nippleToNippleController;
  late TextEditingController _waistController;
  late TextEditingController _hipsController;
  late TextEditingController _shoulderController;
  late TextEditingController _sleeveController;
  late TextEditingController _sleeveLengthController;
  late TextEditingController _fullLengthController;
  late TextEditingController _halfLengthController;
  late TextEditingController _thighController;
  late TextEditingController _neckController;
  late TextEditingController _backController;

  String? _photoPath;
  bool _isSaving = false;

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _pinkBlush = Color(0xFFFBEAF0);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    final m = widget.latestMeasurement;

    _nameController = TextEditingController(text: c.name);
    _phoneController = TextEditingController(text: c.phone ?? '');
    _notesController = TextEditingController(text: c.notes ?? '');
    _photoPath = c.photoPath;

    _bustController = TextEditingController(
        text: m?.bust?.toString() ?? '');
    _underbustController = TextEditingController(
        text: m?.underbust?.toString() ?? '');
    _nippleToNippleController = TextEditingController(
        text: m?.nipple_to_nipple?.toString() ?? '');
    _waistController = TextEditingController(
        text: m?.waist?.toString() ?? '');
    _hipsController = TextEditingController(
        text: m?.hips?.toString() ?? '');
    _shoulderController = TextEditingController(
        text: m?.shoulder?.toString() ?? '');
    _sleeveController = TextEditingController(
        text: m?.sleeve?.toString() ?? '');
    _sleeveLengthController = TextEditingController(
        text: m?.sleeveLength?.toString() ?? '');
    _fullLengthController = TextEditingController(
        text: m?.fullLength?.toString() ?? '');
    _halfLengthController = TextEditingController(
        text: m?.halfLength?.toString() ?? '');
    _thighController = TextEditingController(
        text: m?.thigh?.toString() ?? '');
    _neckController = TextEditingController(
        text: m?.neck?.toString() ?? '');
    _backController = TextEditingController(
        text: m?.back?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _bustController.dispose();
    _underbustController.dispose();
    _nippleToNippleController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoulderController.dispose();
    _sleeveController.dispose();
    _sleeveLengthController.dispose();
    _fullLengthController.dispose();
    _halfLengthController.dispose();
    _thighController.dispose();
    _neckController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  double? _parse(TextEditingController c) {
    if (c.text.trim().isEmpty) return null;
    return double.tryParse(c.text.trim());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ClientProvider>();

    try {
      final now = DateTime.now().toIso8601String();

      final updatedClient = widget.client.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        photoPath: _photoPath,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: now,
      );

      final newMeasurement = Measurement(
        clientId: widget.client.id!,
        bust: _parse(_bustController),
        underbust: _parse(_underbustController),
        nipple_to_nipple: _parse(_nippleToNippleController),
        waist: _parse(_waistController),
        hips: _parse(_hipsController),
        shoulder: _parse(_shoulderController),
        sleeve: _parse(_sleeveController),
        sleeveLength: _parse(_sleeveLengthController),
        fullLength: _parse(_fullLengthController),
        halfLength: _parse(_halfLengthController),
        thigh: _parse(_thighController),
        neck: _parse(_neckController),
        back: _parse(_backController),
        recordedAt: now,
      );

      await provider.updateClient(updatedClient, newMeasurement);

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
                    Text(
                      'Edit Client',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      widget.client.name,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFF9A7F8A)),
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
                    // photo picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _pinkBlush,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _pinkSoft, width: 1.5),
                            image: _photoPath != null
                                ? DecorationImage(
                              image:
                              FileImage(File(_photoPath!)),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: _photoPath == null
                              ? Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined,
                                  color: _pink, size: 22),
                              const SizedBox(height: 2),
                              Text('Photo',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: _pink)),
                            ],
                          )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionLabel('Client Info'),
                    const SizedBox(height: 10),

                    _field('Full name', _nameController,
                        required: true),
                    const SizedBox(height: 10),
                    _field('Phone number', _phoneController,
                        keyboard: TextInputType.phone),
                    const SizedBox(height: 10),
                    _field('Notes', _notesController,
                        maxLines: 2,
                        hint: 'e.g. prefers loose fit...'),

                    const SizedBox(height: 24),
                    _sectionLabel('Measurements (inches)'),
                    const SizedBox(height: 12),

                    _measRow('Bust', _bustController,
                        'Underbust', _underbustController),
                    const SizedBox(height: 10),
                    _measRow('Nipple-Nipple',
                        _nippleToNippleController,
                        'Waist', _waistController),
                    const SizedBox(height: 10),
                    _measRow('Hips', _hipsController,
                        'Shoulder', _shoulderController),
                    const SizedBox(height: 10),
                    _measRow('Sleeve', _sleeveController,
                        'Sleeve Length', _sleeveLengthController),
                    const SizedBox(height: 10),
                    _measRow('Full Length', _fullLengthController,
                        'Half Length', _halfLengthController),
                    const SizedBox(height: 10),
                    _measRow('Thigh', _thighController,
                        'Neck', _neckController),
                    const SizedBox(height: 10),
                    _measSingle('Back', _backController),

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
                          'Save Changes',
                          style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, color: _black)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _pinkSoft)),
      ],
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        bool required = false,
        int maxLines = 1,
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
                letterSpacing: .04)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: GoogleFonts.dmSans(fontSize: 13, color: _black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
                color: const Color(0xFFD0B0C0),
                fontSize: 12,
                fontStyle: FontStyle.italic),
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
              borderSide:
              const BorderSide(color: _pink, width: 1.5),
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

  Widget _measRow(
      String label1,
      TextEditingController ctrl1,
      String label2,
      TextEditingController ctrl2,
      ) {
    return Row(
      children: [
        Expanded(child: _measField(label1, ctrl1)),
        const SizedBox(width: 10),
        Expanded(child: _measField(label2, ctrl2)),
      ],
    );
  }

  Widget _measSingle(
      String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(child: _measField(label, controller)),
        const SizedBox(width: 10),
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _measField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 9,
                color: const Color(0xFFB090A0),
                fontWeight: FontWeight.w500,
                letterSpacing: .04)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.dmSans(
              fontSize: 14,
              color: _pink,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: '0.0',
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
                horizontal: 10, vertical: 10),
          ),
        ),
      ],
    );
  }
}