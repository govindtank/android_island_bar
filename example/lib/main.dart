import 'dart:async';

import 'package:android_island_bar/android_island_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const FluxIslandApp());
}

/// Visual theme presets with high-contrast OLED typography
enum AppThemePreset {
  cyberLime(
    'Cyber Lime',
    Color(0xFFCBFF4D),
    Color(0xFF38D9F5),
    Color(0xFF07090E),
    Color(0xFF111722),
  ),
  tokyoNight(
    'Tokyo Night',
    Color(0xFFA78BFA),
    Color(0xFF60A5FA),
    Color(0xFF0F101A),
    Color(0xFF181B2B),
  ),
  sunsetGlow(
    'Sunset Glow',
    Color(0xFFFB7185),
    Color(0xFFFBBF24),
    Color(0xFF0E0812),
    Color(0xFF1C1326),
  ),
  matrixEmerald(
    'Matrix Emerald',
    Color(0xFF34D399),
    Color(0xFF10B981),
    Color(0xFF050A08),
    Color(0xFF0D1B14),
  ),
  ceramicLight(
    'Ceramic Light',
    Color(0xFF2563EB),
    Color(0xFF0D9488),
    Color(0xFFF4F6F9),
    Color(0xFFFFFFFF),
  );

  const AppThemePreset(
    this.label,
    this.primary,
    this.secondary,
    this.surface,
    this.card,
  );
  final String label;
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color card;
}

class FluxMark extends StatelessWidget {
  const FluxMark({super.key, this.size = 44});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _FluxMarkPainter());
  }
}

