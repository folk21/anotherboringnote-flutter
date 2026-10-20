import 'package:flutter/material.dart';

import '../notes/note.dart';
import '../storage/store.dart';
import 'reader_model.dart';

class ReaderPreferences {
  ReaderPreferences(this.store);
  final AppStore store;

  Future<ReaderConfiguration> load() async =>
      decode(await store.readSettings());

  Future<void> save(ReaderConfiguration config) async {
    if (!config.sizesValid) {
      throw ArgumentError('Sizes must be Private < Normal < Large');
    }
    final current = await store.readSettings();
    if (current != null) {
      final values = _properties(current);
      final version = int.tryParse(values?['formatVersion'] ?? '');
      if (version != null && version != 1) {
        throw UnsupportedDataVersion(version);
      }
    }
    await store.writeSettings(encode(config));
  }

  static ReaderConfiguration decode(String? raw) {
    if (raw == null) return const ReaderConfiguration();
    final values = _properties(raw);
    if (values == null || values['formatVersion'] != '1') {
      return const ReaderConfiguration();
    }
    final p = double.tryParse(values['privateSizeSp'] ?? '');
    final n = double.tryParse(values['normalSizeSp'] ?? '');
    final l = double.tryParse(values['largeSizeSp'] ?? '');
    final mode =
        _enumByName(ReaderMode.values, values['defaultMode']?.toLowerCase());
    if (p == null || n == null || l == null || mode == null) {
      return const ReaderConfiguration();
    }
    final orientation = _enumByName(ReaderOrientationPolicy.values,
            _orientationName(values['orientationPolicy'])) ??
        ReaderOrientationPolicy.followSystem;
    final colorKind = values['colorKind'];
    ReaderColorPreset colorPreset = ReaderColorPreset.light;
    var foreground = const Color(0xFF181818);
    var background = const Color(0xFFFAFAFA);
    if (colorKind == 'CUSTOM') {
      final fg = parseHexColor(values['foreground'] ?? '');
      final bg = parseHexColor(values['background'] ?? '');
      if (fg == null || bg == null) return const ReaderConfiguration();
      colorPreset = ReaderColorPreset.custom;
      foreground = fg;
      background = bg;
    } else if (colorKind == null || colorKind == 'PRESET') {
      colorPreset = _enumByName(
              ReaderColorPreset.values, _colorName(values['colorPreset'])) ??
          ReaderColorPreset.light;
    } else {
      return const ReaderConfiguration();
    }
    ReaderFontPreset fontPreset = ReaderFontPreset.sansSerif;
    String? customFontFile;
    if (values['fontKind'] == 'CUSTOM') {
      customFontFile = values['customFontFile'];
      if (!validCustomFontName(customFontFile)) {
        return const ReaderConfiguration();
      }
      fontPreset = ReaderFontPreset.custom;
    } else if (values['fontKind'] == null || values['fontKind'] == 'PRESET') {
      fontPreset = _enumByName(
              ReaderFontPreset.values, _fontName(values['fontPreset'])) ??
          ReaderFontPreset.sansSerif;
    } else {
      return const ReaderConfiguration();
    }
    final config = ReaderConfiguration(
        privateSize: p,
        normalSize: n,
        largeSize: l,
        defaultMode: mode,
        orientation: orientation,
        colorPreset: colorPreset,
        foreground: foreground,
        background: background,
        fontPreset: fontPreset,
        customFontFile: customFontFile);
    return config.sizesValid ? config : const ReaderConfiguration();
  }

  static String encode(ReaderConfiguration c) {
    final orientationName = switch (c.orientation) {
      ReaderOrientationPolicy.followSystem => 'FOLLOW_SYSTEM',
      ReaderOrientationPolicy.portrait => 'PORTRAIT',
      ReaderOrientationPolicy.landscape => 'LANDSCAPE',
    };
    final colorName = c.colorPreset == ReaderColorPreset.highContrast
        ? 'HIGH_CONTRAST'
        : c.colorPreset.name.toUpperCase();
    final fontName = c.fontPreset == ReaderFontPreset.sansSerif
        ? 'SANS_SERIF'
        : c.fontPreset.name.toUpperCase();
    final lines = <String>[
      'formatVersion=1',
      'privateSizeSp=${c.privateSize}',
      'normalSizeSp=${c.normalSize}',
      'largeSizeSp=${c.largeSize}',
      'defaultMode=${c.defaultMode.name.toUpperCase()}',
      'orientationPolicy=$orientationName',
    ];
    if (c.colorPreset == ReaderColorPreset.custom) {
      lines.addAll([
        'colorKind=CUSTOM',
        'foreground=${toHex(c.foreground)}',
        'background=${toHex(c.background)}',
      ]);
    } else {
      lines.addAll(['colorKind=PRESET', 'colorPreset=$colorName']);
    }
    if (c.fontPreset == ReaderFontPreset.custom &&
        validCustomFontName(c.customFontFile)) {
      lines.addAll(['fontKind=CUSTOM', 'customFontFile=${c.customFontFile}']);
    } else {
      lines.addAll(['fontKind=PRESET', 'fontPreset=$fontName']);
    }
    return '${lines.join('\n')}\n';
  }

  static Map<String, String>? _properties(String raw) {
    final values = <String, String>{};
    for (final line in raw.split('\n')) {
      if (line.isEmpty) continue;
      final separator = line.indexOf('=');
      if (separator <= 0) return null;
      final key = line.substring(0, separator);
      if (values.containsKey(key)) return null;
      values[key] = line.substring(separator + 1).trimRight();
    }
    return values;
  }

  static T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static String? _orientationName(String? name) => switch (name) {
        'FOLLOW_SYSTEM' => 'followSystem',
        'PORTRAIT' => 'portrait',
        'LANDSCAPE' => 'landscape',
        _ => null,
      };

  static String? _colorName(String? name) => switch (name) {
        'LIGHT' => 'light',
        'DARK' => 'dark',
        'HIGH_CONTRAST' => 'highContrast',
        'SEPIA' => 'sepia',
        _ => null,
      };

  static String? _fontName(String? name) => switch (name) {
        'SANS_SERIF' => 'sansSerif',
        'SERIF' => 'serif',
        'MONOSPACE' => 'monospace',
        'READABLE' => 'readable',
        _ => null,
      };
}

Color? parseHexColor(String hex) {
  if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) return null;
  return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
}

String toHex(Color color) =>
    '#${(color.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0').toUpperCase()}';

bool validCustomFontName(String? name) =>
    name != null &&
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*\.(ttf|otf)$', caseSensitive: false)
        .hasMatch(name) &&
    name != '..' &&
    name != '.';
