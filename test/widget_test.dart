import 'package:anotherboringnote_flutter/src/reader/reader_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial reader session uses configured default mode', () {
    const config = ReaderConfiguration(defaultMode: ReaderMode.private);
    expect(ReaderSession.open(config).fontSize, config.privateSize);
  });
}
