import 'dart:ui';
import 'island_types.dart';

/// Hardware display cutout geometry parsed from the host Android OS.
class CutoutInfo {
  /// Creates a [CutoutInfo] instance describing device cutout barriers.
  const CutoutInfo({
    required this.hasCutout,
    required this.cutoutType,
    required this.safeInsetTop,
    required this.safeInsetBottom,
    required this.safeInsetLeft,
    required this.safeInsetRight,
    required this.rects,
  });

  /// Default empty cutout information representing a screen with no camera cutout.
  static const empty = CutoutInfo(
    hasCutout: false,
    cutoutType: CutoutType.none,
    safeInsetTop: 0.0,
    safeInsetBottom: 0.0,
    safeInsetLeft: 0.0,
    safeInsetRight: 0.0,
    rects: <Rect>[],
  );

  /// Whether the host display features a hardware cutout (punch hole or notch).
  final bool hasCutout;

  /// The inferred type/placement of the display cutout.
  final CutoutType cutoutType;

  /// Top safe inset in logical density-independent pixels (dp).
  final double safeInsetTop;

  /// Bottom safe inset in logical dp.
  final double safeInsetBottom;

  /// Left safe inset in logical dp.
  final double safeInsetLeft;

  /// Right safe inset in logical dp.
  final double safeInsetRight;

  /// Bounding rectangles of all hardware cutouts on the display.
  final List<Rect> rects;

  /// The primary camera cutout rectangle (first detected cutout, if any).
  Rect? get primaryRect => rects.isNotEmpty ? rects.first : null;

  /// Parses native Map returned from Android platform channel.
  factory CutoutInfo.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return empty;

    final hasCutout = map['hasCutout'] as bool? ?? false;
    final typeStr = map['cutoutType'] as String? ?? 'none';
    final safeTop = (map['safeInsetTop'] as num?)?.toDouble() ?? 0.0;
    final safeBottom = (map['safeInsetBottom'] as num?)?.toDouble() ?? 0.0;
    final safeLeft = (map['safeInsetLeft'] as num?)?.toDouble() ?? 0.0;
    final safeRight = (map['safeInsetRight'] as num?)?.toDouble() ?? 0.0;

    final rawRects = map['rects'] as List<dynamic>? ?? <dynamic>[];
    final parsedRects = <Rect>[];

    for (final item in rawRects) {
      if (item is Map) {
        final left = (item['left'] as num?)?.toDouble() ?? 0.0;
        final top = (item['top'] as num?)?.toDouble() ?? 0.0;
        final right = (item['right'] as num?)?.toDouble() ?? 0.0;
        final bottom = (item['bottom'] as num?)?.toDouble() ?? 0.0;
        parsedRects.add(Rect.fromLTRB(left, top, right, bottom));
      }
    }

    final CutoutType cutoutType;
    switch (typeStr) {
      case 'left_punch':
        cutoutType = CutoutType.leftPunch;
        break;
      case 'right_punch':
        cutoutType = CutoutType.rightPunch;
        break;
      case 'notch':
        cutoutType = CutoutType.notch;
        break;
      case 'center_punch':
        cutoutType = CutoutType.centerPunch;
        break;
      default:
        cutoutType =
            parsedRects.isNotEmpty ? CutoutType.centerPunch : CutoutType.none;
    }

    return CutoutInfo(
      hasCutout: hasCutout || parsedRects.isNotEmpty,
      cutoutType: cutoutType,
      safeInsetTop: safeTop,
      safeInsetBottom: safeBottom,
      safeInsetLeft: safeLeft,
      safeInsetRight: safeRight,
      rects: parsedRects,
    );
  }

  @override
  String toString() =>
      'CutoutInfo(hasCutout: $hasCutout, type: $cutoutType, top: $safeInsetTop, rects: ${rects.length})';
}
