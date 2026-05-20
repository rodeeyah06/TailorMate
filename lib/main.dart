import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/screens/splash_screen.dart';
import 'package:tailormate/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const TailorMateApp());
}

class TailorMateApp extends StatelessWidget {
  const TailorMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientProvider(),
      child: MaterialApp(
        title: 'TailorMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'DM Sans',
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}