import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lyricpro_app/core/config/app_env.dart';
import 'package:lyricpro_app/core/supabase/supabase_client_provider.dart';
import 'package:lyricpro_app/data/local/database.dart';
import 'package:lyricpro_app/data/repositories/library_repository.dart';

enum SyncStatus { synced, pending, offline }

enum SyncOperation { create, update, delete }

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final client = ref.watch(supabaseProvider);
  final controller = SyncController(db: db, client: client);
  controller.scheduleBackgroundSync();
  ref.onDispose(controller.dispose);
  return controller;
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.syncQueueEntries)
        ..where((tbl) => tbl.isProcessing.equals(false)))
      .watch()
      .map((rows) => rows.length);
});

class SyncController extends StateNotifier<SyncState> {
  SyncController({required AppDatabase db, required SupabaseClient? client})
      : _db = db,
        _client = client,
        super(const SyncState.initial());

  final AppDatabase _db;
  final SupabaseClient? _client;
  Timer? _timer;

  Future<void> enqueueMutation({
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    String? payload,
  }) async {
    await _db.into(_db.syncQueueEntries).insert(
          SyncQueueEntriesCompanion.insert(
            id: _generateQueueId(entityType, entityId),
            entityType: entityType,
            entityId: entityId,
            operation: operation.name,
            payload: Value(payload),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> processQueue() async {
    if (!AppEnv.hasSupabaseCredentials || _client == null) {
      return;
    }
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true, lastError: null);

    final entries = await (_db.select(_db.syncQueueEntries)
          ..where((tbl) => tbl.isProcessing.equals(false)))
        .get();

    if (entries.isEmpty) {
      state = state.copyWith(isSyncing: false, lastSync: DateTime.now());
      return;
    }

    try {
      for (final entry in entries) {
        await (_db.update(_db.syncQueueEntries)
              ..where((tbl) => tbl.id.equals(entry.id)))
            .write(const SyncQueueEntriesCompanion(isProcessing: Value(true)));

        await _simulateNetworkDelay();

        await (_db.delete(_db.syncQueueEntries)
              ..where((tbl) => tbl.id.equals(entry.id)))
            .go();
      }

      state = state.copyWith(
        isSyncing: false,
        lastSync: DateTime.now(),
        lastError: null,
      );
    } catch (error, stack) {
      state = state.copyWith(
        isSyncing: false,
        lastError: error.toString(),
      );
      Zone.current.handleUncaughtError(error, stack);
    }
  }

  void scheduleBackgroundSync() {
    _timer?.cancel();
    if (!AppEnv.hasSupabaseCredentials || _client == null) {
      return;
    }
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => processQueue());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  String _generateQueueId(String type, String id) => '$type::$id';
}

class SyncState {
  const SyncState({
    required this.isSyncing,
    required this.lastSync,
    required this.lastError,
  });

  const SyncState.initial()
      : isSyncing = false,
        lastSync = null,
        lastError = null;

  final bool isSyncing;
  final DateTime? lastSync;
  final String? lastError;

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSync,
    String? lastError,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      lastError: lastError,
    );
  }
}
