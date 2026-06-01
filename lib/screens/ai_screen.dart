import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../models/enums.dart';
import '../providers/fasting_provider.dart';
import '../providers/meal_provider.dart';
import '../services/ai_service.dart';
import '../services/shopping_service.dart';
import '../widgets/app_header.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<AiMessage> _messages = [];
  bool _loading = false;
  bool _hasKey = false;

  static const _quickActions = [
    ('Suggest meals to prep', LucideIcons.utensils),
    ('Best fasting protocol for me', LucideIcons.timer),
    ('Add ingredients to my list', LucideIcons.shoppingCart),
    ('How do I stay full longer?', LucideIcons.heart),
  ];

  static const _suggestions = [
    'What meals should I prep this week?',
    'Which fasting protocol fits a beginner?',
    'Generate a shopping list for chicken recipes',
    'Best high-protein breakfast ideas?',
  ];

  @override
  void initState() {
    super.initState();
    _checkKey();
  }

  Future<void> _checkKey() async {
    final key = await AiService.instance.getApiKey();
    if (mounted) setState(() => _hasKey = key != null && key.isNotEmpty);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    setState(() {
      _messages.add(AiMessage(role: 'user', content: text.trim()));
      _loading = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    final reply = await AiService.instance.ask(text, _messages);
    setState(() {
      _messages.add(reply);
      _loading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _handleAction(AiAction action) async {
    switch (action.type) {
      case 'set_fasting':
        final protocolName = action.data['protocol'] as String? ?? 'h16_8';
        final protocol = FastingProtocol.values.firstWhere(
          (p) => p.name == protocolName,
          orElse: () => FastingProtocol.h16_8,
        );
        ref.read(fastingProvider.notifier).startFast(protocol);
        if (mounted) context.go('/fasting');

      case 'add_shopping':
        final items = (action.data['items'] as List? ?? []).whereType<Map<String, dynamic>>();
        for (final item in items) {
          await ShoppingService.instance.addItem(
            name: item['name'] as String? ?? '',
            amount: item['amount'] as String? ?? '',
            unit: item['unit'] as String? ?? '',
            category: item['category'] as String? ?? 'Other',
          );
        }
        ref.invalidate(shoppingItemsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${items.length} items added to your shopping list!'),
              backgroundColor: AppColors.forestGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

      case 'open_meals':
        if (mounted) context.go('/meals');

      case 'open_fasting':
        if (mounted) context.go('/fasting');
    }
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _hasKey ? AppColors.greenLight : AppColors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasKey
                    ? AppColors.forestGreen.withValues(alpha: 0.3)
                    : AppColors.orange.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 7, color: _hasKey ? AppColors.forestGreen : AppColors.orange),
                const SizedBox(width: 4),
                Text(
                  _hasKey ? 'Gemini AI' : 'No Key',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _hasKey ? AppColors.forestGreen : AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _messages.isEmpty ? 1 : _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (_messages.isEmpty) return _buildIntro();
                if (_loading && i == _messages.length) return const _TypingBubble();
                final msg = _messages[i];
                return _MessageBubble(message: msg, onAction: _handleAction);
              },
            ),
          ),
          if (!_hasKey) _NoKeyBanner(onSetup: () => context.push('/profile')),
          _InputBar(ctrl: _ctrl, loading: _loading, enabled: _hasKey, onSend: _send),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset('assets/images/happy.png', height: 64),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hey there! 👋',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark)),
                        SizedBox(height: 4),
                        Text("I can suggest meals to prep,\nrecommend a fasting schedule,\nand fill your shopping list!",
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickActions.map((action) => GestureDetector(
                  onTap: () => _send(action.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(action.$2, size: 13, color: AppColors.forestGreen),
                        const SizedBox(width: 5),
                        Text(action.$1,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestGreen)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Try asking me...',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
        ),
        const SizedBox(height: 10),
        ..._suggestions.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _send(s),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.sparkles, size: 14, color: AppColors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s,
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiMessage message;
  final Future<void> Function(AiAction) onAction;
  const _MessageBubble({required this.message, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
                  child: ClipOval(child: Image.asset('assets/images/happy.png', fit: BoxFit.cover)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.forestGreen : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? AppColors.white : AppColors.textDark,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Action buttons
          if (message.actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.actions.map((action) => _ActionButton(
                  action: action,
                  onTap: () => onAction(action),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final AiAction action;
  final VoidCallback onTap;
  const _ActionButton({required this.action, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _done = false;

  IconData get _icon {
    switch (widget.action.type) {
      case 'set_fasting': return LucideIcons.timer;
      case 'add_shopping': return LucideIcons.shoppingCart;
      case 'open_meals': return LucideIcons.calendarDays;
      case 'open_fasting': return LucideIcons.timer;
      default: return LucideIcons.zap;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _done ? null : () {
        setState(() => _done = true);
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _done ? AppColors.greenLight : AppColors.forestGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_done ? Icons.check : _icon, size: 13, color: _done ? AppColors.forestGreen : AppColors.white),
            const SizedBox(width: 5),
            Text(
              _done ? 'Done!' : widget.action.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _done ? AppColors.forestGreen : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
            child: ClipOval(child: Image.asset('assets/images/happy.png', fit: BoxFit.cover)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const _ThinkingDots(),
          ),
        ],
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final opacity = ((_anim.value * 3 - i) % 1.0).clamp(0.2, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NoKeyBanner extends StatelessWidget {
  final VoidCallback onSetup;
  const _NoKeyBanner({required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, size: 16, color: AppColors.orange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Add your free Gemini API key to enable AI.',
                style: TextStyle(fontSize: 12, color: AppColors.textDark)),
          ),
          GestureDetector(
            onTap: onSetup,
            child: const Text('Set up',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.orange)),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool loading;
  final bool enabled;
  final void Function(String) onSend;
  const _InputBar({required this.ctrl, required this.loading, required this.enabled, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                onSubmitted: enabled ? onSend : null,
                enabled: enabled,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: enabled ? 'Ask your AI Buddy...' : 'Set up Gemini API key first',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.cream,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (loading || !enabled) ? null : () => onSend(ctrl.text),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: (loading || !enabled) ? AppColors.border : AppColors.forestGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.send, color: AppColors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
