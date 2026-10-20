import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'store.dart';

Future<AppStore> createAppStore() async {
  final override = Platform.environment['ABN_DATA_DIR'];
  late final String root;
  if (Platform.isMacOS) {
    root = macOsDataRoot(
      (await getApplicationSupportDirectory()).path,
      override: override,
    );
  } else if (override != null && override.trim().isNotEmpty) {
    root = override;
  } else if (Platform.isLinux) {
    final base = Platform.environment['XDG_DATA_HOME'] ??
        '${Platform.environment['HOME']}/.local/share';
    root = '$base/anotherboringnote_flutter/abn-data';
  } else if (Platform.isWindows) {
    final base = Platform.environment['APPDATA'] ??
        (await getApplicationSupportDirectory()).path;
    root = '$base/AnotherBoringNoteFlutter/abn-data';
  } else {
    root = '${(await getApplicationSupportDirectory()).path}/abn-data';
  }
  return IoAppStore(Directory(root));
}

String macOsDataRoot(String applicationSupportPath, {String? override}) {
  final requested = override?.trim();
  const appDirectory = 'AnotherBoringNoteFlutter';
  if (requested == null || requested.isEmpty) {
    return '$applicationSupportPath/$appDirectory/abn-data';
  }
  if (requested.startsWith('/')) {
    return requested;
  }
  if (requested.split('/').contains('..')) {
    throw ArgumentError.value(
      requested,
      'override',
      'Relative ABN_DATA_DIR must not contain parent directory components',
    );
  }
  return '$applicationSupportPath/$appDirectory/$requested';
}

class IoAppStore implements AppStore {
  IoAppStore(this.root);
  final Directory root;

  File _index() => File('${root.path}/index.json');
  File _note(String id) => File('${root.path}/notes/$id.txt');
  File _settings() => File('${root.path}/settings/reader.properties');
  File _font(String name) => File('${root.path}/fonts/$name');

  Future<void> _publish(File target, List<int> contents) async {
    await target.parent.create(recursive: true);
    final temp = File('${target.path}.tmp');
    try {
      await temp.writeAsBytes(contents, flush: true);
      if (await target.exists() && Platform.isWindows) {
        await target.delete();
      }
      await temp.rename(target.path);
    } finally {
      if (await temp.exists()) await temp.delete();
    }
  }

  Future<String?> _read(File file) async =>
      await file.exists() ? file.readAsString() : null;

  @override
  Future<String?> readIndex() => _read(_index());

  @override
  Future<void> writeIndex(String content) =>
      _publish(_index(), utf8Bytes(content));

  @override
  Future<List<StoredTextFile>> listNotes() async {
    final directory = Directory('${root.path}/notes');
    if (!await directory.exists()) return [];
    final result = <StoredTextFile>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.txt')) continue;
      final name = entity.uri.pathSegments.last;
      final metadata = await entity.stat();
      result.add(StoredTextFile(
        name,
        await entity.readAsString(),
        metadata.modified.millisecondsSinceEpoch,
      ));
    }
    return result;
  }

  @override
  Future<void> writeNote(String id, String content) =>
      _publish(_note(id), utf8Bytes(content));

  @override
  Future<void> deleteNote(String id) async {
    final file = _note(id);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<String?> readSettings() => _read(_settings());

  @override
  Future<void> writeSettings(String content) =>
      _publish(_settings(), utf8Bytes(content));

  @override
  Future<void> writeFont(String name, Uint8List bytes) =>
      _publish(_font(name), bytes);

  @override
  Future<Uint8List?> readFont(String name) async {
    final file = _font(name);
    return await file.exists() ? file.readAsBytes() : null;
  }
}

List<int> utf8Bytes(String value) => utf8.encode(value);
