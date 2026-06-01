import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import 'meal_service.dart';

class AiAction {
  final String type;
  final String label;
  final Map<String, dynamic> data;
  const AiAction({required this.type, required this.label, required this.data});

  factory AiAction.fromJson(Map<String, dynamic> json) => AiAction(
        type: json['type'] as String? ?? '',
        label: json['label'] as String? ?? '',
        data: json,
      );
}

class AiMessage {
  final String role;
  final String content;
  final List<AiAction> actions;
  const AiMessage({required this.role, required this.content, this.actions = const []});
}

class AiService {
  AiService._();
  static final instance = AiService._();

  static const _apiKeyPref = 'gemini_api_key';
  static const _apiBase =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key.trim());
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
  }

  Future<AiMessage> ask(String userMessage, List<AiMessage> history) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return const AiMessage(
        role: 'assistant',
        content: 'No API key set. Go to Profile → AI Settings to add your free Gemini API key.',
      );
    }

    try {
      final recipes = await MealService.instance.getAllRecipes();
      final recipeContext = recipes.isEmpty
          ? 'No recipes saved yet.'
          : recipes.map((r) {
              final ings = r.ingredients.map((i) => i.name).join(', ');
              return '- ${r.recipe.name} (${r.recipe.prepTime + r.recipe.cookTime} min): $ings';
            }).join('\n');

      final protocols = FastingProtocol.values
          .map((p) => '${p.name}: ${p.label} — ${p.description}')
          .join('\n');

      final systemPrompt = '''You are BiteBuddy, a friendly meal prep and intermittent fasting assistant inside a mobile app. Be concise, warm, and practical.

User's saved recipes:
$recipeContext

Available fasting protocols:
$protocols

Shopping item categories: Produce, Meat & Seafood, Dairy & Eggs, Grains & Bread, Pantry, Frozen, Beverages, Other.

Always respond with valid JSON in this exact format:
{
  "text": "Your friendly response here (conversational, 2-4 sentences max)",
  "actions": [
    // Include only actions relevant to this specific request.
    // Action types:
    // {"type": "set_fasting", "label": "Start 16:8 Fasting", "protocol": "h16_8"},
    // {"type": "add_shopping", "label": "Add ingredients to list", "items": [{"name": "...", "amount": "...", "unit": "...", "category": "..."}]},
    // {"type": "open_meals", "label": "Open Meal Planner"},
    // {"type": "open_fasting", "label": "Open Fasting Timer"}
  ]
}

Protocol values: h16_8, h18_6, h20_4, h24. Use empty array for actions if none apply.''';

      final contents = <Map<String, dynamic>>[];
      for (final msg in history) {
        if (msg.role == 'system') continue;
        contents.add({
          'role': msg.role == 'assistant' ? 'model' : 'user',
          'parts': [
            {'text': msg.content}
          ],
        });
      }
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ],
      });

      final response = await http
          .post(
            Uri.parse('$_apiBase?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'system_instruction': {
                'parts': [
                  {'text': systemPrompt}
                ]
              },
              'contents': contents,
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 800,
                'responseMimeType': 'application/json',
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const AiMessage(
          role: 'assistant',
          content: 'Invalid API key. Go to Profile → AI Settings to update it.',
        );
      }
      if (response.statusCode != 200) {
        return AiMessage(
          role: 'assistant',
          content: 'API error (${response.statusCode}). Try again shortly.',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final rawText =
          ((decoded['candidates'] as List).first['content']['parts'] as List).first['text']
              as String;

      try {
        final parsed = jsonDecode(rawText) as Map<String, dynamic>;
        final text = parsed['text'] as String? ?? rawText;
        final actionsJson = parsed['actions'] as List? ?? [];
        final actions = actionsJson
            .whereType<Map<String, dynamic>>()
            .map(AiAction.fromJson)
            .where((a) => a.type.isNotEmpty)
            .toList();
        return AiMessage(role: 'assistant', content: text, actions: actions);
      } catch (_) {
        return AiMessage(role: 'assistant', content: rawText);
      }
    } on http.ClientException {
      return const AiMessage(
        role: 'assistant',
        content: 'No internet connection. Check your network and try again.',
      );
    } catch (_) {
      return const AiMessage(
        role: 'assistant',
        content: 'Something went wrong. Please try again.',
      );
    }
  }
}
