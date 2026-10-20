import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import 'store.dart';

Future<AppStore> createAppStore() async =>
    WebAppStore(await SharedPreferences.getInstance());

class WebAppStore implements AppStore {
  WebAppStore(this.prefs);
  final SharedPreferences prefs;
  static const String prefix = 'abn_flutter_';

  @override
  Future<String?> readIndex() async => prefs.getString('${prefix}index');

  @override
  Future<void> writeIndex(String content) async {
    await prefs.setString('${prefix}index', content);
  }

  @override
  Future<List<StoredTextFile>> listNotes() async {
    final result = <StoredTextFile>[];
    for (final key
        in prefs.getKeys().where((k) => k.startsWith('${prefix}note_'))) {
      final id = key.substring('${prefix}note_'.length);
      final content = prefs.getString(key);
      if (content != null) {
        result.add(StoredTextFile(
            '$id.txt',
            content,
            prefs.getInt('${prefix}modified_$id') ??
                DateTime.now().millisecondsSinceEpoch));
      }
    }
    return result;
  }

  @override
  Future<void> writeNote(String id, String content) async {
    await prefs.setString('${prefix}note_$id', content);
    await prefs.setInt(
        '${prefix}modified_$id', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> deleteNote(String id) async {
    await prefs.remove('${prefix}note_$id');
    await prefs.remove('${prefix}modified_$id');
  }

  @override
  Future<String?> readSettings() async => prefs.getString('${prefix}settings');

  @override
  Future<void> writeSettings(String content) async {
    await prefs.setString('${prefix}settings', content);
  }

  @override
  Future<void> writeFont(String name, Uint8List bytes) async {
    await prefs.setString('${prefix}font_$name', base64Encode(bytes));
  }

  @override
  Future<Uint8List?> readFont(String name) async {
    final value = prefs.getString('${prefix}font_$name');
    return value == null ? null : base64Decode(value);
  }
}
