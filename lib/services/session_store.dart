import '../models/session.dart';

/// Abstract storage layer for [FocusSession]s. Lets the [StatsProvider]
/// stay agnostic of where sessions are persisted (SQLite in production,
/// in-memory in tests, etc.).
///
/// Implementations are expected to be safe to call after [init] completes
/// and before [close]. Methods may throw on programmer errors but should
/// not crash on corrupt rows — they should skip them and log.
abstract class SessionStore {
  /// Open / migrate underlying storage. Must be called before any other
  /// method. Safe to call multiple times.
  Future<void> init();

  /// Returns all sessions, ordered newest-first by `startedAt`.
  Future<List<FocusSession>> loadAll();

  /// Persists a new session. Implementations should upsert by [id] so
  /// duplicate writes are idempotent.
  Future<void> insert(FocusSession session);

  /// Deletes every session. Used for tests and the "reset stats" feature.
  Future<void> deleteAll();

  /// Releases resources. After this call, no other methods may be called.
  Future<void> close();
}
