import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../services/ai_service.dart';
import '../widgets/app_gradient_body.dart';
import '../widgets/app_header.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _ctrl = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  bool _hasKey = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await AiService.instance.getApiKey();
    if (key != null && key.isNotEmpty) {
      setState(() {
        _hasKey = true;
        _ctrl.text = key;
      });
    }
  }

  Future<void> _save() async {
    final key = _ctrl.text.trim();
    if (key.isEmpty) return;
    setState(() { _saving = true; _status = ''; });
    await AiService.instance.saveApiKey(key);
    setState(() { _saving = false; _hasKey = true; _status = 'Saved!'; });
  }

  Future<void> _clear() async {
    await AiService.instance.clearApiKey();
    _ctrl.clear();
    setState(() { _hasKey = false; _status = 'Key removed.'; });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppHeader(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        showLogo: false,
      ),
      body: AppGradientBody(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Settings',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 2),
            const Text('Connect your free Gemini API key',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 24),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _hasKey ? AppColors.greenLight : AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hasKey
                      ? AppColors.forestGreen.withValues(alpha: 0.3)
                      : AppColors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hasKey ? Icons.check_circle : LucideIcons.alertCircle,
                    size: 14,
                    color: _hasKey ? AppColors.forestGreen : AppColors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _hasKey ? 'Gemini AI connected' : 'No API key set',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _hasKey ? AppColors.forestGreen : AppColors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // How to get key
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.info, size: 14, color: AppColors.forestGreen),
                      SizedBox(width: 6),
                      Text('How to get a free key',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Step(n: '1', text: 'Go to aistudio.google.com'),
                  _Step(n: '2', text: 'Sign in with your Google account'),
                  _Step(n: '3', text: 'Click "Get API key" → "Create API key"'),
                  _Step(n: '4', text: 'Copy the key and paste it below'),
                  const SizedBox(height: 6),
                  const Text(
                    'Free tier: 15 requests/min, 1M tokens/day — more than enough for daily use.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Key input
            const Text('Your API Key',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              obscureText: _obscure,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'AIza...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.forestGreen, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? LucideIcons.eyeOff : LucideIcons.eye, size: 18, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _status == 'Saved!' ? AppColors.forestGreen : AppColors.textMuted,
                  )),
            ],
            const SizedBox(height: 16),

            // Save button
            GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _saving ? AppColors.border : AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Text('Save API Key',
                          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),

            if (_hasKey) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _clear,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Remove Key',
                        style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Privacy note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.greenLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.forestGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your API key is stored only on this device and is never sent anywhere except Google\'s Gemini API.',
                      style: TextStyle(fontSize: 11, color: AppColors.forestGreen, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class _Step extends StatelessWidget {
  final String n;
  final String text;
  const _Step({required this.n, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18, height: 18,
          decoration: const BoxDecoration(color: AppColors.forestGreen, shape: BoxShape.circle),
          child: Center(child: Text(n, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
      ],
    ),
  );
}
