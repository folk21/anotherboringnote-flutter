class Note {
  const Note({
    required this.id,
    required this.content,
    required this.createdAtEpochMillis,
    required this.updatedAtEpochMillis,
  });

  final String id;
  final String content;
  final int createdAtEpochMillis;
  final int updatedAtEpochMillis;

  Note copyWith({String? content, int? updatedAtEpochMillis}) => Note(
        id: id,
        content: content ?? this.content,
        createdAtEpochMillis: createdAtEpochMillis,
        updatedAtEpochMillis: updatedAtEpochMillis ?? this.updatedAtEpochMillis,
      );
}

final RegExp validNoteId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$');

String normalizePlainText(String content) =>
    content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

List<Note> sortNotes(Iterable<Note> notes) {
  final sorted = notes.toList();
  sorted.sort((a, b) {
    final updated = b.updatedAtEpochMillis.compareTo(a.updatedAtEpochMillis);
    if (updated != 0) return updated;
    final created = b.createdAtEpochMillis.compareTo(a.createdAtEpochMillis);
    if (created != 0) return created;
    return a.id.compareTo(b.id);
  });
  return sorted;
}

class UnsupportedDataVersion implements Exception {
  UnsupportedDataVersion(this.version);
  final Object? version;

  @override
  String toString() => 'Unsupported data format version: $version';
}
