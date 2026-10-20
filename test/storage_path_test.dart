import 'package:anotherboringnote_flutter/src/storage/store_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const support = '/sandbox/Data/Library/Application Support';

  test('macOS default data root is beneath application support', () {
    expect(
      macOsDataRoot(support),
      '$support/AnotherBoringNoteFlutter/abn-data',
    );
  });

  test('relative macOS override stays in application support', () {
    expect(
      macOsDataRoot(support, override: 'abn-flutter-smoke'),
      '$support/AnotherBoringNoteFlutter/abn-flutter-smoke',
    );
  });

  test('absolute macOS override is preserved for authorized paths', () {
    expect(
      macOsDataRoot(support, override: '/authorized/data'),
      '/authorized/data',
    );
  });

  test('relative macOS override cannot escape through parent components', () {
    expect(
      () => macOsDataRoot(support, override: '../outside'),
      throwsArgumentError,
    );
  });
}
