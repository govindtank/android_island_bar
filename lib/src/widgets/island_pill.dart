import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/island_controller.dart';
import '../models/island_item.dart';
import '../models/island_theme.dart';
import '../models/island_types.dart';

/// Interactive morphing container for the island bar.
class IslandPill extends StatefulWidget {
  /// Creates an [IslandPill].
  const IslandPill({
    super.key,
    required this.controller,
    required this.theme,
    required this.alignment,
  });

  /// The active controller managing items and state.
  final AndroidIslandBarController controller;

  /// The theme styling parameters.
  final IslandTheme theme;

  /// Alignment rule for cutout hugging.
  final CutoutAlignment alignment;

  @override
  State<IslandPill> createState() => _IslandPillState();
}

class _IslandPillState extends State<IslandPill> {
  double _dragOffset = 0.0;
  bool _isDragging = false;

  void _triggerHaptic() {
    if (widget.theme.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.controller.primaryItem;
    final secondary = widget.controller.secondaryItem;
    final state = widget.controller.state;

    if (item == null || state == IslandState.hidden) {
      return const SizedBox.shrink();
    }

    final isExpanded = state == IslandState.expanded;
    final isSplit = state == IslandState.split && secondary != null;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // Dimensions
    final double targetWidth;
    final double targetHeight;
    final double targetRadius;

    if (isExpanded) {
      targetWidth =
          (screenWidth - 32.0).clamp(240.0, widget.theme.expandedMaxWidth);
      targetHeight = widget.theme.expandedMaxHeight +
          (_isDragging ? _dragOffset * 0.3 : 0.0);
      targetRadius = widget.theme.expandedBorderRadius;
    } else {
      targetWidth = isSplit
          ? (widget.theme.compactMinWidth + 30.0)
          : (widget.theme.compactMinWidth + 50.0);
      targetHeight =
          widget.theme.compactHeight + (_isDragging ? _dragOffset * 0.4 : 0.0);
      targetRadius = widget.theme.compactBorderRadius;
    }

    return GestureDetector(
      onVerticalDragStart: (_) {
        setState(() {
          _isDragging = true;
          _dragOffset = 0.0;
        });
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.primaryDelta ?? 0.0;
          if (_dragOffset < -40.0 && !isExpanded) {
            // Swipe up to stash
            _isDragging = false;
            _dragOffset = 0.0;
            _triggerHaptic();
            widget.controller.stash();
          } else if (_dragOffset > 45.0 && !isExpanded) {
            // Drag down past threshold to expand
            _isDragging = false;
            _dragOffset = 0.0;
            _triggerHaptic();
            widget.controller.expand();
          } else if (_dragOffset < -30.0 && isExpanded) {
            // Swipe up to collapse
            _isDragging = false;
            _dragOffset = 0.0;
            _triggerHaptic();
            widget.controller.collapse();
          }
        });
      },
      onVerticalDragEnd: (_) {
        setState(() {
          _isDragging = false;
          _dragOffset = 0.0;
        });
      },
      onTap: () {
        _triggerHaptic();
        if (isExpanded) {
          widget.controller.collapse();
        } else {
          item.onTap?.call();
          widget.controller.expand();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary Island Pill
          AnimatedContainer(
            duration: _isDragging
                ? const Duration(milliseconds: 60)
                : widget.theme.animationDuration,
            curve: widget.theme.springCurve,
            width: targetWidth,
            constraints: BoxConstraints(
              minHeight: targetHeight,
              maxHeight: isExpanded
                  ? widget.theme.expandedMaxHeight + 40
                  : targetHeight,
            ),
            padding: isExpanded
                ? widget.theme.expandedPadding
                : widget.theme.compactPadding,
            decoration: BoxDecoration(
              color: widget.theme.backgroundColor,
              borderRadius: BorderRadius.circular(targetRadius),
              border: widget.theme.border,
              boxShadow: [
                BoxShadow(
                  color: widget.theme.shadowColor,
                  blurRadius: widget.theme.elevation * 1.5,
                  offset: Offset(0, widget.theme.elevation * 0.4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(targetRadius),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isExpanded
                    ? _buildExpandedContent(context, item)
                    : _buildCompactContent(context, item),
              ),
            ),
          ),

          // Secondary Split Bubble in Multi-Task Mode
          if (isSplit && !isExpanded) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _triggerHaptic();
                // Switch focus to secondary item and expand
                widget.controller.show(secondary);
                widget.controller.expand();
              },
              child: AnimatedContainer(
                duration: widget.theme.animationDuration,
                curve: widget.theme.springCurve,
                width: widget.theme.splitBubbleSize,
                height: widget.theme.splitBubbleSize,
                decoration: BoxDecoration(
                  color: widget.theme.backgroundColor,
                  shape: BoxShape.circle,
                  border: widget.theme.border,
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.shadowColor,
                      blurRadius: widget.theme.elevation,
                      offset: Offset(0, widget.theme.elevation * 0.3),
                    ),
                  ],
                ),
                child: Center(
                  child: secondary.splitBubble ??
                      secondary.trailing ??
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: widget.theme.accentColor,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactContent(BuildContext context, IslandItem item) {
    if (item.compactBuilder != null) {
      return item.compactBuilder!(context, item, widget.theme);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (item.leading != null) item.leading!,
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.theme.contentColor,
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
  }

  Widget _buildExpandedContent(BuildContext context, IslandItem item) {
    if (item.expandedBuilder != null) {
      return item.expandedBuilder!(
        context,
        item,
        widget.theme,
        widget.controller.collapse,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (item.leading != null) ...[
              item.leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: widget.theme.contentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        color: widget.theme.secondaryContentColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: widget.theme.secondaryContentColor, size: 20),
              onPressed: widget.controller.collapse,
            ),
          ],
        ),
        if (item.actions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: item.actions.map((act) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FilledButton.tonal(
                  onPressed: () {
                    act.onPressed();
                    widget.controller.collapse();
                  },
                  child: Text(act.label),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
