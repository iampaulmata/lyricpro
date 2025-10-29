import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricpro_app/data/local/database.dart';
import '../../data/setlist_repository.dart';

final _dbProvider = Provider<AppDatabase>((ref) {
  // Lazily create the database. In real app we may want a singleton in main.dart
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final setListRepoProvider = Provider<SetListRepository>((ref) {
  final db = ref.read(_dbProvider);
  return SetListRepository(db);
});

class SetListScreen extends ConsumerWidget {
  const SetListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(setListRepoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Set Lists')),
      body: StreamBuilder<List<SetList>>(
        stream: repo.watchSetLists(),
        builder: (context, snapshot) {
          final lists = snapshot.data ?? [];
          if (lists.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('No set lists yet'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await repo.createSet('New Set ${DateTime.now().millisecondsSinceEpoch}');
                  },
                  child: const Text('Create sample set'),
                )
              ]),
            );
          }

          return ReorderableListView.builder(
            itemCount: lists.length,
            onReorder: (oldIndex, newIndex) async {
              // simple reorder at list level: adjust positions by rewriting set items positions is left as future work
              // For now, reorder SetLists by creating a no-op to trigger UI update
            },
            itemBuilder: (context, index) {
              final s = lists[index];
              return ListTile(
                key: ValueKey(s.id),
                title: Text(s.name),
                subtitle: Text('Created ${s.createdAt}'),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
