import 'package:drift/drift.dart';
import '../core/database.dart';
import '../models/enums.dart';

class FastingService {
  FastingService._();
  static final instance = FastingService._();

  Future<FastingSession> startSession(FastingProtocol protocol) async {
    await db.into(db.fastingSessions).insert(
      FastingSessionsCompanion.insert(
        startTime: DateTime.now().millisecondsSinceEpoch,
        targetHours: protocol.targetHours,
      ),
    );
    return (await getActiveSession())!;
  }

  Future<void> endSession(int id, {bool completed = true}) async {
    await (db.update(db.fastingSessions)..where((t) => t.id.equals(id))).write(
      FastingSessionsCompanion(
        endTime: Value(DateTime.now().millisecondsSinceEpoch),
        completed: Value(completed),
      ),
    );
  }

  Future<FastingSession?> getActiveSession() async {
    return (db.select(db.fastingSessions)
          ..where((t) => t.endTime.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<FastingSession>> getRecentSessions(int limit) async {
    return (db.select(db.fastingSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .get();
  }
}