class _FluxMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 44;
    canvas.scale(scale);
    final base = Paint()..color = const Color(0xFF121923);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 44, 44),
        const Radius.circular(14),
      ),
      base,
    );

    final orbit = Paint()
      ..color = const Color(0xFFCBFF4D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(7, 7, 30, 30),
      -2.55,
      2.15,
      false,
      orbit,
    );

    final island = Paint()..color = const Color(0xFFCBFF4D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 10, 20, 11),
        const Radius.circular(5.5),
      ),
      island,
    );

    final flow = Paint()
      ..color = const Color(0xFF38D9F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(8, 29)
      ..cubicTo(13, 25, 16, 34, 21, 30)
      ..cubicTo(26, 26, 29, 34, 36, 28);
    canvas.drawPath(path, flow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FluxIslandApp extends StatefulWidget {
  const FluxIslandApp({super.key});

  @override
  State<FluxIslandApp> createState() => _FluxIslandAppState();
}

class _FluxIslandAppState extends State<FluxIslandApp>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  int _currentTab = 0;
  AppThemePreset _selectedTheme = AppThemePreset.cyberLime;

  // Real System Media Session
  MediaSnapshot _systemMedia = const MediaSnapshot(
    accessGranted: false,
    hasSession: false,
  );
  bool _mediaLoading = true;
  Timer? _mediaPoller;

  // Real Android Battery Telemetry
  BatterySnapshot _battery = const BatterySnapshot(
    percent: -1,
    isCharging: false,
    temperatureC: 0.0,
    isFastCharge: false,
  );
  Timer? _batteryPoller;

  // Real System Clipboard
  String _currentClipboardText = '';

  // Real Countdown Timer
  final int _timerMinutes = 5;
  int _timerSecondsRemaining = 5 * 60;
  bool _timerActive = false;
  Timer? _countdownTicker;

  // Real Precision Stopwatch
  bool _stopwatchActive = false;
  int _stopwatchElapsedSeconds = 0;
  Timer? _stopwatchTicker;

  // Hardware Cutout Calibrator State
  CutoutAlignment _calibrationAlignment = CutoutAlignment.auto;
  double _topOffset = 0.0;
  double _horizontalOffset = 0.0;
  double _compactWidth = 152.0;
  double _compactHeight = 38.0;
  double _cornerRadius = 24.0;
  CutoutInfo _detectedCutout = CutoutInfo.empty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _refreshRealData();
    _mediaPoller = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _pollMedia(),
    );
    _batteryPoller = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _pollBattery(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mediaPoller?.cancel();
    _batteryPoller?.cancel();
    _countdownTicker?.cancel();
    _stopwatchTicker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRealData();
    }
  }

  Future<void> _refreshRealData() async {
    await Future.wait([
      _pollMedia(),
      _pollBattery(),
      _pollClipboard(),
      _queryHardwareCutout(),
    ]);
  }

  Future<void> _queryHardwareCutout() async {
    try {
      final info = await AndroidIslandBar.getCutoutInfo();
      if (mounted) setState(() => _detectedCutout = info);
    } catch (_) {}
  }

  Future<void> _pollMedia() async {
    try {
      final snapshot = await AndroidIslandBar.getMediaSnapshot();
      if (!mounted) return;
      setState(() {
        _systemMedia = snapshot;
        _mediaLoading = false;
      });

      if (snapshot.hasSession) {
        _publishSystemMediaIsland(snapshot);
      } else {
        if (AndroidIslandBar.controller.items.any(
          (it) => it.id == 'active_media',
        )) {
          AndroidIslandBar.dismiss('active_media');
        }
      }
    } catch (_) {}
  }

  Future<void> _pollBattery() async {
    try {
      final snapshot = await AndroidIslandBar.getBatteryInfo();
      if (!mounted) return;
      setState(() => _battery = snapshot);
    } catch (_) {}
  }

  Future<void> _pollClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (mounted) {
        setState(() => _currentClipboardText = data?.text ?? '');
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Real Media Island Actions
  // ---------------------------------------------------------------------------
  void _publishSystemMediaIsland(MediaSnapshot snapshot) {
    final title = snapshot.title.trim().isEmpty
        ? 'Playing Audio'
        : snapshot.title.trim();
    final artist = snapshot.artist.trim().isEmpty
        ? snapshot.appLabel
        : snapshot.artist.trim();

    final item = IslandItem.media(
      id: 'active_media',
      title: title,
      artist: artist.isEmpty ? snapshot.packageName : artist,
      isPlaying: snapshot.isPlaying,
      progress: snapshot.progress,
      positionText: snapshot.positionText,
      durationText: snapshot.durationText,
      accentColor: _selectedTheme.secondary,
      onPlayPause: () => _controlSystemMedia('playPause'),
      onPrevious: () => _controlSystemMedia('previous'),
      onNext: () => _controlSystemMedia('next'),
    );

    if (AndroidIslandBar.controller.items.any((it) => it.id == item.id)) {
      AndroidIslandBar.update(item);
    } else {
      AndroidIslandBar.show(item);
    }
  }

  Future<void> _controlSystemMedia(String action) async {
    await AndroidIslandBar.controlMedia(action);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _pollMedia();
  }

  // ---------------------------------------------------------------------------
  // Real Battery Island Action
  // ---------------------------------------------------------------------------
  void _showBatteryIsland() {
    HapticFeedback.lightImpact();
    if (_battery.percent < 0) {
      _pollBattery();
      _showToast('Reading battery from system...');
      return;
    }

    final item = IslandItem(
      id: 'real_battery',
      title: 'Battery ${_battery.percent}%',
      duration: const Duration(seconds: 6),
      priority: 15,
      leading: Icon(
        _battery.isCharging
            ? Icons.battery_charging_full_rounded
            : Icons.battery_std_rounded,
        color: _battery.percent > 20
            ? const Color(0xFF00FF87)
            : Colors.redAccent,
        size: 18,
      ),
      compactBuilder: (context, item, theme) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _battery.isCharging
                ? Icons.bolt_rounded
                : Icons.battery_std_rounded,
            color: _battery.percent > 20
                ? const Color(0xFF00FF87)
                : Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '${_battery.percent}%${_battery.isCharging ? ' · CHARGING' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
      expandedBuilder: (context, item, theme, collapse) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF00FF87).withValues(alpha: .2),
                child: Icon(
                  _battery.isCharging
                      ? Icons.battery_charging_full_rounded
                      : Icons.battery_std_rounded,
                  color: const Color(0xFF00FF87),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BATTERY TELEMETRY',
                      style: TextStyle(
                        color: const Color(0xFF00FF87),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _battery.isCharging
                          ? (_battery.isFastCharge
                                ? 'Fast Charging Connected'
                                : 'Charging')
                          : 'On Battery Power',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_battery.percent}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_battery.percent / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00FF87)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_battery.temperatureC.toStringAsFixed(1)}°C Battery Temp',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                _battery.isCharging ? 'Power Connected' : 'Discharging',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );

    AndroidIslandBar.show(item);
  }

  // ---------------------------------------------------------------------------
  // Real Clipboard Action
  // ---------------------------------------------------------------------------
  void _showClipboardIsland() async {
    HapticFeedback.lightImpact();
    await _pollClipboard();
    if (_currentClipboardText.trim().isEmpty) {
      _showToast('Clipboard is currently empty');
      return;
    }

    final isUrl =
        _currentClipboardText.startsWith('http://') ||
        _currentClipboardText.startsWith('https://');
    final snippet = _currentClipboardText.length > 28
        ? '${_currentClipboardText.substring(0, 28)}...'
        : _currentClipboardText;

    final item = IslandItem(
      id: 'real_clipboard',
      title: snippet,
      duration: const Duration(seconds: 6),
      priority: 20,
      leading: const Icon(
        Icons.content_paste_rounded,
        color: Color(0xFF38D9F5),
        size: 18,
      ),
      compactBuilder: (context, item, theme) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.content_paste_rounded,
            color: Color(0xFF38D9F5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              snippet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      expandedBuilder: (context, item, theme, collapse) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.content_paste_search_rounded,
                color: Color(0xFF38D9F5),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CLIPBOARD CONTENT',
                      style: TextStyle(
                        color: const Color(0xFF38D9F5),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentClipboardText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isUrl) ...[
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      collapse();
                      _showToast('Link recognized');
                    },
                    icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                    label: const Text('Valid Link'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: ''));
                  setState(() => _currentClipboardText = '');
                  collapse();
                  _showToast('Clipboard cleared');
                },
                icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );

    AndroidIslandBar.show(item);
    AndroidIslandBar.expand();
  }

  // ---------------------------------------------------------------------------
  // Real Usable Countdown Timer
  // ---------------------------------------------------------------------------
  void _toggleCountdownTimer() {
    HapticFeedback.mediumImpact();
    setState(() => _timerActive = !_timerActive);

    if (_timerActive) {
      _countdownTicker?.cancel();
      _countdownTicker = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_timerSecondsRemaining <= 0) {
          t.cancel();
          setState(() {
            _timerActive = false;
            _timerSecondsRemaining = _timerMinutes * 60;
          });
          AndroidIslandBar.showAlert(
            title: 'Timer Complete',
            message: 'Your $_timerMinutes-minute countdown is done.',
            accentColor: _selectedTheme.primary,
          );
          return;
        }
        setState(() => _timerSecondsRemaining--);
        _publishTimerIsland();
      });
      _publishTimerIsland();
      _showToast('Timer started for $_timerMinutes min');
    } else {
      _countdownTicker?.cancel();
      AndroidIslandBar.dismiss('countdown_timer');
      _showToast('Timer paused');
    }
  }

  void _publishTimerIsland() {
    final m = (_timerSecondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_timerSecondsRemaining % 60).toString().padLeft(2, '0');
    final item = IslandItem.timer(
      id: 'countdown_timer',
      label: 'Timer $m:$s',
      remaining: Duration(seconds: _timerSecondsRemaining),
      totalDuration: Duration(seconds: _timerMinutes * 60),
      isPaused: !_timerActive,
      accentColor: _selectedTheme.primary,
      onPauseResume: _toggleCountdownTimer,
      onCancel: () {
        _countdownTicker?.cancel();
        setState(() {
          _timerActive = false;
          _timerSecondsRemaining = _timerMinutes * 60;
        });
        AndroidIslandBar.dismiss('countdown_timer');
      },
    );

    if (AndroidIslandBar.controller.items.any((it) => it.id == item.id)) {
      AndroidIslandBar.update(item);
    } else {
      AndroidIslandBar.show(item);
    }
  }

  // ---------------------------------------------------------------------------
  // Real Precision Stopwatch
  // ---------------------------------------------------------------------------
  void _toggleStopwatch() {
    HapticFeedback.mediumImpact();
    setState(() => _stopwatchActive = !_stopwatchActive);

    if (_stopwatchActive) {
      _stopwatchTicker?.cancel();
      _stopwatchTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _stopwatchElapsedSeconds++);
        _publishStopwatchIsland();
      });
      _publishStopwatchIsland();
      _showToast('Stopwatch running in island');
    } else {
      _stopwatchTicker?.cancel();
      AndroidIslandBar.dismiss('real_stopwatch');
      _showToast('Stopwatch paused');
    }
  }

  void _publishStopwatchIsland() {
    final m = (_stopwatchElapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_stopwatchElapsedSeconds % 60).toString().padLeft(2, '0');

    final item = IslandItem(
      id: 'real_stopwatch',
      title: 'Stopwatch $m:$s',
      priority: 16,
      leading: const Icon(
        Icons.timer_outlined,
        color: Color(0xFFFBBF24),
        size: 18,
      ),
      trailing: Text(
        '$m:$s',
        style: const TextStyle(
          color: Color(0xFFFBBF24),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
      compactBuilder: (context, item, theme) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFFFBBF24), size: 16),
          const SizedBox(width: 6),
          Text(
            '$m:$s',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
      expandedBuilder: (context, item, theme, collapse) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: Color(0xFFFBBF24),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'STOPWATCH ACTIVE',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '$m:$s',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _toggleStopwatch,
                  child: Text(_stopwatchActive ? 'Pause' : 'Resume'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _stopwatchTicker?.cancel();
                  setState(() {
                    _stopwatchActive = false;
                    _stopwatchElapsedSeconds = 0;
                  });
                  AndroidIslandBar.dismiss('real_stopwatch');
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );

    if (AndroidIslandBar.controller.items.any((it) => it.id == item.id)) {
      AndroidIslandBar.update(item);
    } else {
      AndroidIslandBar.show(item);
    }
  }

  void _showToast(String msg) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  // ---------------------------------------------------------------------------
  // Theme & Island Overlay Geometry
  // ---------------------------------------------------------------------------
  ThemeData get _activeTheme {
    final dark = _selectedTheme != AppThemePreset.ceramicLight;
    final primary = _selectedTheme.primary;
    final secondary = _selectedTheme.secondary;
    final surface = _selectedTheme.surface;
    final card = _selectedTheme.card;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: dark
          ? ColorScheme.dark(
              primary: primary,
              secondary: secondary,
              surface: surface,
              onSurface: const Color(0xFFF8FAFC),
              onSurfaceVariant: const Color(0xFF94A3B8),
              outline: const Color(0xFF334155),
            )
          : ColorScheme.light(
              primary: primary,
              secondary: secondary,
              surface: surface,
              onSurface: const Color(0xFF0F172A),
              onSurfaceVariant: const Color(0xFF475569),
              outline: const Color(0xFFCBD5E1),
            ),
      scaffoldBackgroundColor: surface,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: .08)
                : Colors.black.withValues(alpha: .06),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF0C1017) : Colors.white,
        indicatorColor: primary.withValues(alpha: .2),
        height: 70,
      ),
    );
  }

  IslandTheme get _islandTheme {
    final dark = _selectedTheme != AppThemePreset.ceramicLight;
    return IslandTheme(
      backgroundColor: dark ? const Color(0xFF06080C) : const Color(0xFF1E293B),
      contentColor: Colors.white,
      secondaryContentColor: Colors.white.withValues(alpha: .85),
      accentColor: _selectedTheme.primary,
      compactMinWidth: _compactWidth,
      compactHeight: _compactHeight,
      compactBorderRadius: _cornerRadius,
      border: Border.all(color: Colors.white.withValues(alpha: .18)),
      shadowColor: Colors.black.withValues(alpha: .45),
      enableHaptics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _selectedTheme != AppThemePreset.ceramicLight;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flux Island',
      scaffoldMessengerKey: _messengerKey,
      theme: _activeTheme,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: AndroidIslandBarOverlay(
          alignment: _calibrationAlignment,
          customTopOffset: _topOffset,
          customHorizontalOffset: _horizontalOffset,
          theme: _islandTheme,
          child: child!,
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentTab,
            children: [
              _buildIslandHub(),
              _buildCutoutCalibrator(),
              _buildSettingsStudio(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: (idx) => setState(() => _currentTab = idx),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.bolt_outlined,
                color: _activeTheme.colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.bolt_rounded,
                color: _activeTheme.colorScheme.primary,
              ),
              label: 'Island Hub',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.tune_rounded,
                color: _activeTheme.colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.tune_rounded,
                color: _activeTheme.colorScheme.primary,
              ),
              label: 'Cutout Tuner',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.palette_outlined,
                color: _activeTheme.colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.palette_rounded,
                color: _activeTheme.colorScheme.primary,
              ),
              label: 'Themes',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: ISLAND HUB (REAL DATA ONLY)
  // ---------------------------------------------------------------------------
  Widget _buildIslandHub() => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _buildHeader()),
      SliverToBoxAdapter(child: _buildSystemMediaCard()),
      SliverToBoxAdapter(
        child: _buildSectionTitle('Real Hardware Telemetry', 'DEVICE SENSORS'),
      ),
      SliverToBoxAdapter(child: _buildRealBatteryCard()),
      SliverToBoxAdapter(
        child: _buildSectionTitle('System Clipboard', 'COPY / PASTE INSPECTOR'),
      ),
      SliverToBoxAdapter(child: _buildRealClipboardCard()),
      SliverToBoxAdapter(
        child: _buildSectionTitle('Island Utilities', 'STOPWATCH & TIMERS'),
      ),
      SliverToBoxAdapter(child: _buildUtilitiesRow()),
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
    ],
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        const FluxMark(size: 42),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FLUX ISLAND',
                style: _activeTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: _activeTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                _systemMedia.hasSession
                    ? 'Syncing ${_systemMedia.appLabel}'
                    : (_mediaLoading
                          ? 'Connecting Android media...'
                          : 'Real System Bridge Active'),
                style: _activeTheme.textTheme.bodySmall?.copyWith(
                  color: _activeTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {
            AndroidIslandBar.expand();
            _showToast('Island expanded');
          },
          tooltip: 'Expand Island',
          icon: const Icon(Icons.open_in_full_rounded, size: 20),
        ),
      ],
    ),
  );

  Widget _buildSystemMediaCard() {
    final hasSession = _systemMedia.hasSession;
    final access = _systemMedia.accessGranted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: hasSession
                          ? _selectedTheme.primary
                          : (access ? _selectedTheme.secondary : Colors.amber),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasSession
                        ? 'PLAYING IN ${_systemMedia.appLabel.toUpperCase()}'
                        : (access
                              ? 'MEDIA BRIDGE CONNECTED'
                              : 'NOTIFICATION ACCESS REQUIRED'),
                    style: TextStyle(
                      color: _activeTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: _pollMedia,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (hasSession) ...[
                Text(
                  _systemMedia.title.isEmpty
                      ? 'Active Track'
                      : _systemMedia.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _activeTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: _activeTheme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_systemMedia.artist} · ${_systemMedia.appLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _activeTheme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _systemMedia.progress,
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      _selectedTheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _systemMedia.positionText,
                      style: TextStyle(
                        color: _activeTheme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _systemMedia.durationText,
                      style: TextStyle(
                        color: _activeTheme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _controlSystemMedia('previous'),
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _controlSystemMedia('playPause'),
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: Icon(
                        _systemMedia.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _controlSystemMedia('next'),
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  access
                      ? 'No active media playback detected on this device.'
                      : 'Grant notification listener permission so Flux Island can sync with Spotify, YouTube, and other media apps.',
                  style: _activeTheme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: _activeTheme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                if (!access)
                  FilledButton.icon(
                    onPressed: () => AndroidIslandBar.openMediaAccessSettings(),
                    icon: const Icon(Icons.settings_suggest_rounded),
                    label: const Text('Open Android Access Settings'),
                  )
                else
                  Text(
                    'Start playing music or podcast in any app to see it surface in the island.',
                    style: TextStyle(
                      color: _activeTheme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealBatteryCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF87).withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _battery.isCharging
                    ? Icons.battery_charging_full_rounded
                    : Icons.battery_std_rounded,
                color: const Color(0xFF00FF87),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _battery.percent >= 0
                            ? '${_battery.percent}%'
                            : 'Reading...',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF87).withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _battery.isCharging ? 'CHARGING' : 'DISCHARGING',
                          style: const TextStyle(
                            color: Color(0xFF00FF87),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_battery.temperatureC > 0 ? '${_battery.temperatureC.toStringAsFixed(1)}°C · ' : ''}Real Android BatteryManager',
                    style: TextStyle(
                      color: _activeTheme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: _showBatteryIsland,
              child: const Text('Island HUD'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildRealClipboardCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.content_paste_rounded,
                  color: Color(0xFF38D9F5),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'CURRENT CLIPBOARD',
                  style: TextStyle(
                    color: _activeTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  onPressed: _pollClipboard,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _currentClipboardText.trim().isEmpty
                  ? 'Clipboard is currently empty on this device.'
                  : _currentClipboardText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _activeTheme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _showClipboardIsland,
                  icon: const Icon(Icons.bubble_chart_rounded, size: 16),
                  label: const Text('Show in Island'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: ''));
                    setState(() => _currentClipboardText = '');
                    _showToast('Clipboard cleared');
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildUtilitiesRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFFA78BFA),
                    size: 24,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Countdown Timer',
                    style: _activeTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timerActive
                        ? '${_timerSecondsRemaining ~/ 60}:${(_timerSecondsRemaining % 60).toString().padLeft(2, '0')}'
                        : '$_timerMinutes min',
                    style: TextStyle(
                      color: _activeTheme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: _toggleCountdownTimer,
                    child: Text(_timerActive ? 'Pause' : 'Start'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFFFBBF24),
                    size: 24,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Precision Stopwatch',
                    style: _activeTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_stopwatchElapsedSeconds ~/ 60}:${(_stopwatchElapsedSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _activeTheme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: _toggleStopwatch,
                    child: Text(_stopwatchActive ? 'Pause' : 'Start'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ---------------------------------------------------------------------------
  // TAB 2: HARDWARE CUTOUT CALIBRATOR
  // ---------------------------------------------------------------------------
  Widget _buildCutoutCalibrator() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      Text(
        'Cutout Calibrator',
        style: _activeTheme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Fine-tune the floating island position to match your phone’s camera cutout.',
        style: TextStyle(color: _activeTheme.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hardware Cutout Insets (Detected)',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Top Inset: ${_detectedCutout.safeInsetTop.toStringAsFixed(1)} dp · Type: ${_detectedCutout.cutoutType.name.toUpperCase()}',
                style: TextStyle(
                  color: _selectedTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CutoutAlignment.values.map((a) {
                  final isSel = _calibrationAlignment == a;
                  return ChoiceChip(
                    label: Text(a.name.toUpperCase()),
                    selected: isSel,
                    selectedColor: _selectedTheme.primary,
                    onSelected: (_) =>
                        setState(() => _calibrationAlignment = a),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vertical Top Offset',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${_topOffset.toStringAsFixed(1)} dp',
                    style: TextStyle(
                      color: _selectedTheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _topOffset,
                min: -15.0,
                max: 35.0,
                activeColor: _selectedTheme.primary,
                onChanged: (v) => setState(() => _topOffset = v),
              ),
              const Divider(color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Horizontal X Offset',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${_horizontalOffset.toStringAsFixed(1)} dp',
                    style: TextStyle(
                      color: _selectedTheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _horizontalOffset,
                min: -50.0,
                max: 50.0,
                activeColor: _selectedTheme.primary,
                onChanged: (v) => setState(() => _horizontalOffset = v),
              ),
              const Divider(color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pill Width',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${_compactWidth.round()} dp',
                    style: TextStyle(
                      color: _selectedTheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _compactWidth,
                min: 100.0,
                max: 220.0,
                activeColor: _selectedTheme.primary,
                onChanged: (v) => setState(() => _compactWidth = v),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: () {
          setState(() {
            _topOffset = 0.0;
            _horizontalOffset = 0.0;
            _compactWidth = 152.0;
            _compactHeight = 38.0;
            _cornerRadius = 24.0;
            _calibrationAlignment = CutoutAlignment.auto;
          });
          _showToast('Calibrator reset to auto-detect');
        },
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text('Reset Calibration'),
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // TAB 3: THEMES & ARCHITECTURE
  // ---------------------------------------------------------------------------
  Widget _buildSettingsStudio() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      Text(
        'Studio & Themes',
        style: _activeTheme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'High-contrast palettes with true OLED pitch-black fidelity.',
        style: TextStyle(color: _activeTheme.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme Palette',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...AppThemePreset.values.map((preset) {
                final isSel = _selectedTheme == preset;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTheme = preset),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSel
                            ? preset.primary.withValues(alpha: .15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSel ? preset.primary : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: preset.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: preset.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              preset.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isSel)
                            Icon(
                              Icons.check_circle_rounded,
                              color: preset.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFFCBFF4D)),
                  SizedBox(width: 10),
                  Text(
                    'System Overlay Architecture',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Flux Island runs cleanly as an in-window hardware cutout overlay with zero privacy risks. '
                'For floating above external third-party apps on Android, SYSTEM_ALERT_WINDOW can be authorized via Android Settings.',
                style: TextStyle(
                  color: _activeTheme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: () => AndroidIslandBar.openMediaAccessSettings(),
                icon: const Icon(Icons.settings_suggest_rounded),
                label: const Text('Manage Android Media Access'),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildSectionTitle(String title, String eyebrow) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
    child: Row(
      children: [
        Text(
          title,
          style: _activeTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: _activeTheme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          eyebrow,
          style: TextStyle(
            color: _activeTheme.colorScheme.onSurfaceVariant,
            fontSize: 10,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
