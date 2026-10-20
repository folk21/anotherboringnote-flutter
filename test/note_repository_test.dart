import 'dart:convert';
import 'dart:typed_data';

import 'package:anotherboringnote_flutter/src/notes/note.dart';
import 'package:anotherboringnote_flutter/src/notes/note_repository.dart';
import 'package:anotherboringnote_flutter/src/storage/store.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryStore implements AppStore {
  String? index;
  String? settings;
  final notes = <String, StoredTextFile>{};
  final fonts = <String, Uint8List>{};
  bool failNoteWrite = false;

  @override
  Future<String?> readIndex() async => index;
  @override
  Future<void> writeIndex(String content) async => index = content;
  @override
  Future<List<StoredTextFile>> listNotes() async => notes.values.toList();
  @override
  Future<void> writeNote(String id, String content) async {
    if (failNoteWrite) throw StateError('Disk is full');
    notes[id] = StoredTextFile('$id.txt', content, 123);
  }

  @override
  Future<void> deleteNote(String id) async {
    notes.remove(id);
  }

  @override
  Future<String?> readSettings() async => settings;
  @override
  Future<void> writeSettings(String content) async => settings = content;
  @override
  Future<void> writeFont(String name, Uint8List bytes) async =>
      fonts[name] = bytes;
  @override
  Future<Uint8List?> readFont(String name) async => fonts[name];
}

void main() {
  test('creates portable text, normalizes newline and writes v1 index',
      () async {
    final store = MemoryStore();
    final repository =
        NoteRepository(store, clock: () => 100, nextId: () => 'note1');
    final note = await repository.create('Hello\r\nworld');
    expect(note.content, 'Hello\nworld');
    expect(store.notes['note1']!.content, 'Hello\nworld');
    expect(jsonDecode(store.index!)['formatVersion'], 1);
    expect((await repository.load()).single.id, 'note1');
  });

  test('empty content must not mutate repository', () async {
    final store = MemoryStore();
    final repository = NoteRepository(store);
    await expectLater(repository.create('   '), throwsArgumentError);
    expect(store.index, isNull);
    expect(store.notes, isEmpty);
  });

  test('future index cannot be overwritten even when note text exists',
      () async {
    final store = MemoryStore();
    store.index = '{"formatVersion": 42, "notes": []}';
    store.notes['n.txt'] = const StoredTextFile('n.txt', 'hi', 123);
    final repository = NoteRepository(store);
    await expectLater(
        repository.load(), throwsA(isA<UnsupportedDataVersion>()));
    expect(store.index, contains('42'));
  });

  test('malformed index is rebuilt from recoverable note text', () async {
    final store = MemoryStore();
    store.index = 'not-json';
    store.notes['hello'] = const StoredTextFile('hello.txt', 'original', 120);
    final repository = NoteRepository(store);
    expect((await repository.load()).single.content, 'original');
    expect(jsonDecode(store.index!)['notes'][0]['id'], 'hello');
  });

  test('upsert failure restores index and leaves old content', () async {
    final store = MemoryStore();
    var counter = 0;
    final repository =
        NoteRepository(store, clock: () => 100, nextId: () => 'n${++counter}');
    final old = await repository.create('original');
    final prior = store.index;
    store.failNoteWrite = true;
    await expectLater(repository.update(old, 'changed'), throwsStateError);
    expect(store.index, prior);
    expect(store.notes['n1']!.content, 'original');
  });

  test('duplicate is independent and ordering uses last edit time', () async {
    final store = MemoryStore();
    var clock = 100;
    var id = 0;
    final repo =
        NoteRepository(store, clock: () => clock, nextId: () => 'n${++id}');
    final original = await repo.create('same');
    clock = 200;
    final duplicate = await repo.duplicate(original);
    expect(duplicate.id, isNot(original.id));
    expect(duplicate.content, 'same');
    expect((await repo.load()).first.id, duplicate.id);
  });
}
