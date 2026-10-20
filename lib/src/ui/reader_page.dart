import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../notes/note.dart';
import '../reader/reader_model.dart';
import '../storage/store.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage(
      {super.key,
      required this.note,
      required this.config,
      required this.store,
      required this.session,
      required this.onSession,
      required this.onBack,
      required this.onEdit,
      required this.onDelete,
      required this.onSettings,
      required this.onHelp});

  final Note note;
  final ReaderConfiguration config;
  final AppStore store;
  final ReaderSession session;
  final ValueChanged<ReaderSession> onSession;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSettings;
  final VoidCallback onHelp;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final FocusNode _focus = FocusNode();
  double? _pinchBaseline;
  double _pinchStartSize = 24;
  DeviceOrientation? _temporaryOrientation;
  bool _customFontLoaded = false;

  bool get _mobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _applyOrientation();
    _loadFont();
  }

  @override
  void didUpdateWidget(covariant ReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.mode != widget.session.mode ||
        oldWidget.config.orientation != widget.config.orientation) {
      _applyOrientation();
    }
    if (oldWidget.config.customFontFile != widget.config.customFontFile) {
      _customFontLoaded = false;
      _loadFont();
    }
  }

  Future<void> _loadFont() async {
    final name = widget.config.customFontFile;
    if (widget.config.fontPreset != ReaderFontPreset.custom || name == null) {
      return;
    }
    try {
      final bytes = await widget.store.readFont(name);
      if (bytes == null) return;
      final loader = FontLoader('abn_custom')
        ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      await loader.load();
      if (mounted) setState(() => _customFontLoaded = true);
    } catch (_) {
      // A missing or invalid imported font falls back to the system sans-serif font.
    }
  }

  void _applyOrientation() {
    if (!_mobile) return;
    final orientation = switch (widget.session.mode) {
      ReaderMode.presentation => ReaderOrientationPolicy.landscape,
      _ => widget.config.orientation,
    };
    final preferences = widget.session.mode != ReaderMode.presentation &&
            _temporaryOrientation != null
        ? [_temporaryOrientation!]
        : switch (orientation) {
            ReaderOrientationPolicy.followSystem => <DeviceOrientation>[],
            ReaderOrientationPolicy.portrait => [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown
              ],
            ReaderOrientationPolicy.landscape => [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight
              ],
          };
    SystemChrome.setPreferredOrientations(preferences);
  }

  @override
  void dispose() {
    if (_mobile) SystemChrome.setPreferredOrientations([]);
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onBack();
      return KeyEventResult.handled;
    }
    final modifier = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!modifier) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.add ||
        key == LogicalKeyboardKey.numpadAdd) {
      widget.onSession(widget.session.zoom(4));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract) {
      widget.onSession(widget.session.zoom(-4));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
      widget.onSession(widget.session.reset(widget.config));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _rotate() {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final current = _temporaryOrientation;
    final landscape = current == null
        ? !isLandscape
        : (current == DeviceOrientation.portraitUp ||
            current == DeviceOrientation.portraitDown);
    setState(() => _temporaryOrientation = landscape
        ? DeviceOrientation.landscapeLeft
        : DeviceOrientation.portraitUp);
    _applyOrientation();
  }

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = widget.config.colors;
    final family = widget.config.fontPreset == ReaderFontPreset.custom &&
            !_customFontLoaded
        ? null
        : widget.config.fontFamily;
    final desktop = MediaQuery.sizeOf(context).width >= 750;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
        leading: IconButton(
            onPressed: widget.onBack,
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back)),
        actions: [
          PopupMenuButton<ReaderMode>(
            tooltip: 'Reader mode',
            initialValue: widget.session.mode,
            onSelected: (mode) =>
                widget.onSession(widget.session.select(mode, widget.config)),
            itemBuilder: (_) => ReaderMode.values
                .map((mode) =>
                    PopupMenuItem(value: mode, child: Text(mode.label)))
                .toList(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.session.mode.label),
                  const Icon(Icons.arrow_drop_down),
                ]))),
          ),
          if (desktop) ...[
            IconButton(
                tooltip: 'Zoom out',
                onPressed: () => widget.onSession(widget.session.zoom(-4)),
                icon: const Icon(Icons.remove)),
            IconButton(
                tooltip: 'Zoom in',
                onPressed: () => widget.onSession(widget.session.zoom(4)),
                icon: const Icon(Icons.add)),
            IconButton(
                tooltip: 'Reset zoom',
                onPressed: () =>
                    widget.onSession(widget.session.reset(widget.config)),
                icon: const Icon(Icons.restart_alt)),
          ],
          if (_mobile && widget.session.mode != ReaderMode.presentation)
            IconButton(
                tooltip: 'Rotate',
                onPressed: _rotate,
                icon: const Icon(Icons.screen_rotation_outlined)),
          PopupMenuButton<String>(
              tooltip: 'Reader actions',
              onSelected: (key) {
                switch (key) {
                  case 'edit':
                    widget.onEdit();
                  case 'delete':
                    widget.onDelete();
                  case 'settings':
                    widget.onSettings();
                  case 'help':
                    widget.onHelp();
                }
              },
              itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete…')),
                    PopupMenuItem(value: 'settings', child: Text('Settings')),
                    PopupMenuItem(value: 'help', child: Text('Help')),
                  ]),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : SafeArea(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => widget.onSession(widget.session.zoom(-4)),
                    child: const Text('−')),
                Text('${widget.session.fontSize.toStringAsFixed(0)} sp'),
                TextButton(
                    onPressed: () => widget.onSession(widget.session.zoom(4)),
                    child: const Text('+')),
                TextButton(
                    onPressed: () =>
                        widget.onSession(widget.session.reset(widget.config)),
                    child: const Text('Reset')),
              ],
            )),
      body: Focus(
        autofocus: true,
        focusNode: _focus,
        onKeyEvent: _onKey,
        child: Listener(
          onPointerSignal: (signal) {
            if (signal is PointerScrollEvent &&
                (HardwareKeyboard.instance.isControlPressed ||
                    HardwareKeyboard.instance.isMetaPressed)) {
              widget.onSession(widget.session
                  .zoom((-signal.scrollDelta.dy * 4).clamp(-12.0, 12.0)));
            }
          },
          child: GestureDetector(
            onScaleStart: (_) {
              _pinchBaseline = widget.session.fontSize;
              _pinchStartSize = widget.session.fontSize;
            },
            onScaleUpdate: (details) {
              if (details.pointerCount < 2 || _pinchBaseline == null) return;
              final target =
                  (_pinchStartSize * details.scale).clamp(8.0, 240.0);
              widget.onSession(ReaderSession(widget.session.mode, target));
            },
            onScaleEnd: (_) => _pinchBaseline = null,
            child: ColoredBox(
              color: background,
              child: SelectionArea(
                  child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
                child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.note.content.isEmpty ? ' ' : widget.note.content,
                      style: TextStyle(
                          color: foreground,
                          fontFamily: family,
                          fontSize: widget.session.fontSize,
                          height: 1.22),
                    )),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
