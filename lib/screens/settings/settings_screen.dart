import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useCm = false;
  bool _darkMode = false;

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _cream = Color(0xFFFDF8F2);

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
                      border:
                      Border.all(color: const Color(0xFF4A2E40)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFED93B1),
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20, color: Colors.white),
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
                  _sectionLabel('Preferences'),
                  const SizedBox(height: 8),

                  _toggleTile(
                    'Use centimetres (cm)',
                    'Default is inches',
                    Icons.straighten_rounded,
                    _useCm,
                        (val) => setState(() => _useCm = val),
                  ),

                  const SizedBox(height: 24),
                  _sectionLabel('About'),
                  const SizedBox(height: 8),

                  _infoTile('App name', 'TailorMate'),
                  _infoTile('Version', '1.0.0'),
                  _infoTile('Built for', "Mummy's Studio 🎀"),
                  _infoTile('Made with', 'Flutter + SQLite'),

                  const SizedBox(height: 24),
                  _sectionLabel('Data'),
                  const SizedBox(height: 8),

                  _actionTile(
                    'Clear all data',
                    'Delete all clients, measurements and orders',
                    Icons.delete_outline_rounded,
                    Colors.red.shade300,
                        () => _confirmClearData(),
                  ),

                  const SizedBox(height: 40),

                  // footer
                  Center(
                    child: Text(
                      'Made with 💗 for Mummy',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFFB090A0),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Clear all data?',
            style: GoogleFonts.playfairDisplay(fontSize: 18)),
        content: Text(
          'This will permanently delete ALL clients, measurements and orders. This cannot be undone.',
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
            child: Text('Clear',
                style: GoogleFonts.dmSans(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coming soon!',
              style: GoogleFonts.dmSans()),
          backgroundColor: _pink,
        ),
      );
    }
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, color: _black)),
        const SizedBox(width: 10),
        Expanded(
            child: Container(height: 1, color: _pinkSoft)),
      ],
    );
  }

  Widget _toggleTile(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pinkSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFBEAF0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _pink, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _black)),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFFB090A0))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _pink,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pinkSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: const Color(0xFFB090A0))),
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _black)),
        ],
      ),
    );
  }

  Widget _actionTile(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: color)),
                  Text(subtitle,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFFB090A0))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}