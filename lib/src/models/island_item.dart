import 'package:flutter/material.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/circular_timer_indicator.dart';
import 'island_theme.dart';
import 'island_types.dart';

/// Callback invoked to build the compact island pill.
typedef IslandCompactBuilder = Widget Function(
  BuildContext context,
  IslandItem item,
  IslandTheme theme,
);

/// Callback invoked to build the expanded interactive island card.
typedef IslandExpandedBuilder = Widget Function(
  BuildContext context,
  IslandItem item,
  IslandTheme theme,
  VoidCallback collapse,
);

/// Callback invoked to build the detached secondary bubble in split mode.
typedef IslandSplitBuilder = Widget Function(
  BuildContext context,
  IslandItem item,
  IslandTheme theme,
);

/// Represents an active or queued item in the island bar.
class IslandItem {
  /// Base constructor for custom island items.
  const IslandItem({
    required this.id,
    this.title = '',
    this.subtitle,
    this.leading,
    this.trailing,
    this.splitBubble,
    this.compactBuilder,
    this.expandedBuilder,
    this.duration,
    this.priority = 0,
    this.onTap,
    this.onDismiss,
    this.onExpanded,
    this.actions = const <IslandAction>[],
  });

  /// Unique identifier for this island item.
  final String id;

  /// Primary title or label.
  final String title;

  /// Secondary description or status string.
  final String? subtitle;

  /// Leading widget displayed in the compact pill.
  final Widget? leading;

  /// Trailing widget displayed in the compact pill.
  final Widget? trailing;

  /// Custom widget rendered inside the detached split bubble in multi-task mode.
  final Widget? splitBubble;

  /// Custom builder for the compact pill.
  final IslandCompactBuilder? compactBuilder;

  /// Custom builder for the expanded interactive card.
  final IslandExpandedBuilder? expandedBuilder;

  /// Auto-dismiss duration. If null, remains persistent until dismissed programmatically.
  final Duration? duration;

  /// Priority weighting. In split mode, the item with higher priority claims the primary pill.
  final int priority;

  /// Callback fired when the compact pill is tapped.
  final VoidCallback? onTap;

  /// Callback fired when the item is dismissed or timed out.
  final VoidCallback? onDismiss;

  /// Callback fired when the island successfully expands into its sheet.
  final VoidCallback? onExpanded;

  /// Interactive action buttons displayed in default expanded sheets.
  final List<IslandAction> actions;

  // ---------------------------------------------------------------------------
  // FACTORY PRESETS
  // ---------------------------------------------------------------------------

