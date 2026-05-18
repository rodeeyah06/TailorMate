import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailormate/screens/home/homepage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkMid = Color(0xFFED93B1);
  static const _pinkSoft = Color(0xFFF4C0D1);

  Future<void> _getStarted(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── LOGO ──
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1F28),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A2E40),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: _pink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.straighten_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── TITLE ──
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Tailor',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'Mate',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        color: _pinkMid,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'measurements. simplified.',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF9A7F8A),
                  letterSpacing: .12,
                ),
              ),

              const Spacer(flex: 2),

              // ── FEATURES ──
              _featureRow(Icons.people_outline_rounded,
                  'Store all client measurements in one place'),
              const SizedBox(height: 14),
              _featureRow(Icons.share_outlined,
                  'Share measurements directly to WhatsApp'),
              const SizedBox(height: 14),
              _featureRow(Icons.history_rounded,
                  'Track measurement history over time'),

              const Spacer(flex: 3),

              // ── GET STARTED BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _getStarted(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get started',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .02,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── SKIP / ALREADY HAVE ACCOUNT ──
              TextButton(
                onPressed: () => _getStarted(context),
                child: Text(
                  'Skip for now',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF6A4A55),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2C1F28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF4A2E40)),
          ),
          child: Icon(icon, color: const Color(0xFFED93B1), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF9A7F8A),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}