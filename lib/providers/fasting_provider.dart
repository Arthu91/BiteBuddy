import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database.dart';
import '../models/enums.dart';
import '../services/fasting_service.dart';

// ── Active session state ───────────────────────────────────────────────────

class FastingState {
  final FastingSession? session;
  final int elapsedSeconds;

  const FastingState({this.session, this.elapsedSeconds = 0});

  bool get isActive => session != null && session!.endTime == null;

  double get progress {
    if (!isActive) return 0;
    final target = (session!.targetHours * 3600).toDouble();
    return (elapsedSeconds / target).clamp(0.0, 1.0);
  }

  bool get isComplete => isActive && elapsedSeconds >= session!.targetHours * 3600;

  FastingProtocol get protocol =>
      FastingProtocolExt.fromHours(session?.targetHours ?? 16);

  String get elapsedFormatted => _fmt(elapsedSeconds);
  String get remainingFormatted {
    if (!isActive) return '--:--:--';
    final rem = (session!.targetHours * 3600 - elapsedSeconds).clamp(0, double.infinity).toInt();
    return _fmt(rem);
  }

  static String _fmt(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class FastingNotifier extends Notifier<FastingState> {
  Timer? _timer;

  @override
  FastingState build() {
    ref.onDispose(() => _timer?.cancel());
    _load();
    return const FastingState();
  }

  Future<void> _load() async {
    final session = await FastingService.instance.getActiveSession();
    if (session != null) {
      _startTicking(session);
    }
  }

  void _startTicking(FastingSession session) {
    _timer?.cancel();
    final elapsed = (DateTime.now().millisecondsSinceEpoch - session.startTime) ~/ 1000;
    state = FastingState(session: session, elapsedSeconds: elapsed);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = FastingState(
        session: state.session,
        elapsedSeconds: state.elapsedSeconds + 1,
      );
    });
  }

  Future<void> startFast(FastingProtocol protocol) async {
    final session = await FastingService.instance.startSession(protocol);
    _startTicking(session);
  }

  Future<void> endFast({bool completed = true}) async {
    if (state.session == null) return;
    await FastingService.instance.endSession(state.session!.id, completed: completed);
    _timer?.cancel();
    state = const FastingState();
  }
}

final fastingProvider = NotifierProvider<FastingNotifier, FastingState>(FastingNotifier.new);