  /// Creates a rich Media Player island item with an animated audio visualizer.
  factory IslandItem.media({
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
    return IslandItem(
      id: id,
      title: title,
      subtitle: artist,
      priority: 10,
      leading: art != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 22, height: 22, child: art),
            )
          : Icon(Icons.music_note_rounded, size: 18, color: accentColor),
      trailing: AudioVisualizerWidget(
        isPlaying: isPlaying,
        color: accentColor,
        barCount: 4,
        width: 18,
        height: 14,
      ),
      splitBubble: Icon(
        isPlaying ? Icons.music_note_rounded : Icons.pause_rounded,
        size: 18,
        color: accentColor,
      ),
      compactBuilder: (context, item, theme) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.leading ??
                Icon(Icons.music_note_rounded, size: 18, color: accentColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '$title • $artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            item.trailing ??
                AudioVisualizerWidget(
                  isPlaying: isPlaying,
                  color: accentColor,
                  width: 18,
                  height: 14,
                ),
          ],
        );
      },
      expandedBuilder: (context, item, theme, collapse) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: Colors.white10,
                    child: art ??
                        Icon(
                          Icons.album_rounded,
                          size: 32,
                          color: accentColor,
                        ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.contentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.secondaryContentColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                AudioVisualizerWidget(
                  isPlaying: isPlaying,
                  color: accentColor,
                  barCount: 5,
                  width: 26,
                  height: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar / Scrub
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 4,
                  ),
                ),
                if (positionText != null || durationText != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        positionText ?? '0:00',
                        style: TextStyle(
                          color: theme.secondaryContentColor,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        durationText ?? '',
                        style: TextStyle(
                          color: theme.secondaryContentColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onPrevious != null)
                  IconButton(
                    onPressed: onPrevious,
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      color: theme.contentColor,
                      size: 28,
                    ),
                  ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onPlayPause,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (onNext != null)
                  IconButton(
                    onPressed: onNext,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: theme.contentColor,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Creates an active countdown or stopwatch Timer island item.
  factory IslandItem.timer({
    String id = 'timer',
    required String label,
    required Duration remaining,
    required Duration totalDuration,
    bool isPaused = false,
    Color accentColor = const Color(0xFFFF9100),
    VoidCallback? onPauseResume,
    VoidCallback? onCancel,
  }) {
    final remainingSeconds = remaining.inSeconds;
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final formattedTime = '$minutes:$seconds';

    final totalSeconds =
        totalDuration.inSeconds > 0 ? totalDuration.inSeconds : 1;
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return IslandItem(
      id: id,
      title: label,
      subtitle: formattedTime,
      priority: 8,
      leading: CircularTimerIndicator(
        progress: progress,
        size: 20,
        color: accentColor,
        strokeWidth: 2.5,
        child: Icon(
          isPaused ? Icons.pause : Icons.timer_outlined,
          size: 11,
          color: accentColor,
        ),
      ),
      trailing: Text(
        formattedTime,
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      splitBubble: CircularTimerIndicator(
        progress: progress,
        size: 22,
        color: accentColor,
        strokeWidth: 2.5,
        child: Text(
          seconds,
          style: TextStyle(
            color: accentColor,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      compactBuilder: (context, item, theme) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.leading!,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            item.trailing!,
          ],
        );
      },
      expandedBuilder: (context, item, theme, collapse) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircularTimerIndicator(
                  progress: progress,
                  size: 48,
                  strokeWidth: 4,
                  color: accentColor,
                  child: Icon(
                    Icons.hourglass_bottom_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: theme.secondaryContentColor,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: theme.contentColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onCancel != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      collapse();
                      onCancel();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel'),
                  ),
                const SizedBox(width: 10),
                if (onPauseResume != null)
                  FilledButton.icon(
                    onPressed: onPauseResume,
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                    ),
                    icon: Icon(
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      size: 18,
                    ),
                    label: Text(isPaused ? 'Resume' : 'Pause'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Creates a download, upload, or sync Progress island item.
  factory IslandItem.progress({
    String id = 'progress',
    required String title,
    String? subtitle,
    required double progress,
    Color accentColor = const Color(0xFF29B6F6),
    VoidCallback? onCancel,
  }) {
    final pct = (progress.clamp(0.0, 1.0) * 100).toInt();

    return IslandItem(
      id: id,
      title: title,
      subtitle: subtitle,
      priority: 6,
      leading: Icon(Icons.cloud_download_rounded, size: 18, color: accentColor),
      trailing: Text(
        '$pct%',
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      splitBubble: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            backgroundColor: Colors.white24,
          ),
          Icon(Icons.download_rounded, size: 12, color: accentColor),
        ],
      ),
      compactBuilder: (context, item, theme) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.leading!,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            item.trailing!,
          ],
        );
      },
      expandedBuilder: (context, item, theme, collapse) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_sync_rounded, color: accentColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.contentColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: theme.secondaryContentColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '$pct%',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    collapse();
                    onCancel();
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel Download'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Creates a sleek alert, OTP chip, or high-priority notification item.
  factory IslandItem.alert({
    String id = 'alert',
    required String title,
    String? message,
    Widget? icon,
    Color accentColor = const Color(0xFF00E676),
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    return IslandItem(
      id: id,
      title: title,
      subtitle: message,
      duration: duration,
      priority: 12,
      leading: icon ??
          Icon(Icons.check_circle_rounded, color: accentColor, size: 18),
      trailing: actionLabel != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      splitBubble: icon ??
          Icon(Icons.notifications_active_rounded,
              color: accentColor, size: 16),
      compactBuilder: (context, item, theme) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.leading!,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (item.trailing != null) ...[
              const SizedBox(width: 8),
              item.trailing!,
            ],
          ],
        );
      },
      expandedBuilder: (context, item, theme, collapse) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: item.leading,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.contentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        color: theme.secondaryContentColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              FilledButton(
                onPressed: () {
                  collapse();
                  onAction();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(actionLabel),
              ),
          ],
        );
      },
    );
  }

  /// Creates a live ongoing VoIP / Phone Call island item.
  factory IslandItem.call({
    String id = 'active_call',
    required String callerName,
    required String durationText,
    Widget? avatar,
    bool isMuted = false,
    Color accentColor = const Color(0xFF00E676),
    VoidCallback? onMuteToggle,
    VoidCallback? onEndCall,
  }) {
    return IslandItem(
      id: id,
      title: callerName,
      subtitle: durationText,
      priority: 15, // Highest priority
      leading: avatar != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 20, height: 20, child: avatar),
            )
          : Icon(Icons.call_rounded, size: 16, color: accentColor),
      trailing: Text(
        durationText,
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      splitBubble: Icon(Icons.call_rounded, size: 16, color: accentColor),
      compactBuilder: (context, item, theme) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.leading!,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                callerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            item.trailing!,
          ],
        );
      },
      expandedBuilder: (context, item, theme, collapse) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accentColor.withValues(alpha: 0.2),
                  child: avatar ??
                      Icon(Icons.person_rounded, color: accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        callerName,
                        style: TextStyle(
                          color: theme.contentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ongoing Call • $durationText',
                        style: TextStyle(
                          color: theme.secondaryContentColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onMuteToggle != null)
                  IconButton.filledTonal(
                    onPressed: onMuteToggle,
                    icon: Icon(
                      isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: isMuted ? Colors.redAccent : Colors.white,
                    ),
                  ),
                if (onEndCall != null)
                  IconButton.filled(
                    onPressed: () {
                      collapse();
                      onEndCall();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.call_end_rounded),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Creates a turn-by-turn Navigation or Ride Tracking island item (Uber / Google Maps style).
  factory IslandItem.navigation({
    String id = 'navigation',
    required String destination,
    required String etaText,
    required String distanceText,
    required String nextInstruction,
    Color accentColor = const Color(0xFF29B6F6),
    VoidCallback? onTap,
    VoidCallback? onCancel,
  }) {
    return IslandItem(
      id: id,
      title: destination,
      subtitle: '$etaText • $distanceText',
      priority: 11,
      leading: Icon(Icons.navigation_rounded, size: 16, color: accentColor),
      trailing: Text(
        etaText,
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      splitBubble: Icon(Icons.near_me_rounded, size: 16, color: accentColor),
      compactBuilder: (context, item, theme) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.leading!,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '$etaText • $destination',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            item.trailing!,
          ],
        );
      },
      expandedBuilder: (context, item, theme, collapse) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.turn_right_rounded,
                      color: accentColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextInstruction,
                        style: TextStyle(
                          color: theme.contentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$destination • $distanceText',
                        style: TextStyle(
                          color: theme.secondaryContentColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      etaText,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'ETA',
                      style: TextStyle(
                        color: theme.secondaryContentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
