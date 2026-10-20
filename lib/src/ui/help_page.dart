import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Help'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
                tooltip: 'Back')),
        body: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(padding: const EdgeInsets.all(24), children: const [
            Text('Another Boring Note',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
            SizedBox(height: 18),
            Text(
                'Plain text, kept simple. Notes have no separate title. Tap a note to read it; use its menu to edit, duplicate or delete.'),
            SizedBox(height: 18),
            Text('Reader modes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
                'Private, Normal, Large and Presentation set typography rather than scaling an image. Presentation reuses the Large size and requests landscape on mobile. Private is not a security feature.'),
            SizedBox(height: 18),
            Text('Zoom and navigation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
                'Use + and − controls, touch pinch, or Ctrl/Cmd with +, − and 0 in the reader. Use Ctrl/Cmd with the mouse wheel on desktop. Escape returns to the note list.'),
            SizedBox(height: 18),
            Text('Saving notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
                'The editor saves when you select Save. Leaving with changes asks for confirmation. Saving an empty new note creates nothing; emptying an existing note requires a confirmation to delete.'),
            SizedBox(height: 18),
            Text('Local data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
                'On desktop/mobile native builds, note content is stored in UTF-8 .txt files and index.json. Web stores a browser-local equivalent, not exportable .txt files. Nothing is synced.'),
          ]),
        )),
      );
}
