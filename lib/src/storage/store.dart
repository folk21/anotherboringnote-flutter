import 'dart:typed_data';

class StoredTextFile {
  const StoredTextFile(this.name, this.content, this.modifiedAt);
  final String name;
  final String content;
  final int modifiedAt;
}

abstract class AppStore {
  Future<String?> readIndex();
  Future<void> writeIndex(String content);
  Future<List<StoredTextFile>> listNotes();
  Future<void> writeNote(String id, String content);
  Future<void> deleteNote(String id);
  Future<String?> readSettings();
  Future<void> writeSettings(String content);
  Future<void> writeFont(String name, Uint8List bytes);
  Future<Uint8List?> readFont(String name);
}
