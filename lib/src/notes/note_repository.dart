import 'dart:convert';
import 'dart:math';

import '../storage/store.dart';
import 'note.dart';

class NoteRepository {
  NoteRepository(this.store, {int Function()? clock, String Function()? nextId})
      : _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch),
        _nextId = nextId ?? _generateId;

  final AppStore store;
  final int Function() _clock;
  final String Function() _nextId;

  Future<List<Note>> load() async {
    final index = await _readIndex();
    final metadata = index ?? <String, Map<String, dynamic>>{};
    final notes = <Note>[];
    final files = await store.listNotes();
    for (final file in files) {
      if (!file.name.endsWith('.txt')) continue;
      final id = file.name.substring(0, file.name.length - 4);
      if (!validNoteId.hasMatch(id)) continue;
      final row = metadata[id];
      final fallback = max(0, file.modifiedAt);
      final created = row?['createdAtEpochMillis'] as int? ?? fallback;
      final updated = row?['updatedAtEpochMillis'] as int? ?? fallback;
      notes.add(Note(
        id: id,
        content: normalizePlainText(file.content),
        createdAtEpochMillis: created,
        updatedAtEpochMillis: max(created, updated),
      ));
    }
    notes.sort((a, b) => a.id.compareTo(b.id));
    if (!_sameMetadata(index, notes)) await _writeIndex(notes);
    return sortNotes(notes);
  }

  Future<Note> create(String content) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('Note content must not be empty');
    }
    final existing = await load();
    final id = _nextId();
    if (!validNoteId.hasMatch(id) || existing.any((n) => n.id == id)) {
      throw StateError('Invalid or duplicate note ID');
    }
    final now = max(0, _clock());
    final note = Note(
        id: id,
        content: normalizePlainText(content),
        createdAtEpochMillis: now,
        updatedAtEpochMillis: now);
    await _mutate(
        existing, [...existing, note], () => store.writeNote(id, note.content));
    return note;
  }

  Future<Note> update(Note original, String content) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('Note content must not be empty');
    }
    final existing = await load();
    if (!existing.any((n) => n.id == original.id)) {
      throw StateError('Note is missing');
    }
    final note = original.copyWith(
        content: normalizePlainText(content),
        updatedAtEpochMillis: max(_clock(), original.updatedAtEpochMillis + 1));
    await _mutate(
        existing,
        existing.map((n) => n.id == note.id ? note : n).toList(),
        () => store.writeNote(note.id, note.content));
    return note;
  }

  Future<Note> duplicate(Note source) => create(source.content);

  Future<void> delete(String id) async {
    final existing = await load();
    await _mutate(existing, existing.where((n) => n.id != id).toList(),
        () => store.deleteNote(id));
  }

  Future<void> _mutate(List<Note> before, List<Note> after,
      Future<void> Function() mutation) async {
    await _writeIndex(after);
    try {
      await mutation();
    } catch (_) {
      try {
        await _writeIndex(before);
      } catch (_) {
        // Preserve the original storage error; subsequent load can reconcile the index.
      }
      rethrow;
    }
  }

  Future<Map<String, Map<String, dynamic>>?> _readIndex() async {
    final raw = await store.readIndex();
    if (raw == null) return null;
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final version = decoded['formatVersion'];
    if (version is int && version != 1) throw UnsupportedDataVersion(version);
    if (version != 1 || decoded['notes'] is! List) return null;
    final metadata = <String, Map<String, dynamic>>{};
    for (final row in decoded['notes'] as List) {
      if (row is! Map<String, dynamic>) return null;
      final id = row['id'];
      final created = row['createdAtEpochMillis'];
      final updated = row['updatedAtEpochMillis'];
      if (id is! String ||
          !validNoteId.hasMatch(id) ||
          metadata.containsKey(id) ||
          created is! int ||
          updated is! int ||
          created < 0 ||
          updated < created) {
        return null;
      }
      metadata[id] = row;
    }
    return metadata;
  }

  bool _sameMetadata(
      Map<String, Map<String, dynamic>>? index, List<Note> notes) {
    if (index == null || index.length != notes.length) return false;
    for (final note in notes) {
      final row = index[note.id];
      if (row == null ||
          row['createdAtEpochMillis'] != note.createdAtEpochMillis ||
          row['updatedAtEpochMillis'] != note.updatedAtEpochMillis) {
        return false;
      }
    }
    return true;
  }

  Future<void> _writeIndex(List<Note> notes) async {
    final entries = [...notes]..sort((a, b) => a.id.compareTo(b.id));
    const encoder = JsonEncoder.withIndent('  ');
    final payload = encoder.convert({
      'formatVersion': 1,
      'notes': entries
          .map((n) => {
                'id': n.id,
                'createdAtEpochMillis': n.createdAtEpochMillis,
                'updatedAtEpochMillis': n.updatedAtEpochMillis,
              })
          .toList(),
    });
    await store.writeIndex('$payload\n');
  }

  static String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final random = Random.secure().nextInt(0x7fffffff).toRadixString(36);
    return '$now-$random';
  }
}
