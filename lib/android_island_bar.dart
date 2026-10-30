import 'package:flutter/material.dart';
import 'android_island_bar_platform_interface.dart';
import 'src/controller/island_controller.dart';
import 'src/models/cutout_info.dart';
import 'src/models/island_item.dart';
import 'src/widgets/island_overlay.dart';

export 'src/controller/island_controller.dart';
export 'src/models/cutout_info.dart';
export 'src/models/island_item.dart';
export 'src/models/island_theme.dart';
export 'src/models/island_types.dart';
export 'src/widgets/audio_visualizer.dart';
export 'src/widgets/circular_timer_indicator.dart';
export 'src/widgets/island_overlay.dart';
export 'src/widgets/island_pill.dart';

/// Top-level coordinator for displaying and managing the Android Island Bar.
class AndroidIslandBar {
  AndroidIslandBar._();

  /// Access the global singleton controller.
  static AndroidIslandBarController get controller =>
      AndroidIslandBarController.instance;

  /// Returns the host platform OS version string.
  static Future<String?> getPlatformVersion() {
    return AndroidIslandBarPlatform.instance.getPlatformVersion();
  }

  /// Queries Android DisplayCutout insets and bounding rectangles.
  static Future<CutoutInfo> getCutoutInfo() {
    return AndroidIslandBarPlatform.instance.getCutoutInfo();
  }

  /// Displays an [IslandItem] in the island bar.
  ///
  /// If another item is already displaying, the island automatically morphs
  /// into multi-task split mode.
  static void show(IslandItem item) {
    controller.show(item);
  }

  /// Convenience shortcut to show an audio/media player island.
  static void showMedia({
    String id = 'media_player',
    required String title,
    required String artist,
    Widget? art,
    bool isPlaying = true,
    double progress = 0.0,
    String? positionText,
    String? durationText,
    Color accentColor = const Color(0xFF00E676),
    VoidCallback? onPlayPause,
    VoidCallback? onNext,
    VoidCallback? onPrevious,
    ValueChanged<double>? onSeek,
  }) {
    controller.show(
      IslandItem.media(
        id: id,
        title: title,
        artist: artist,
        art: art,
        isPlaying: isPlaying,
        progress: progress,
        positionText: positionText,
        durationText: durationText,
        accentColor: accentColor,
        onPlayPause: onPlayPause,
        onNext: onNext,
        onPrevious: onPrevious,
        onSeek: onSeek,
      ),
    );
  }

  /// Convenience shortcut to show a countdown or stopwatch timer island.
  static void showTimer({
    String id = 'timer',
    required String label,
    required Duration remaining,
    required Duration totalDuration,
    bool isPaused = false,
    Color accentColor = const Color(0xFFFF9100),
    VoidCallback? onPauseResume,
    VoidCallback? onCancel,
  }) {
    controller.show(
      IslandItem.timer(
        id: id,
        label: label,
        remaining: remaining,
        totalDuration: totalDuration,
        isPaused: isPaused,
        accentColor: accentColor,
        onPauseResume: onPauseResume,
        onCancel: onCancel,
      ),
    );
  }

  /// Convenience shortcut to show a file download/upload progress island.
  static void showProgress({
    String id = 'progress',
    required String title,
    String? subtitle,
    required double progress,
    Color accentColor = const Color(0xFF29B6F6),
    VoidCallback? onCancel,
  }) {
    controller.show(
      IslandItem.progress(
        id: id,
        title: title,
        subtitle: subtitle,
        progress: progress,
        accentColor: accentColor,
        onCancel: onCancel,
      ),
    );
  }

  /// Convenience shortcut to show an alert, OTP chip, or high-priority toast.
  static void showAlert({
    String id = 'alert',
    required String title,
    String? message,
    Widget? icon,
    Color accentColor = const Color(0xFF00E676),
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    controller.show(
      IslandItem.alert(
        id: id,
        title: title,
        message: message,
        icon: icon,
        accentColor: accentColor,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
    );
  }

  /// Convenience shortcut to show an ongoing phone or VoIP call island.
  static void showCall({
    String id = 'active_call',
    required String callerName,
    required String durationText,
    Widget? avatar,
    bool isMuted = false,
    Color accentColor = const Color(0xFF00E676),
    VoidCallback? onMuteToggle,
    VoidCallback? onEndCall,
  }) {
    controller.show(
      IslandItem.call(
        id: id,
        callerName: callerName,
        durationText: durationText,
        avatar: avatar,
        isMuted: isMuted,
        accentColor: accentColor,
        onMuteToggle: onMuteToggle,
        onEndCall: onEndCall,
      ),
    );
  }

  /// Convenience shortcut to show a turn-by-turn navigation or rideshare tracking island.
  static void showNavigation({
    String id = 'navigation',
    required String destination,
    required String etaText,
    required String distanceText,
    required String nextInstruction,
    Color accentColor = const Color(0xFF29B6F6),
    VoidCallback? onTap,
    VoidCallback? onCancel,
  }) {
    controller.show(
      IslandItem.navigation(
        id: id,
        destination: destination,
        etaText: etaText,
        distanceText: distanceText,
        nextInstruction: nextInstruction,
        accentColor: accentColor,
        onTap: onTap,
        onCancel: onCancel,
      ),
    );
  }

  /// Updates an active item in-place without resetting animations.
  static void update(IslandItem item) {
    controller.update(item);
  }

  /// Pushes a secondary task, triggering multi-task split mode.
  static void push(IslandItem item) {
    controller.push(item);
  }

  /// Dismisses an item by its [id], or the top item if [id] is null.
  static void dismiss([String? id]) {
    controller.dismiss(id);
  }

  /// Dismisses all active items and hides the island.
  static void clear() {
    controller.clear();
  }

  /// Expands the primary island into its interactive card.
  static void expand() {
    controller.expand();
  }

  /// Collapses the expanded island back to compact or split mode.
  static void collapse() {
    controller.collapse();
  }

  /// Stashes (minimizes) the island until reopened.
  static void stash() {
    controller.stash();
  }
}

/// Universal cross-platform alias for [AndroidIslandBar] to use seamlessly across Android, iOS, and Web.
typedef IslandBar = AndroidIslandBar;

/// Universal cross-platform alias for [AndroidIslandBarOverlay].
typedef IslandBarOverlay = AndroidIslandBarOverlay;

/// Universal cross-platform alias for [AndroidIslandBarController].
typedef IslandBarController = AndroidIslandBarController;
