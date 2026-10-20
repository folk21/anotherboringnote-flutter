import 'package:flutter/material.dart';

enum ReaderMode { private, normal, large, presentation }

enum ReaderOrientationPolicy { followSystem, portrait, landscape }

enum ReaderColorPreset { light, dark, highContrast, sepia, custom }

enum ReaderFontPreset { sansSerif, serif, monospace, readable, custom }

extension ReaderModeLabel on ReaderMode {
  String get label => switch (this) {
        ReaderMode.private => 'Private',
        ReaderMode.normal => 'Normal',
        ReaderMode.large => 'Large',
        ReaderMode.presentation => 'Presentation',
      };
}

class ReaderConfiguration {
  const ReaderConfiguration({
    this.privateSize = 14,
    this.normalSize = 24,
    this.largeSize = 56,
    this.defaultMode = ReaderMode.normal,
    this.orientation = ReaderOrientationPolicy.followSystem,
    this.colorPreset = ReaderColorPreset.light,
    this.foreground = const Color(0xFF181818),
    this.background = const Color(0xFFFAFAFA),
    this.fontPreset = ReaderFontPreset.sansSerif,
    this.customFontFile,
  });

  final double privateSize;
  final double normalSize;
  final double largeSize;
  final ReaderMode defaultMode;
  final ReaderOrientationPolicy orientation;
  final ReaderColorPreset colorPreset;
  final Color foreground;
  final Color background;
  final ReaderFontPreset fontPreset;
  final String? customFontFile;

  bool get sizesValid =>
      privateSize.isFinite &&
      normalSize.isFinite &&
      largeSize.isFinite &&
      privateSize > 0 &&
      privateSize < normalSize &&
      normalSize < largeSize;

  double sizeFor(ReaderMode mode) => switch (mode) {
        ReaderMode.private => privateSize,
        ReaderMode.normal => normalSize,
        ReaderMode.large || ReaderMode.presentation => largeSize,
      };

  (Color, Color) get colors => switch (colorPreset) {
        ReaderColorPreset.light => (
            const Color(0xFF181818),
            const Color(0xFFFAFAFA)
          ),
        ReaderColorPreset.dark => (
            const Color(0xFFF4F4F4),
            const Color(0xFF161616)
          ),
        ReaderColorPreset.highContrast => (Colors.white, Colors.black),
        ReaderColorPreset.sepia => (
            const Color(0xFF3B2F25),
            const Color(0xFFF3E7CF)
          ),
        ReaderColorPreset.custom => (foreground, background),
      };

  String? get fontFamily => switch (fontPreset) {
        ReaderFontPreset.sansSerif => null,
        ReaderFontPreset.serif => 'serif',
        ReaderFontPreset.monospace => 'monospace',
        ReaderFontPreset.readable => 'sans-serif',
        ReaderFontPreset.custom => 'abn_custom',
      };

  ReaderConfiguration copyWith({
    double? privateSize,
    double? normalSize,
    double? largeSize,
    ReaderMode? defaultMode,
    ReaderOrientationPolicy? orientation,
    ReaderColorPreset? colorPreset,
    Color? foreground,
    Color? background,
    ReaderFontPreset? fontPreset,
    String? customFontFile,
  }) =>
      ReaderConfiguration(
        privateSize: privateSize ?? this.privateSize,
        normalSize: normalSize ?? this.normalSize,
        largeSize: largeSize ?? this.largeSize,
        defaultMode: defaultMode ?? this.defaultMode,
        orientation: orientation ?? this.orientation,
        colorPreset: colorPreset ?? this.colorPreset,
        foreground: foreground ?? this.foreground,
        background: background ?? this.background,
        fontPreset: fontPreset ?? this.fontPreset,
        customFontFile: customFontFile ?? this.customFontFile,
      );
}

class ReaderSession {
  const ReaderSession(this.mode, this.fontSize);
  final ReaderMode mode;
  final double fontSize;

  factory ReaderSession.open(ReaderConfiguration config, [ReaderMode? mode]) {
    final selected = mode ?? config.defaultMode;
    return ReaderSession(selected, config.sizeFor(selected));
  }

  ReaderSession select(ReaderMode next, ReaderConfiguration config) =>
      ReaderSession(next, config.sizeFor(next));

  ReaderSession zoom(double delta) =>
      ReaderSession(mode, (fontSize + delta).clamp(8.0, 240.0));

  ReaderSession scale(double scale) => scale > 0 && scale.isFinite
      ? ReaderSession(mode, (fontSize * scale).clamp(8.0, 240.0))
      : this;

  ReaderSession reset(ReaderConfiguration config) => select(mode, config);
}
