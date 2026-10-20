import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../reader/reader_model.dart';
import '../reader/reader_preferences.dart';
import '../storage/store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key,
      required this.config,
      required this.store,
      required this.onSave,
      required this.onBack,
      required this.showOrientation});

  final ReaderConfiguration config;
  final AppStore store;
  final Future<void> Function(ReaderConfiguration) onSave;
  final VoidCallback onBack;
  final bool showOrientation;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ReaderConfiguration _draft;
  late final TextEditingController _private;
  late final TextEditingController _normal;
  late final TextEditingController _large;
  late final TextEditingController _foreground;
  late final TextEditingController _background;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _draft = widget.config;
    _private = TextEditingController(text: _draft.privateSize.toString());
    _normal = TextEditingController(text: _draft.normalSize.toString());
    _large = TextEditingController(text: _draft.largeSize.toString());
    _foreground = TextEditingController(text: toHex(_draft.colors.$1));
    _background = TextEditingController(text: toHex(_draft.colors.$2));
  }

  @override
  void dispose() {
    _private.dispose();
    _normal.dispose();
    _large.dispose();
    _foreground.dispose();
    _background.dispose();
    super.dispose();
  }

  Future<void> _importFont() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['ttf', 'otf'],
          withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.length < 4 || bytes.length > 20000000) {
        throw FormatException(
            'Font must be a readable TTF/OTF file (max 20 MB).');
      }
      final signature = bytes.sublist(0, 4);
      final valid = (signature[0] == 0 &&
              signature[1] == 1 &&
              signature[2] == 0 &&
              signature[3] == 0) ||
          String.fromCharCodes(signature) == 'OTTO' ||
          String.fromCharCodes(signature) == 'true';
      if (!valid) throw const FormatException('Unsupported font signature.');
      final extension =
          file.name.toLowerCase().endsWith('.otf') ? 'otf' : 'ttf';
      final name = 'custom-${DateTime.now().microsecondsSinceEpoch}.$extension';
      await widget.store.writeFont(name, bytes);
      if (mounted) {
        setState(() {
          _draft = _draft.copyWith(
              fontPreset: ReaderFontPreset.custom, customFontFile: name);
          _error = null;
        });
      }
    } catch (failure) {
      if (mounted) setState(() => _error = 'Font import failed: $failure');
    }
  }

  Future<void> _save() async {
    final p = double.tryParse(_private.text.trim());
    final n = double.tryParse(_normal.text.trim());
    final l = double.tryParse(_large.text.trim());
    if (p == null || n == null || l == null) {
      setState(() => _error = 'Enter valid numeric font sizes.');
      return;
    }
    final fg = parseHexColor(_foreground.text.trim());
    final bg = parseHexColor(_background.text.trim());
    if (_draft.colorPreset == ReaderColorPreset.custom &&
        (fg == null || bg == null)) {
      setState(() => _error = 'Custom colors must use #RRGGBB.');
      return;
    }
    final update = _draft.copyWith(
        privateSize: p,
        normalSize: n,
        largeSize: l,
        foreground: fg,
        background: bg);
    if (!update.sizesValid) {
      setState(
          () => _error = 'Sizes must satisfy 0 < Private < Normal < Large.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(update);
    } catch (failure) {
      if (mounted) setState(() => _error = 'Unable to save settings: $failure');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _sizeInput(String label, TextEditingController controller) => SizedBox(
        width: 140,
        child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: '$label (sp)', border: const OutlineInputBorder())),
      );

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Reader settings'),
            leading: IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back'),
            actions: [
              TextButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save')),
              const SizedBox(width: 16)
            ]),
        body: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            _section('Reader sizes'),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _sizeInput('Private', _private),
              _sizeInput('Normal', _normal),
              _sizeInput('Large', _large),
            ]),
            _section('Default opening mode'),
            DropdownButtonFormField<ReaderMode>(
                initialValue: _draft.defaultMode,
                items: ReaderMode.values
                    .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(
                        () => _draft = _draft.copyWith(defaultMode: value));
                  }
                },
                decoration:
                    const InputDecoration(border: OutlineInputBorder())),
            if (widget.showOrientation) ...[
              _section('Mobile orientation'),
              DropdownButtonFormField<ReaderOrientationPolicy>(
                  initialValue: _draft.orientation,
                  items: const [
                    DropdownMenuItem(
                        value: ReaderOrientationPolicy.followSystem,
                        child: Text('Follow system')),
                    DropdownMenuItem(
                        value: ReaderOrientationPolicy.portrait,
                        child: Text('Portrait')),
                    DropdownMenuItem(
                        value: ReaderOrientationPolicy.landscape,
                        child: Text('Landscape')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(
                          () => _draft = _draft.copyWith(orientation: value));
                    }
                  },
                  decoration:
                      const InputDecoration(border: OutlineInputBorder())),
            ],
            _section('Colors'),
            DropdownButtonFormField<ReaderColorPreset>(
                initialValue: _draft.colorPreset,
                items: ReaderColorPreset.values
                    .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(switch (value) {
                          ReaderColorPreset.highContrast => 'High contrast',
                          _ => value.name[0].toUpperCase() +
                              value.name.substring(1),
                        })))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(
                        () => _draft = _draft.copyWith(colorPreset: value));
                  }
                },
                decoration:
                    const InputDecoration(border: OutlineInputBorder())),
            if (_draft.colorPreset == ReaderColorPreset.custom) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _foreground,
                        decoration: const InputDecoration(
                            labelText: 'Foreground #RRGGBB',
                            border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: _background,
                        decoration: const InputDecoration(
                            labelText: 'Background #RRGGBB',
                            border: OutlineInputBorder()))),
              ]),
            ],
            _section('Font'),
            DropdownButtonFormField<ReaderFontPreset>(
                initialValue: _draft.fontPreset,
                items: ReaderFontPreset.values
                    .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(switch (value) {
                          ReaderFontPreset.sansSerif => 'Sans serif',
                          ReaderFontPreset.monospace => 'Monospace',
                          _ => value.name[0].toUpperCase() +
                              value.name.substring(1),
                        })))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _draft = _draft.copyWith(fontPreset: value));
                  }
                },
                decoration:
                    const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                    onPressed: _importFont,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Import TTF / OTF'))),
            if (_draft.fontPreset == ReaderFontPreset.custom)
              Text(_draft.customFontFile ?? 'Import a font before saving.',
                  style: Theme.of(context).textTheme.bodySmall),
            if (_error != null)
              Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))),
            const SizedBox(height: 24),
            Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save settings'))),
          ]),
        )),
      );
}
