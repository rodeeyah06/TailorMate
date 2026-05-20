import 'package:flutter/material.dart';
import 'package:tailormate/screens/client/whatsapp_parse_screen.dart';

class WhatsAppParseWrapper extends StatelessWidget {
  final String sharedText;
  const WhatsAppParseWrapper({super.key, required this.sharedText});

  @override
  Widget build(BuildContext context) {
    return WhatsAppParseScreen(initialText: sharedText);
  }
}

