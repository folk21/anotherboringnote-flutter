import 'package:flutter/material.dart';

import '../notes/note.dart';

class EditorPage extends StatefulWidget {
  const EditorPage(
      {super.key,
      required this.note,
      required this.onSave,
      required this.onClose,
      required this.onDelete});

  final Note? note;
  final Future<void> Function(Note? original, String text) onSave;
  final VoidCallback onClose;
  final ValueChanged<Note> onDelete;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final TextEditingController _text;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.note?.content ?? '');
    _text.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _dirty =>
      normalizePlainText(_text.text) != (widget.note?.content ?? '');

  Future<void> _close() async {
    if (_saving) return;
    if (!_dirty) {
      widget.onClose();
      return;
    }
    final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Discard unsaved changes?'),
              content: const Text('Your changes have not been saved.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Keep editing')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Discard')),
              ],
            ));
    if (discard == true && mounted) widget.onClose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (widget.note != null && _text.text.trim().isEmpty) {
      final remove = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Remove empty note?'),
                content: const Text(
                    'Saving an empty existing note deletes it permanently.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Keep editing')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Remove')),
                ],
              ));
      if (remove == true && mounted) widget.onDelete(widget.note!);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(widget.note, _text.text);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _close();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: _close),
            title: Text(widget.note == null ? 'New note' : 'Edit note'),
            actions: [
              TextButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save')),
              const SizedBox(width: 12),
            ],
          ),
          body: Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _text,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 18, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Write anything…',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.all(22),
                ),
              ),
            ),
          )),
        ),
      );
}
