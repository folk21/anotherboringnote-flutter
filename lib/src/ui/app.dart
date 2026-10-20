import 'package:flutter/material.dart';

import '../notes/note.dart';
import '../notes/note_repository.dart';
import '../reader/reader_model.dart';
import '../reader/reader_preferences.dart';
import '../storage/platform_store.dart';
import '../storage/store.dart';
import 'editor_page.dart';
import 'help_page.dart';
import 'notes_page.dart';
import 'reader_page.dart';
import 'settings_page.dart';

enum AppScreen { notes, editor, reader, settings, help }

class AnotherBoringNoteApp extends StatefulWidget {
  const AnotherBoringNoteApp({super.key});

  @override
  State<AnotherBoringNoteApp> createState() => _AnotherBoringNoteAppState();
}

class _AnotherBoringNoteAppState extends State<AnotherBoringNoteApp> {
  AppStore? _store;
  NoteRepository? _notesRepository;
  List<Note> _notes = [];
  ReaderConfiguration _config = const ReaderConfiguration();
  AppScreen _screen = AppScreen.notes;
  AppScreen _returnTo = AppScreen.notes;
  Note? _note;
  ReaderSession? _readerSession;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final store = await createAppStore();
      final notes = NoteRepository(store);
      final loaded = await notes.load();
      final config = await ReaderPreferences(store).load();
      if (!mounted) return;
      setState(() {
        _store = store;
        _notesRepository = notes;
        _notes = loaded;
        _config = config;
        _loading = false;
      });
    } catch (failure) {
      if (mounted) {
        setState(() {
          _error = '$failure';
          _loading = false;
        });
      }
    }
  }

  Future<void> _reload() async {
    final notes = await _notesRepository!.load();
    if (mounted) setState(() => _notes = notes);
  }

  Future<void> _execute(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operation failed: $failure')),
        );
      }
      rethrow;
    }
  }

  void _read(Note note) => setState(() {
        _note = note;
        _readerSession = ReaderSession.open(_config);
        _screen = AppScreen.reader;
      });

  void _edit(Note? note) => setState(() {
        _note = note;
        _screen = AppScreen.editor;
      });

  void _openAuxiliary(AppScreen target) => setState(() {
        _returnTo = _screen;
        _screen = target;
      });

  void _returnFromAuxiliary() => setState(() => _screen = _returnTo);

  Future<void> _saveDraft(Note? original, String text) async {
    await _execute(() async {
      if (original == null) {
        if (text.trim().isNotEmpty) await _notesRepository!.create(text);
      } else if (text.trim().isNotEmpty &&
          normalizePlainText(text) != original.content) {
        await _notesRepository!.update(original, text);
      }
      await _reload();
    });
    if (mounted) {
      setState(() {
        _screen = AppScreen.notes;
        _note = null;
      });
    }
  }

  Future<void> _delete(Note note) async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text(
            'This permanently deletes the note. There is no Trash or undo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (decision != true) return;
    try {
      await _execute(() async {
        await _notesRepository!.delete(note.id);
        await _reload();
      });
      if (mounted) {
        setState(() {
          _screen = AppScreen.notes;
          _note = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _duplicate(Note note) async {
    try {
      await _execute(() async {
        await _notesRepository!.duplicate(note);
        await _reload();
      });
    } catch (_) {}
  }

  Future<void> _saveSettings(ReaderConfiguration config) async {
    await ReaderPreferences(_store!).save(config);
    if (mounted) {
      setState(() {
        _config = config;
        if (_returnTo == AppScreen.reader && _readerSession != null) {
          _readerSession = _readerSession!.select(_readerSession!.mode, config);
        }
        _screen = _returnTo;
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Another Boring Note',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF405D77)),
          scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        ),
        home: _buildPage(),
      );

  Widget _buildPage() {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
          body: Center(
              child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Unable to load local data.'),
          const SizedBox(height: 12),
          SelectableText(_error!),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _initialize();
              },
              child: const Text('Retry')),
        ]),
      )));
    }
    return switch (_screen) {
      AppScreen.notes => NotesPage(
          notes: _notes,
          onNew: () => _edit(null),
          onOpen: _read,
          onEdit: _edit,
          onDuplicate: _duplicate,
          onDelete: _delete,
          onSettings: () => _openAuxiliary(AppScreen.settings),
          onHelp: () => _openAuxiliary(AppScreen.help)),
      AppScreen.editor => EditorPage(
          key: ValueKey(_note?.id ?? 'new'),
          note: _note,
          onSave: _saveDraft,
          onDelete: _delete,
          onClose: () => setState(() => _screen = AppScreen.notes)),
      AppScreen.reader => ReaderPage(
          note: _note!,
          config: _config,
          store: _store!,
          session: _readerSession ?? ReaderSession.open(_config),
          onSession: (updated) => setState(() => _readerSession = updated),
          onBack: () => setState(() => _screen = AppScreen.notes),
          onEdit: () => _edit(_note),
          onDelete: () => _delete(_note!),
          onSettings: () => _openAuxiliary(AppScreen.settings),
          onHelp: () => _openAuxiliary(AppScreen.help)),
      AppScreen.settings => SettingsPage(
          config: _config,
          store: _store!,
          showOrientation: true,
          onSave: _saveSettings,
          onBack: _returnFromAuxiliary),
      AppScreen.help => HelpPage(onBack: _returnFromAuxiliary),
    };
  }
}
