import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../android_island_bar_platform_interface.dart';
import '../models/cutout_info.dart';
import '../models/island_item.dart';
import '../models/island_types.dart';

/// Central singleton controller managing the active items and state of the island bar.
class AndroidIslandBarController extends ChangeNotifier {
  AndroidIslandBarController._();

  static final AndroidIslandBarController instance =
      AndroidIslandBarController._();

  final List<IslandItem> _items = <IslandItem>[];
  IslandState _state = IslandState.hidden;
  Timer? _dismissTimer;
  CutoutInfo _cutoutInfo = CutoutInfo.empty;
  bool _cutoutLoaded = false;

  /// Currently active primary item.
  IslandItem? get primaryItem => _items.isNotEmpty ? _items.first : null;

  /// Secondary item displayed in split bubble mode.
  IslandItem? get secondaryItem => _items.length > 1 ? _items[1] : null;

  /// All currently registered island items.
  List<IslandItem> get items => List.unmodifiable(_items);

  /// Current visual state of the island bar.
  IslandState get state => _state;

  /// Cached cutout information from host platform.
  CutoutInfo get cutoutInfo => _cutoutInfo;

  /// Initializes and caches host Android cutout information.
  Future<CutoutInfo> initCutoutInfo() async {
    if (_cutoutLoaded && _cutoutInfo.hasCutout) return _cutoutInfo;
    try {
      _cutoutInfo = await AndroidIslandBarPlatform.instance.getCutoutInfo();
      _cutoutLoaded = true;
      notifyListeners();
    } catch (_) {
      _cutoutInfo = CutoutInfo.empty;
    }
    return _cutoutInfo;
  }

  /// Displays an [IslandItem]. If another item exists, enters split mode.
  void show(IslandItem item) {
    _dismissTimer?.cancel();

    final existingIndex = _items.indexWhere((it) => it.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = item;
    } else {
      _items.insert(0, item);
      _items.sort((a, b) => b.priority.compareTo(a.priority));
    }

    if (_items.length > 1) {
      _state = IslandState.split;
    } else {
      _state = IslandState.compact;
    }

    _scheduleDismissal(item);
    notifyListeners();
  }

  /// Updates an active item in-place without triggering re-entry animations.
  void update(IslandItem item) {
    final index = _items.indexWhere((it) => it.id == item.id);
    if (index >= 0) {
      _items[index] = item;
      notifyListeners();
    } else {
      show(item);
    }
  }

  /// Pushes a secondary item, automatically triggering multi-task split mode.
  void push(IslandItem item) {
    show(item);
  }

  /// Dismisses an item by its [id], or the top item if [id] is null.
  void dismiss([String? id]) {
    _dismissTimer?.cancel();
    if (_items.isEmpty) {
      _state = IslandState.hidden;
      notifyListeners();
      return;
    }

    if (id != null) {
      final removed = _items.where((it) => it.id == id).toList();
      _items.removeWhere((it) => it.id == id);
      for (final it in removed) {
        it.onDismiss?.call();
      }
    } else {
      final removed = _items.removeAt(0);
      removed.onDismiss?.call();
    }

    if (_items.isEmpty) {
      _state = IslandState.hidden;
    } else if (_items.length == 1) {
      _state = IslandState.compact;
      _scheduleDismissal(_items.first);
    } else {
      _state = IslandState.split;
      _scheduleDismissal(_items.first);
    }

    notifyListeners();
  }

  /// Clears all active island items and hides the bar.
  void clear() {
    _dismissTimer?.cancel();
    for (final it in _items) {
      it.onDismiss?.call();
    }
    _items.clear();
    _state = IslandState.hidden;
    notifyListeners();
  }

  /// Expands the primary island into its full interactive card.
  void expand() {
    if (_items.isEmpty) return;
    _state = IslandState.expanded;
    primaryItem?.onExpanded?.call();
    notifyListeners();
  }

  /// Collapses the expanded island back to its compact or split mode.
  void collapse() {
    if (_items.isEmpty) {
      _state = IslandState.hidden;
    } else if (_items.length > 1) {
      _state = IslandState.split;
    } else {
      _state = IslandState.compact;
    }
    notifyListeners();
  }

  /// Stashes (minimizes) the island until reopened.
  void stash() {
    _state = IslandState.hidden;
    notifyListeners();
  }

  void _scheduleDismissal(IslandItem item) {
    if (item.duration != null) {
      _dismissTimer = Timer(item.duration!, () {
        dismiss(item.id);
      });
    }
  }
}
