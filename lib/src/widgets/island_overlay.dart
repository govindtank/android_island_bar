import 'package:flutter/material.dart';
import '../controller/island_controller.dart';
import '../models/cutout_info.dart';
import '../models/island_theme.dart';
import '../models/island_types.dart';
import 'island_pill.dart';

/// Top-level overlay wrapper that hosts the animated island bar above your app.
class AndroidIslandBarOverlay extends StatefulWidget {
  /// Creates an [AndroidIslandBarOverlay].
  const AndroidIslandBarOverlay({
    super.key,
    required this.child,
    this.controller,
    this.theme = const IslandTheme(),
    this.alignment = CutoutAlignment.auto,
    this.dismissOnBackdropTap = true,
  });

  /// The child application widget (typically from `MaterialApp.builder`).
  final Widget child;

  /// Optional custom controller. Defaults to [AndroidIslandBarController.instance].
  final AndroidIslandBarController? controller;

  /// Styling and theme parameters.
  final IslandTheme theme;

  /// Hardware cutout alignment strategy.
  final CutoutAlignment alignment;

  /// Whether tapping the backdrop outside an expanded island collapses it.
  final bool dismissOnBackdropTap;

  @override
  State<AndroidIslandBarOverlay> createState() =>
      _AndroidIslandBarOverlayState();
}

class _AndroidIslandBarOverlayState extends State<AndroidIslandBarOverlay> {
  late AndroidIslandBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AndroidIslandBarController.instance;
    _controller.initCutoutInfo();
  }

  @override
  void didUpdateWidget(covariant AndroidIslandBarOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? AndroidIslandBarController.instance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.viewPadding.top;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Underlying Application
          widget.child,

          // Island Overlay Layer
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final state = _controller.state;
              if (state == IslandState.hidden ||
                  _controller.primaryItem == null) {
                return const SizedBox.shrink();
              }

              final isExpanded = state == IslandState.expanded;
              final cutoutInfo = _controller.cutoutInfo;

              // Determine alignment and offsets
              final Alignment islandAlign;
              final EdgeInsets islandMargin;

              final effectiveAlignment =
                  _resolveAlignment(widget.alignment, cutoutInfo);

              switch (effectiveAlignment) {
                case CutoutAlignment.leftPunch:
                  islandAlign = Alignment.topLeft;
                  final leftOffset =
                      cutoutInfo.hasCutout && cutoutInfo.primaryRect != null
                          ? cutoutInfo.primaryRect!.left.clamp(12.0, 48.0)
                          : 16.0;
                  islandMargin = EdgeInsets.only(
                    top: isExpanded
                        ? (topPadding + 8.0)
                        : (topPadding > 0
                            ? (topPadding - 4.0).clamp(4.0, 50.0)
                            : 10.0),
                    left: isExpanded ? 16.0 : leftOffset,
                  );
                  break;

                case CutoutAlignment.rightPunch:
                  islandAlign = Alignment.topRight;
                  islandMargin = EdgeInsets.only(
                    top: isExpanded
                        ? (topPadding + 8.0)
                        : (topPadding > 0
                            ? (topPadding - 4.0).clamp(4.0, 50.0)
                            : 10.0),
                    right: 16.0,
                  );
                  break;

                case CutoutAlignment.notch:
                  islandAlign = Alignment.topCenter;
                  islandMargin = EdgeInsets.only(
                    top: isExpanded ? (topPadding + 8.0) : 0.0,
                  );
                  break;

                case CutoutAlignment.floating:
                  islandAlign = Alignment.topCenter;
                  islandMargin = EdgeInsets.only(
                    top: topPadding + 10.0,
                  );
                  break;

                case CutoutAlignment.centerPunch:
                case CutoutAlignment.auto:
                  islandAlign = Alignment.topCenter;
                  islandMargin = EdgeInsets.only(
                    top: isExpanded
                        ? (topPadding + 8.0)
                        : (topPadding > 0
                            ? (topPadding - 6.0).clamp(4.0, 50.0)
                            : 10.0),
                  );
                  break;
              }

              return Stack(
                children: [
                  // Dismissive backdrop on expanded
                  if (isExpanded && widget.dismissOnBackdropTap)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _controller.collapse,
                        child: Container(
                          color: Colors.black38,
                        ),
                      ),
                    ),

                  // The morphing island pill/card
                  Align(
                    alignment: isExpanded ? Alignment.topCenter : islandAlign,
                    child: Padding(
                      padding: islandMargin,
                      child: IslandPill(
                        controller: _controller,
                        theme: widget.theme,
                        alignment: effectiveAlignment,
                      ),
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

  CutoutAlignment _resolveAlignment(
      CutoutAlignment config, dynamic cutoutInfo) {
    if (config != CutoutAlignment.auto) {
      return config;
    }

    if (cutoutInfo is CutoutInfo && cutoutInfo.hasCutout) {
      switch (cutoutInfo.cutoutType) {
        case CutoutType.leftPunch:
          return CutoutAlignment.leftPunch;
        case CutoutType.rightPunch:
          return CutoutAlignment.rightPunch;
        case CutoutType.notch:
          return CutoutAlignment.notch;
        case CutoutType.centerPunch:
        case CutoutType.none:
          return CutoutAlignment.centerPunch;
      }
    }

    return CutoutAlignment.floating;
  }
}
