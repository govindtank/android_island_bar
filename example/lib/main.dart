import 'dart:async';
import 'package:flutter/material.dart';
import 'package:android_island_bar/android_island_bar.dart';

void main() {
  runApp(const IslandBarShowcaseApp());
}

class IslandBarShowcaseApp extends StatefulWidget {
  const IslandBarShowcaseApp({super.key});

  @override
  State<IslandBarShowcaseApp> createState() => _IslandBarShowcaseAppState();
}

class _IslandBarShowcaseAppState extends State<IslandBarShowcaseApp> {
  CutoutAlignment _selectedAlignment = CutoutAlignment.auto;
  bool _isPlaying = true;
  double _musicProgress = 0.35;
  Timer? _ticker;

  // Active state trackers
  int _timerSecondsRemaining = 240;
  final int _timerTotalSeconds = 300;
  bool _isTimerPaused = false;
  Timer? _countdownTimer;

  double _downloadProgress = 0.42;
  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    // Continuous progress ticker updating island without rebuilding root tree
    _ticker = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (_isPlaying) {
        _musicProgress += 0.005;
        if (_musicProgress > 1.0) _musicProgress = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _countdownTimer?.cancel();
    _downloadTimer?.cancel();
    super.dispose();
  }

  void _triggerMedia() {
    AndroidIslandBar.show(
      IslandItem.media(
        id: 'media_player',
        title: 'Starboy (feat. Daft Punk)',
        artist: 'The Weeknd',
        isPlaying: _isPlaying,
        progress: _musicProgress,
        positionText: '1:24',
        durationText: '3:50',
        accentColor: const Color(0xFF00E676),
        onPlayPause: () {
          _isPlaying = !_isPlaying;
          _triggerMedia();
        },
        onNext: () {
          AndroidIslandBar.showAlert(
            title: 'Skipped Track',
            message: 'Now playing: Blinding Lights',
            duration: const Duration(seconds: 2),
          );
        },
      ),
    );
  }

