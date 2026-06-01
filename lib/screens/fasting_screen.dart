import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../models/enums.dart';
import '../providers/fasting_provider.dart';
import '../services/fasting_service.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';
import '../widgets/progress_ring.dart';

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  FastingProtocol _selected = FastingProtocol.h16_8;

  @override
  Widget build(BuildContext context) {
    final fasting = ref.watch(fastingProvider);
    final notifier = ref.read(fastingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppHeader(
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: AppColors.textMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            // Title
            const Text('Fasting Timer ✨',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(
              fasting.isActive
                  ? '${fasting.protocol.label} Intermittent Fasting'
                  : 'Choose your protocol below',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),

            // Progress ring
            Stack(
              alignment: Alignment.center,
              children: [
                ProgressRing(
                  progress: fasting.progress,
                  size: 260,
                  strokeWidth: 20,
                  trackColor: AppColors.greenLight,
                  progressColor: AppColors.forestGreen,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (fasting.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.forestGreen),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: AppColors.forestGreen),
                              SizedBox(width: 4),
                              Text('Fasting', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestGreen)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Text('Elapsed Time', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        fasting.isActive ? fasting.elapsedFormatted : '--:--:--',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      const Text('Time Remaining', style: TextStyle(fontSize: 12, color: AppColors.orange, fontWeight: FontWeight.w600)),
                      Text(
                        fasting.remainingFormatted,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Motivational pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                fasting.isActive
                    ? (fasting.isComplete ? 'Amazing! Fast complete! 🎉' : "You're doing great! 💚")
                    : 'Ready to start? 💪',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 20),

            // Stats row (when active)
            if (fasting.isActive) ...[
              Row(
                children: [
                  _StatBox(
                    icon: LucideIcons.clock,
                    iconColor: AppColors.forestGreen,
                    label: 'Started',
                    value: _fmtDate(DateTime.fromMillisecondsSinceEpoch(fasting.session!.startTime)),
                    sub: _fmtTime(DateTime.fromMillisecondsSinceEpoch(fasting.session!.startTime)),
                  ),
                  const SizedBox(width: 8),
                  _StatBox(
                    icon: LucideIcons.flag,
                    iconColor: AppColors.orange,
                    label: 'Ends',
                    value: _fmtDate(DateTime.fromMillisecondsSinceEpoch(fasting.session!.startTime).add(Duration(hours: fasting.session!.targetHours))),
                    sub: _fmtTime(DateTime.fromMillisecondsSinceEpoch(fasting.session!.startTime).add(Duration(hours: fasting.session!.targetHours))),
                    subColor: AppColors.orange,
                  ),
                  const SizedBox(width: 8),
                  const _StatBox(icon: LucideIcons.flame, iconColor: AppColors.orange, label: 'Streak', value: '7 Days', sub: 'Keep it up!'),
                  const SizedBox(width: 8),
                  const _StatBox(icon: LucideIcons.droplets, iconColor: Colors.blue, label: 'Hydration', value: '3 / 8 cups', sub: 'Drink more!', subColor: Colors.blue),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Protocol picker (inactive)
            if (!fasting.isActive) ...[
              ...FastingProtocol.values.map((p) => _ProtocolTile(
                protocol: p,
                selected: _selected == p,
                onTap: () => setState(() => _selected = p),
              )),
              const SizedBox(height: 8),
            ],

            // Action buttons
            if (fasting.isActive) ...[
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'Complete Fast ✓',
                      color: AppColors.forestGreen,
                      onTap: () => notifier.endFast(completed: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ActionBtn(
                    label: 'Stop',
                    color: AppColors.border,
                    textColor: AppColors.textDark,
                    onTap: () => notifier.endFast(completed: false),
                  ),
                ],
              ),
            ] else
              _ActionBtn(
                label: 'Start Fast',
                color: AppColors.forestGreen,
                width: double.infinity,
                onTap: () => notifier.startFast(_selected),
              ),

            if (fasting.isActive) ...[
              const SizedBox(height: 16),
              // Mascot motivational card
              AppCard(
                child: Row(
                  children: [
                    Image.asset('assets/images/hype.png', height: 72),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("You've got this!",
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.forestGreen)),
                          const SizedBox(height: 4),
                          const Text('Every hour you fast is a step\ntoward a healthier you.',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Proud of you!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                SizedBox(width: 4),
                                Text('🧡', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            _HistorySection(),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  String _fmtDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day) return 'Today';
    if (dt.day == now.day + 1) return 'Tomorrow';
    return '${dt.month}/${dt.day}';
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;
  final Color subColor;
  const _StatBox({required this.icon, required this.iconColor, required this.label, required this.value, required this.sub, this.subColor = AppColors.textMuted});

  @override
  Widget build(BuildContext context) => Expanded(
    child: AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark), textAlign: TextAlign.center),
          Text(sub, style: TextStyle(fontSize: 10, color: subColor, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final double? width;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, this.textColor = AppColors.white, this.width, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(28)),
      child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
    ),
  );
}

class _ProtocolTile extends StatelessWidget {
  final FastingProtocol protocol;
  final bool selected;
  final VoidCallback onTap;
  const _ProtocolTile({required this.protocol, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.greenLight : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.forestGreen : AppColors.border, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Text(protocol.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: selected ? AppColors.forestGreen : AppColors.textDark)),
          const SizedBox(width: 16),
          Expanded(child: Text(protocol.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
          if (selected) const Icon(Icons.check_circle, color: AppColors.forestGreen, size: 20),
        ],
      ),
    ),
  );
}

class _HistorySection extends StatefulWidget {
  @override
  State<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<_HistorySection> {
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    _future = FastingService.instance.getRecentSessions(7);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fasting History', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
              Text('See all', style: TextStyle(fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder(
            future: _future,
            builder: (context, snap) {
              final sessions = snap.data as List? ?? [];
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Row(
                children: List.generate(7, (i) {
                  final hasSession = i < sessions.length;
                  final completed = hasSession ? (sessions[i] as dynamic).completed as bool : false;
                  final isToday = i == DateTime.now().weekday - 1;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: isToday
                          ? BoxDecoration(border: Border.all(color: AppColors.forestGreen, width: 2), borderRadius: BorderRadius.circular(10))
                          : null,
                      child: Column(
                        children: [
                          Text(days[i], style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          const Text('16:8', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Icon(
                            hasSession ? (completed ? Icons.check_circle : Icons.remove_circle_outline) : Icons.remove_circle_outline,
                            size: 18,
                            color: hasSession && completed ? AppColors.forestGreen : AppColors.border,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
