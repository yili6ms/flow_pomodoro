import '../models/session.dart';
import 'session_store.dart';

/// In-memory [SessionStore], primarily for unit tests and as a fallback
/// when persistence is intentionally disabled. Newest sessions are
/// returned first.
class InMemorySessionStore implements SessionStore {
  final List<FocusSession> _items = [];
  bool _initialized = false;

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  Future<List<FocusSession>> loadAll() async {
    _requireInit();
    final copy = List<FocusSession>.from(_items);
    copy.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return copy;
  }

  @override
  Future<void> insert(FocusSession session) async {
    _requireInit();
    _items.removeWhere((s) => s.id == session.id);
    _items.add(session);
  }

  @override
  Future<void> deleteAll() async {
    _requireInit();
    _items.clear();
  }

  @override
  Future<void> close() async {
    _initialized = false;
    _items.clear();
  }

  void _requireInit() {
    if (!_initialized) {
      throw StateError('InMemorySessionStore.init() not called');
    }
  }
}
