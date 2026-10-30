import 'package:flutter/widgets.dart';

/// The type of display cutout detected on the device screen.
enum CutoutType {
  /// Cutout is centered at the top of the display (standard punch hole).
  centerPunch,

  /// Cutout is placed towards the top-left corner.
  leftPunch,

  /// Cutout is placed towards the top-right corner.
  rightPunch,

  /// Cutout spans a notch or teardrop shape.
  notch,

  /// No cutout detected, or device uses an edge-to-edge bezel.
  none,
}

/// Alignment rule for positioning the island bar relative to hardware barriers.
enum CutoutAlignment {
  /// Automatically inspects Android DisplayCutout insets and aligns accordingly.
  auto,

  /// Forces alignment to the horizontal center (matching center punch holes).
  centerPunch,

  /// Forces alignment towards the top-left (matching offset punch holes).
  leftPunch,

  /// Forces alignment towards the top-right.
  rightPunch,

  /// Hugs the top edge notch seamlessly.
  notch,

  /// Detached floating pill below the status bar padding.
  floating,
}

/// The current visual state of the island bar.
enum IslandState {
  /// Island is collapsed into the cutout and invisible.
  hidden,

  /// Island is in its compact status pill form hugging the cutout.
  compact,

  /// Island is in multi-task split mode (primary pill + detached secondary bubble).
  split,

  /// Island is expanded into an interactive full control card.
  expanded,
}

/// Action item displayed inside an expanded or alert island.
class IslandAction {
  /// Creates an action button for an island item.
  const IslandAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
  });

  /// The text label of the action button.
  final String label;

  /// Callback fired when the action button is tapped.
  final VoidCallback onPressed;

  /// Optional icon displayed alongside the label.
  final Widget? icon;

  /// Whether this action indicates a destructive or cancellation action.
  final bool isDestructive;
}
