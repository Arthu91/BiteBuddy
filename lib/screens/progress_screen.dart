import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../core/database.dart';
import '../services/fasting_service.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<FastingSession>> _future;

  @override
  void initState() {
    super.initState();
    _future = FastingService.instance.getRecentSessions(14);
  }

  int _calcStreak(List<FastingSession> sessions) {
    int streak = 0;
    for (final s in sessions) {
      if (s.completed) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
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
        actions: const [],
      ),
      body: FutureBuilder<List<FastingSession>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snap.data ?? [];
          final completed = sessions.where((s) => s.completed).length;
          final adherence = sessions.isEmpty ? 0.0 : completed / sessions.length;
          final streak = _calcStreak(sessions);
          final last7 = sessions.take(7).toList().reversed.toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progress & Insights',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                const Text('Track your fasting journey',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 20),

                // Adherence + streak row
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.greenLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.target, size: 14, color: AppColors.forestGreen),
                                ),
                                const SizedBox(width: 6),
                                const Text('Adherence', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(adherence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.forestGreen),
                            ),
                            Text(
                              adherence >= 0.8 ? 'Excellent! 🎉' : adherence >= 0.5 ? 'Good progress' : 'Keep going 💪',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.flame, size: 14, color: AppColors.orange),
                                ),
                                const SizedBox(width: 6),
                                const Text('Streak', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$streak',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.orange),
                            ),
                            const Text('days in a row', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weekly bar chart
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Weekly Fasting', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                          Text('Last 7 days', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 110,
                        child: last7.isEmpty
                            ? const Center(child: Text('No sessions yet', style: TextStyle(color: AppColors.textMuted)))
                            : _WeekBarChart(sessions: last7),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Streak mascot card
                AppCard(
                  child: Row(
                    children: [
                      Image.asset('assets/images/hype.png', height: 80),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              streak >= 7 ? '🔥 $streak-Day Champion!' : streak >= 3 ? '💪 $streak-Day Streak!' : 'Start Your Streak!',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              streak >= 7
                                  ? 'Incredible dedication. You\'re building a lifestyle!'
                                  : streak >= 3
                                      ? 'Keep the momentum going. You\'re on a roll!'
                                      : 'Complete your first fast to start your streak.',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(7, (i) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    color: i < streak ? AppColors.forestGreen : AppColors.greenLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      i < streak ? Icons.check : Icons.circle,
                                      size: i < streak ? 12 : 6,
                                      color: i < streak ? AppColors.white : AppColors.border,
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Calorie trend (stub line chart)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Calorie Trend', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                          Text('This week', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(height: 100, child: const _CalorieTrendChart()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Habit tracker
                const Text('Healthy Habits',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.7,
                  children: const [
                    _HabitCard(emoji: '💧', label: 'Drink Water', days: 5, color: Colors.blue),
                    _HabitCard(emoji: '🥗', label: 'Eat Balanced', days: 3, color: AppColors.forestGreen),
                    _HabitCard(emoji: '🚶', label: 'Move Daily', days: 7, color: AppColors.orange),
                    _HabitCard(emoji: '😴', label: 'Sleep Well', days: 4, color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary + AI insight two-column
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.barChart2, size: 14, color: AppColors.forestGreen),
                                SizedBox(width: 4),
                                Text('Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _SummaryRow(label: 'Sessions', value: '${sessions.length}'),
                            _SummaryRow(label: 'Completed', value: '$completed'),
                            _SummaryRow(label: 'Streak', value: '$streak days'),
                            _SummaryRow(
                              label: 'Best',
                              value: sessions.isEmpty ? '0h' : '${sessions.map((s) => s.targetHours).reduce((a, b) => a > b ? a : b)}h',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.sparkles, size: 14, color: AppColors.orange),
                                SizedBox(width: 4),
                                Text('AI Insight', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              streak >= 7
                                  ? 'Outstanding! Your $streak-day streak shows real commitment to your health.'
                                  : streak >= 3
                                      ? 'Nice $streak-day run! Consistency is the #1 predictor of success.'
                                      : 'Start small — even a 12-hour fast counts. Every step matters!',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ],
    ),
  );
}

class _WeekBarChart extends StatelessWidget {
  final List<FastingSession> sessions;
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  const _WeekBarChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 24,
        barGroups: List.generate(sessions.length, (i) {
          final s = sessions[i];
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: s.completed ? s.targetHours.toDouble() : s.targetHours * 0.3,
              color: s.completed ? AppColors.forestGreen : AppColors.border,
              width: 22,
              borderRadius: BorderRadius.circular(6),
            ),
          ]);
        }),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 8,
          getDrawingHorizontalLine: (v) => const FlLine(color: AppColors.border, strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) => Text(
                _days[v.toInt() % 7],
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              reservedSize: 20,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class _CalorieTrendChart extends StatelessWidget {
  const _CalorieTrendChart();

  static const _spots = [
    FlSpot(0, 1420), FlSpot(1, 1680), FlSpot(2, 1350), FlSpot(3, 1800),
    FlSpot(4, 1550), FlSpot(5, 1720), FlSpot(6, 1480),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 1000,
        maxY: 2000,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (v) => const FlLine(color: AppColors.border, strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (v, m) => Text(
                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][v.toInt()],
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            color: AppColors.orange,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (s, v, b, i) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.orange,
                strokeColor: AppColors.white,
                strokeWidth: 1.5,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.orange.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int days;
  final Color color;
  const _HabitCard({required this.emoji, required this.label, required this.days, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 14)),
              ),
              const Spacer(),
              Text('$days/7', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: days / 7,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
