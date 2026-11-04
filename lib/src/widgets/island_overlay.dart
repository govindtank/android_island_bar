import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/island_controller.dart';
import '../models/cutout_info.dart';
import '../models/island_theme.dart';
import '../models/island_types.dart';
import 'island_pill.dart';

/// Hosts the animated island above an application and anchors it to real
/// Android cutout geometry when the platform provides it.
class AndroidIslandBarOverlay extends StatefulWidget {
  const AndroidIslandBarOverlay({
    super.key,
    required this.child,
    this.controller,
    this.theme = const IslandTheme(),
    this.alignment = CutoutAlignment.auto,
    this.dismissOnBackdropTap = true,
    this.customTopOffset = 0.0,
    this.customHorizontalOffset = 0.0,
  });

  final Widget child;
  final AndroidIslandBarController? controller;
  final IslandTheme theme;
  final CutoutAlignment alignment;
  final bool dismissOnBackdropTap;
  final double customTopOffset;
  final double customHorizontalOffset;

  @override
  State<AndroidIslandBarOverlay> createState() =>
      _AndroidIslandBarOverlayState();
}

class _AndroidIslandBarOverlayState extends State<AndroidIslandBarOverlay>
    with WidgetsBindingObserver {
  late AndroidIslandBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AndroidIslandBarController.instance;
    WidgetsBinding.instance.addObserver(this);
    _controller.initCutoutInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.refreshCutoutInfo();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _controller.refreshCutoutInfo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.refreshCutoutInfo();
    }
  }

  @override
  void didUpdateWidget(covariant AndroidIslandBarOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? AndroidIslandBarController.instance;
      _controller.refreshCutoutInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final state = _controller.state;
              final item = _controller.primaryItem;
              if (state == IslandState.hidden || item == null) {
                return const SizedBox.shrink();
              }

              final media = MediaQuery.of(context);
              final cutout = _controller.cutoutInfo;
              final expanded = state == IslandState.expanded;
              final alignment = _resolveAlignment(widget.alignment, cutout);
              final width = _widthFor(state, media.size.width);
              final left = (_leftFor(
                        alignment: alignment,
                        cutout: cutout,
                        width: width,
                        screenWidth: media.size.width,
                      ) +
                      (expanded ? 0.0 : widget.customHorizontalOffset))
                  .clamp(4.0, media.size.width - width - 4.0);
              final top = expanded
                  ? media.viewPadding.top + 8
                  : (_compactTop(alignment, cutout, media.viewPadding.top) +
                          widget.customTopOffset)
                      .clamp(0.0, media.size.height - 40.0);

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (expanded && widget.dismissOnBackdropTap)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _controller.collapse,
                        child: ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .scrim
                              .withValues(alpha: .38),
                        ),
                      ),
                    ),
                  Positioned(
                    left: left,
                    top: top,
                    width: width,
                    child: IslandPill(
                      controller: _controller,
                      theme: widget.theme,
                      alignment: alignment,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _widthFor(IslandState state, double screenWidth) {
    if (state == IslandState.expanded) {
      return math.min(
        widget.theme.expandedMaxWidth,
        math.max(260, screenWidth - 32),
      );
    }
    return state == IslandState.split
        ? widget.theme.compactMinWidth + 30
        : widget.theme.compactMinWidth + 50;
  }

  double _leftFor({
    required CutoutAlignment alignment,
    required CutoutInfo cutout,
    required double width,
    required double screenWidth,
  }) {
    final rect = cutout.primaryRect;
    final anchored = rect != null &&
        cutout.hasCutout &&
        alignment != CutoutAlignment.floating;
    final center = anchored
        ? rect.center.dx
        : alignment == CutoutAlignment.leftPunch
            ? width / 2 + 8
            : alignment == CutoutAlignment.rightPunch
                ? screenWidth - width / 2 - 8
                : screenWidth / 2;
    return (center - width / 2).clamp(8.0, screenWidth - width - 8.0);
  }

  double _compactTop(
    CutoutAlignment alignment,
    CutoutInfo cutout,
    double viewPaddingTop,
  ) {
    if (alignment == CutoutAlignment.notch && cutout.hasCutout) {
      return 0.0;
    }
    // Float cleanly right below the status bar and camera cutout
    // so the camera lens never punches through text or crowds system icons.
    return viewPaddingTop > 0 ? viewPaddingTop + 4.0 : 8.0;
  }

  CutoutAlignment _resolveAlignment(
    CutoutAlignment config,
    CutoutInfo cutout,
  ) {
    if (config != CutoutAlignment.auto) return config;
    switch (cutout.cutoutType) {
      case CutoutType.leftPunch:
        return CutoutAlignment.leftPunch;
      case CutoutType.rightPunch:
        return CutoutAlignment.rightPunch;
      case CutoutType.notch:
        return CutoutAlignment.notch;
      case CutoutType.centerPunch:
      case CutoutType.none:
        return cutout.hasCutout
            ? CutoutAlignment.centerPunch
            : CutoutAlignment.floating;
    }
  }
}
