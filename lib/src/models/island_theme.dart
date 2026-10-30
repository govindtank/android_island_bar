import 'package:flutter/material.dart';

/// Styling and animation parameters for the island bar.
class IslandTheme {
  /// Creates an [IslandTheme] configuration.
  const IslandTheme({
    this.backgroundColor = const Color(0xFF000000),
    this.contentColor = const Color(0xFFFFFFFF),
    this.secondaryContentColor = const Color(0xFFB0B0B0),
    this.accentColor = const Color(0xFF00E676),
    this.compactHeight = 38.0,
    this.compactMinWidth = 124.0,
    this.expandedMaxWidth = 360.0,
    this.expandedMaxHeight = 220.0,
    this.compactBorderRadius = 24.0,
    this.expandedBorderRadius = 32.0,
    this.splitBubbleSize = 38.0,
    this.elevation = 8.0,
    this.shadowColor = const Color(0x66000000),
    this.border,
    this.enableHaptics = true,
    this.springCurve = Curves.easeOutBack,
    this.animationDuration = const Duration(milliseconds: 380),
    this.expandedPadding = const EdgeInsets.all(18.0),
    this.compactPadding = const EdgeInsets.symmetric(horizontal: 14.0),
  });

  /// Primary background color of the island pill and sheet (default pitch black).
  final Color backgroundColor;

  /// Primary text and icon color.
  final Color contentColor;

  /// Secondary/subdued text color.
  final Color secondaryContentColor;

  /// Accent highlight color for progress bars, visualizer, and active states.
  final Color accentColor;

  /// Height of the compact pill.
  final double compactHeight;

  /// Minimum width of the compact pill.
  final double compactMinWidth;

  /// Maximum width of the expanded interactive sheet.
  final double expandedMaxWidth;

  /// Maximum height of the expanded interactive sheet.
  final double expandedMaxHeight;

  /// Border radius for the compact pill.
  final double compactBorderRadius;

  /// Border radius for the expanded sheet.
  final double expandedBorderRadius;

  /// Diameter of the secondary floating bubble in split mode.
  final double splitBubbleSize;

  /// Elevation shadow depth.
  final double elevation;

  /// Shadow color.
  final Color shadowColor;

  /// Optional outer border outline.
  final BoxBorder? border;

  /// Whether device haptic feedback should trigger on expand/collapse/tap.
  final bool enableHaptics;

  /// Animation curve used for expanding and collapsing.
  final Curve springCurve;

  /// Animation duration for state transitions.
  final Duration animationDuration;

  /// Inner padding for the expanded sheet.
  final EdgeInsets expandedPadding;

  /// Inner padding for the compact pill.
  final EdgeInsets compactPadding;

  /// Creates a copy of this theme with the given fields replaced.
  IslandTheme copyWith({
    Color? backgroundColor,
    Color? contentColor,
    Color? secondaryContentColor,
    Color? accentColor,
    double? compactHeight,
    double? compactMinWidth,
    double? expandedMaxWidth,
    double? expandedMaxHeight,
    double? compactBorderRadius,
    double? expandedBorderRadius,
    double? splitBubbleSize,
    double? elevation,
    Color? shadowColor,
    BoxBorder? border,
    bool? enableHaptics,
    Curve? springCurve,
    Duration? animationDuration,
    EdgeInsets? expandedPadding,
    EdgeInsets? compactPadding,
  }) {
    return IslandTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      contentColor: contentColor ?? this.contentColor,
      secondaryContentColor:
          secondaryContentColor ?? this.secondaryContentColor,
      accentColor: accentColor ?? this.accentColor,
      compactHeight: compactHeight ?? this.compactHeight,
      compactMinWidth: compactMinWidth ?? this.compactMinWidth,
      expandedMaxWidth: expandedMaxWidth ?? this.expandedMaxWidth,
      expandedMaxHeight: expandedMaxHeight ?? this.expandedMaxHeight,
      compactBorderRadius: compactBorderRadius ?? this.compactBorderRadius,
      expandedBorderRadius: expandedBorderRadius ?? this.expandedBorderRadius,
      splitBubbleSize: splitBubbleSize ?? this.splitBubbleSize,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      border: border ?? this.border,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      springCurve: springCurve ?? this.springCurve,
      animationDuration: animationDuration ?? this.animationDuration,
      expandedPadding: expandedPadding ?? this.expandedPadding,
      compactPadding: compactPadding ?? this.compactPadding,
    );
  }
}
