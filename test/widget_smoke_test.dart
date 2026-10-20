import 'package:anotherboringnote_flutter/src/ui/notes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty notes screen exposes new note and settings',
      (tester) async {
    var newPressed = false;
    await tester.pumpWidget(MaterialApp(
        home: NotesPage(
      notes: const [],
      onNew: () => newPressed = true,
      onOpen: (_) {},
      onEdit: (_) {},
      onDuplicate: (_) {},
      onDelete: (_) {},
      onSettings: () {},
      onHelp: () {},
    )));
    expect(find.text('No notes yet'), findsOneWidget);
    await tester.tap(find.text('Create note'));
    expect(newPressed, isTrue);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });
}
