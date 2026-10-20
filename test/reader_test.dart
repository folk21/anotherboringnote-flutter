import 'package:anotherboringnote_flutter/src/reader/reader_model.dart';
import 'package:anotherboringnote_flutter/src/reader/reader_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('four reader modes have KMP-compatible semantic sizes', () {
    const config = ReaderConfiguration();
    expect(config.sizeFor(ReaderMode.private), 14);
    expect(config.sizeFor(ReaderMode.normal), 24);
    expect(config.sizeFor(ReaderMode.large), 56);
    expect(config.sizeFor(ReaderMode.presentation), 56);
  });

  test('zoom reflows text but cannot overwrite semantic mode settings', () {
    const config = ReaderConfiguration();
    final session = ReaderSession.open(config).zoom(14);
    expect(session.fontSize, 38);
    expect(config.normalSize, 24);
    expect(session.reset(config).fontSize, 24);
    expect(session.zoom(-500).fontSize, 8);
    expect(session.zoom(500).fontSize, 240);
  });

  test('KMP-compatible properties round trip', () {
    const config = ReaderConfiguration();
    final encoded = ReaderPreferences.encode(config);
    expect(encoded, contains('formatVersion=1'));
    expect(encoded, contains('orientationPolicy=FOLLOW_SYSTEM'));
    final decoded = ReaderPreferences.decode(encoded);
    expect(decoded.normalSize, 24);
    expect(decoded.defaultMode, ReaderMode.normal);
  });

  test('malformed and future settings resolve to defaults on load', () {
    expect(ReaderPreferences.decode('broken').normalSize, 24);
    expect(ReaderPreferences.decode('formatVersion=4\n').normalSize, 24);
  });
}
