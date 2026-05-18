import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/screens/home/homepage.dart';
import 'package:tailormate/screens/splash_screen.dart';

void main() async {
  // ADD this line — required for sqflite to work on real devices
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TailorMateApp());
}

class TailorMateApp extends StatelessWidget {
  const TailorMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: MaterialApp(
        title: 'TailorMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4537E),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.dmSansTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFFDF8F2),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}