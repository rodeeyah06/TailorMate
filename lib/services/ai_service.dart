import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const _apiKey = String.fromEnvironment('GEMINI_KEY');

  // ── TEXT PARSE (WhatsApp import) ──
  static Future<Map<String, dynamic>> parseMeasurements(
      String text) async {
    final model = GenerativeModel(
      model:  'gemini-2.5-flash',
      apiKey: _apiKey,
    );

    final prompt = '''
Extract client measurements from this text and return ONLY a JSON object with no extra text, no markdown, no backticks.

Text: "$text"

Return this exact JSON structure (use null for missing values):
{
  "name": null,
  "phone": null,
  "bust": null,
  "underbust": null,
  "nipple_to_nipple": null,
  "waist": null,
  "hips": null,
  "shoulder": null,
  "sleeve": null,
  "sleeve_length": null,
  "full_length": null,
  "half_length": null,
  "thigh": null,
  "neck": null,
  "back": null,
  "notes": null
}
''';

    final response = await model.generateContent([
      Content.text(prompt),
    ]);

    final content = response.text ?? '{}';
    final cleaned = content
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    return jsonDecode(cleaned);
  }

  // ── IMAGE ANALYSIS (dress cost breakdown) ──
  static Future<Map<String, dynamic>> analyzeDress({
    required String imagePath,
    required String outfitName,
    String? fabric,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );

    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();

    final ext = imagePath.split('.').last.toLowerCase();
    final mimeType = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
        ? 'image/webp'
        : 'image/jpeg';

    final prompt = '''
You are an expert Nigerian tailor and fabric market analyst.
Analyze this dress/outfit image and provide a detailed cost breakdown based on current Nigerian market prices (2025).

Outfit name: $outfitName
${fabric != null ? 'Fabric type mentioned: $fabric' : ''}

Look at the dress carefully and identify:
- Type and amount of fabric needed
- Lining requirements
- Embellishments (stones, applique, beading, sequins etc)
- Structural elements (boning, padding, interfacing)
- Zips, buttons, hooks
- Labour complexity
- Any other materials specific to this style

Return ONLY a JSON object with no extra text, no markdown, no backticks:
{
  "dress_analysis": "Brief description of what you see",
  "complexity": "simple/medium/complex/highly complex",
  "expenses": [
    {
      "description": "item name",
      "quantity": "e.g. 4 yards",
      "amount": 8000
    }
  ],
  "shopping_list": [
    "item to buy at market"
  ],
  "total_estimated": 0,
  "tailor_notes": "Any special notes for the tailor"
}

Use realistic Nigerian market prices in Naira (2025):
- Ankara: 2500-4500 per yard
- Plain lace: 8000-15000 per yard
- French lace: 15000-35000 per yard
- George fabric: 12000-25000 per yard
- Aso-oke: 8000-20000 per yard
- Chiffon: 1500-3000 per yard
- Regular lining: 800-1500 per yard
- Boning: 500-800 per metre
- Invisible zip: 500-800 each
- Rhinestones pack: 2000-5000
- Applique stones: 3000-8000
- Sequin fabric: 3000-6000 per yard
- Thread: 300-500
- Labour simple: 8000-15000
- Labour medium: 15000-35000
- Labour complex: 35000-80000
- Labour highly complex: 80000-200000
''';

    final response = await model.generateContent([
      Content.multi([
        DataPart(mimeType, imageBytes),
        TextPart(prompt),
      ]),
    ]);

    final content = response.text ?? '{}';
    final cleaned = content
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    return jsonDecode(cleaned);
  }
}