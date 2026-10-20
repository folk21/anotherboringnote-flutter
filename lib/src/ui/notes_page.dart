import 'package:flutter/material.dart';

import '../notes/note.dart';

class NotesPage extends StatelessWidget {
  const NotesPage(
      {super.key,
      required this.notes,
      required this.onNew,
      required this.onOpen,
      required this.onEdit,
      required this.onDuplicate,
      required this.onDelete,
      required this.onSettings,
      required this.onHelp});

  final List<Note> notes;
  final VoidCallback onNew;
  final ValueChanged<Note> onOpen;
  final ValueChanged<Note?> onEdit;
  final ValueChanged<Note> onDuplicate;
  final ValueChanged<Note> onDelete;
  final VoidCallback onSettings;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Another Boring Note'),
          actions: [
            IconButton(
                tooltip: 'Settings',
                onPressed: onSettings,
                icon: const Icon(Icons.tune_outlined)),
            IconButton(
                tooltip: 'Help',
                onPressed: onHelp,
                icon: const Icon(Icons.help_outline)),
            const SizedBox(width: 12),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: onNew,
            icon: const Icon(Icons.add),
            label: const Text('New note')),
        body: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: notes.isEmpty
              ? Center(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 60, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    const Text('No notes yet', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    const Text('Create a plain-text note to get started.'),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                        onPressed: onNew,
                        icon: const Icon(Icons.add),
                        label: const Text('Create note')),
                  ],
                ))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final preview =
                        note.content.trim().isEmpty ? '(empty)' : note.content;
                    return Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        title: Text(preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, height: 1.4)),
                        subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                                _formatTimestamp(note.updatedAtEpochMillis),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant))),
                        onTap: () => onOpen(note),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Note actions',
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                onEdit(note);
                              case 'copy':
                                onDuplicate(note);
                              case 'delete':
                                onDelete(note);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'copy', child: Text('Duplicate')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete…')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        )),
      );

  String _formatTimestamp(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
