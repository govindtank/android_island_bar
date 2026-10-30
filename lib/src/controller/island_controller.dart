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
  String? _expandedItemId;
  Timer? _dismissTimer;
  CutoutInfo _cutoutInfo = CutoutInfo.empty;
  bool _cutoutLoaded = false;

  /// Currently active primary item.
  IslandItem? get primaryItem => _items.isNotEmpty ? _items.first : null;

  /// Currently expanded item when in [IslandState.expanded].
  IslandItem? get expandedItem {
    if (_expandedItemId != null) {
      final match = _items.where((it) => it.id == _expandedItemId);
      if (match.isNotEmpty) return match.first;
    }
    return primaryItem;
  }

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
    final existingIndex = _items.indexWhere((it) => it.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = item;
    } else {
      _items.insert(0, item);
      _items.sort((a, b) => b.priority.compareTo(a.priority));
    }

    // Preserve expanded state if currently expanded
    if (_state == IslandState.expanded) {
      notifyListeners();
      return;
    }

    _dismissTimer?.cancel();
    if (_items.length > 1) {
      _state = IslandState.split;
    } else {
      _state = IslandState.compact;
    }

    _scheduleDismissal(item);
    notifyListeners();
  }

  /// Updates an active item in-place without triggering re-entry animations or collapsing expanded view.
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

  /// Promotes a secondary item to primary and expands it.
  void promoteAndExpand(String id) {
    final index = _items.indexWhere((it) => it.id == id);
    if (index > 0) {
      final item = _items.removeAt(index);
      _items.insert(0, item);
    }
    expand(id);
  }

  /// Dismisses an item by its [id], or the top item if [id] is null.
  void dismiss([String? id]) {
    _dismissTimer?.cancel();
    if (_items.isEmpty) {
      _state = IslandState.hidden;
      _expandedItemId = null;
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
      _expandedItemId = null;
    } else if (_items.length == 1) {
      _state = IslandState.compact;
      _expandedItemId = null;
      _scheduleDismissal(_items.first);
    } else {
      _state = IslandState.split;
      _expandedItemId = null;
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
    _expandedItemId = null;
    notifyListeners();
  }

  /// Expands the primary or specified island into its full interactive card.
  void expand([String? id]) {
    if (_items.isEmpty) return;
    _dismissTimer?.cancel(); // Freeze auto-dismiss while expanded!
    _state = IslandState.expanded;
    _expandedItemId = id ?? primaryItem?.id;
    expandedItem?.onExpanded?.call();
    notifyListeners();
  }

  /// Collapses the expanded island back to its compact or split mode.
  void collapse() {
    if (_items.isEmpty) {
      _state = IslandState.hidden;
    } else if (_items.length > 1) {
      _state = IslandState.split;
      _scheduleDismissal(_items.first);
    } else {
      _state = IslandState.compact;
      _scheduleDismissal(_items.first);
    }
    _expandedItemId = null;
    notifyListeners();
  }

  /// Stashes (minimizes) the island until reopened.
  void stash() {
    _state = IslandState.hidden;
    _expandedItemId = null;
    notifyListeners();
  }

  void _scheduleDismissal(IslandItem item) {
    // Only schedule dismissal if not currently expanded
    if (_state != IslandState.expanded && item.duration != null) {
      _dismissTimer?.cancel();
      _dismissTimer = Timer(item.duration!, () {
        dismiss(item.id);
      });
    }
  }
}