  void _triggerTimer() {
    _countdownTimer?.cancel();
    _timerSecondsRemaining = 240;
    _isTimerPaused = false;

    void updateTimerItem({bool isInitial = false}) {
      final timerItem = IslandItem.timer(
        id: 'countdown_timer',
        label: 'Pasta Timer',
        remaining: Duration(seconds: _timerSecondsRemaining),
        totalDuration: Duration(seconds: _timerTotalSeconds),
        isPaused: _isTimerPaused,
        accentColor: const Color(0xFFFF9100),
        onPauseResume: () {
          _isTimerPaused = !_isTimerPaused;
          updateTimerItem();
        },
        onCancel: () {
          _countdownTimer?.cancel();
          AndroidIslandBar.dismiss('countdown_timer');
        },
      );

      if (isInitial) {
        AndroidIslandBar.show(timerItem);
      } else {
        AndroidIslandBar.update(timerItem);
      }
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerPaused && _timerSecondsRemaining > 0) {
        _timerSecondsRemaining--;
        updateTimerItem();
      } else if (_timerSecondsRemaining <= 0) {
        timer.cancel();
        AndroidIslandBar.showAlert(
          title: 'Timer Done!',
          message: 'Pasta is ready to serve',
          accentColor: const Color(0xFFFF9100),
          duration: const Duration(seconds: 4),
        );
      }
    });

    updateTimerItem(isInitial: true);
  }

  void _triggerDownload() {
    _downloadTimer?.cancel();
    _downloadProgress = 0.05;

    void updateProgressItem({bool isInitial = false}) {
      final progressItem = IslandItem.progress(
        id: 'app_download',
        title: 'Firmware_OTA_v2.4.zip',
        subtitle: '48.2 MB / 114 MB • 4.2 MB/s',
        progress: _downloadProgress,
        accentColor: const Color(0xFF29B6F6),
        onCancel: () {
          _downloadTimer?.cancel();
          AndroidIslandBar.dismiss('app_download');
        },
      );

      if (isInitial) {
        AndroidIslandBar.show(progressItem);
      } else {
        AndroidIslandBar.update(progressItem);
      }
    }

    _downloadTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _downloadProgress += 0.04;
      if (_downloadProgress >= 1.0) {
        timer.cancel();
        AndroidIslandBar.showAlert(
          title: 'Download Complete',
          message: 'Firmware_OTA_v2.4.zip saved to Downloads',
          accentColor: const Color(0xFF29B6F6),
          duration: const Duration(seconds: 3),
        );
      } else {
        updateProgressItem();
      }
    });

    updateProgressItem(isInitial: true);
  }

  void _triggerOTPAlert() {
    AndroidIslandBar.showAlert(
      id: 'otp_alert',
      title: 'Verification Code',
      message: 'Your login code is 849201',
      icon: const Icon(Icons.key_rounded, color: Color(0xFF00E676), size: 18),
      accentColor: const Color(0xFF00E676),
      actionLabel: 'Copy 849201',
      onAction: () {
        AndroidIslandBar.showAlert(
          title: 'Code Copied!',
          message: '849201 copied to clipboard',
          duration: const Duration(seconds: 2),
        );
      },
      duration: const Duration(seconds: 6),
    );
  }

  void _triggerCall() {
    AndroidIslandBar.showCall(
      callerName: 'Alex Mercer',
      durationText: '04:12',
      isMuted: false,
      accentColor: const Color(0xFF00E676),
      onMuteToggle: () {
        AndroidIslandBar.showAlert(
          title: 'Microphone Muted',
          message: 'Your audio is now muted',
          duration: const Duration(seconds: 2),
        );
      },
      onEndCall: () {
        AndroidIslandBar.dismiss('active_call');
        AndroidIslandBar.showAlert(
          title: 'Call Ended',
          message: 'Duration: 04:15',
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  void _triggerNavigation() {
    AndroidIslandBar.showNavigation(
      destination: 'San Francisco Int Airport',
      etaText: '18 min',
      distanceText: '12.4 mi',
      nextInstruction: 'In 500 ft, Turn Right on 4th St',
      accentColor: const Color(0xFF29B6F6),
      onTap: () {
        AndroidIslandBar.expand();
      },
    );
  }

  void _triggerMultiTask() {
    _triggerMedia();
    Future.delayed(const Duration(milliseconds: 300), () {
      _triggerTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF29B6F6),
          surface: Color(0xFF161B22),
        ),
      ),
      builder: (context, child) {
        return AndroidIslandBarOverlay(
          alignment: _selectedAlignment,
          child: child!,
        );
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Android Island Bar',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF161B22),
          centerTitle: true,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2430), Color(0xFF161B22)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF00E676,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF00E676),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Hardware Cutout Hugging',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The island automatically snaps to and nests inside the Android camera cutout. '
                    'Tap any pill to expand, drag down for squishy rubber-band physics, or swipe up to stash.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cutout Simulator Switcher
            const Text(
              'CAMERA CUTOUT SIMULATOR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCutoutChip('Auto (Native)', CutoutAlignment.auto),
                _buildCutoutChip('Center Punch', CutoutAlignment.centerPunch),
                _buildCutoutChip('Left Punch', CutoutAlignment.leftPunch),
                _buildCutoutChip('Teardrop Notch', CutoutAlignment.notch),
                _buildCutoutChip('Floating Pill', CutoutAlignment.floating),
              ],
            ),
            const SizedBox(height: 28),

            // Interactive Presets Showcase
            const Text(
              'LIVE PRESETS & GESTURES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),

            _buildPresetCard(
              title: 'Live Media Player',
              subtitle: 'Waveform visualizer, album scrub & controls',
              icon: Icons.music_note_rounded,
              color: const Color(0xFF00E676),
              onTap: _triggerMedia,
            ),
            const SizedBox(height: 10),

            _buildPresetCard(
              title: 'Countdown Timer',
              subtitle: 'Circular countdown ring & formatted time',
              icon: Icons.timer_outlined,
              color: const Color(0xFFFF9100),
              onTap: _triggerTimer,
            ),
            const SizedBox(height: 10),

            _buildPresetCard(
              title: 'Download / Upload Progress',
              subtitle: 'Linear progress bar with byte metrics',
              icon: Icons.cloud_download_rounded,
              color: const Color(0xFF29B6F6),
              onTap: _triggerDownload,
            ),
            const SizedBox(height: 10),

            _buildPresetCard(
              title: 'OTP & High-Priority Alert',
              subtitle: 'Instant toast replacement with Copy action chip',
              icon: Icons.security_rounded,
              color: const Color(0xFFE040FB),
              onTap: _triggerOTPAlert,
            ),
            const SizedBox(height: 10),

            _buildPresetCard(
              title: 'Ongoing VoIP / Phone Call',
              subtitle: 'Active call pill, mute controls & end call',
              icon: Icons.call_rounded,
              color: const Color(0xFF00E676),
              onTap: _triggerCall,
            ),
            const SizedBox(height: 10),

            _buildPresetCard(
              title: 'Navigation & Ride Tracking',
              subtitle: 'Turn-by-turn guidance, ETA and distance metrics',
              icon: Icons.navigation_rounded,
              color: const Color(0xFF00B0FF),
              onTap: _triggerNavigation,
            ),
            const SizedBox(height: 20),

            // Multi-task Split Island Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1A29),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE040FB).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.call_split_rounded, color: Color(0xFFE040FB)),
                      SizedBox(width: 10),
                      Text(
                        'Multi-Task Split Mode',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Simultaneously runs music playback + countdown timer. '
                    'The island automatically splits into a primary pill + detached secondary bubble.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _triggerMultiTask,
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      label: const Text('Simulate Multitask (Music + Timer)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE040FB),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Controls: Expand, Collapse, Dismiss All
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: AndroidIslandBar.expand,
                    icon: const Icon(Icons.open_in_full_rounded, size: 16),
                    label: const Text('Expand'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: AndroidIslandBar.collapse,
                    icon: const Icon(Icons.close_fullscreen_rounded, size: 16),
                    label: const Text('Collapse'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: AndroidIslandBar.clear,
                    icon: const Icon(Icons.clear_all_rounded, size: 16),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCutoutChip(String label, CutoutAlignment alignment) {
    final isSelected = _selectedAlignment == alignment;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedAlignment = alignment;
          });
        }
      },
      selectedColor: const Color(0xFF00E676),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: const Color(0xFF161B22),
    );
  }

  Widget _buildPresetCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
