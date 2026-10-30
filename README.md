# android_island_bar

<p align="center">
  <a href="https://pub.dev/packages/android_island_bar"><img src="https://img.shields.io/pub/v/android_island_bar.svg?style=flat-square&color=00E676" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/android_island_bar/score"><img src="https://img.shields.io/pub/points/android_island_bar?style=flat-square&color=00B0FF" alt="Pub Points"></a>
  <a href="https://govindtank.github.io/android_island_bar/"><img src="https://img.shields.io/badge/Live_Demo-Try_in_Browser-00E676?style=flat-square&logo=googlechrome&logoColor=white" alt="Live Demo"></a>
  <a href="https://github.com/govindtank/android_island_bar"><img src="https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows-blue?style=flat-square" alt="Platform"></a>
  <a href="https://github.com/govindtank/android_island_bar/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://buymeacoffee.com/govindtank"><img src="https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg?style=flat-square&logo=buymeacoffee" alt="Buy Me A Coffee"></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/Sponsor-GitHub-ea4aaa.svg?style=flat-square&logo=githubsponsors" alt="GitHub Sponsors"></a>
</p>

<p align="center">
  <strong>Universal Cross-Platform Dynamic Island for Flutter (Android, iOS &amp; Web).</strong><br>
  Snaps directly to physical camera punch-holes and iOS Dynamic Island geometries with spring morphing, multi-task concurrent split bubbles, rubber-band physics, and zero dangerous permissions.
</p>

---

<p align="center">
  <a href="https://govindtank.github.io/android_island_bar/">
    <img src="https://raw.githubusercontent.com/govindtank/android_island_bar/main/doc/assets/hero_showcase.svg" width="100%" alt="Android Island Bar Real-World Hardware Showcase" />
  </a>
</p>

<p align="center">
  🎮 <strong><a href="https://govindtank.github.io/android_island_bar/">Launch Live In-Browser Interactive Demo &amp; Cutout Simulator →</a></strong>
</p>

---

## 📱 Hardware Adaptation (Android &amp; iOS)

Unlike packages hardcoded to static coordinates, `android_island_bar` binds directly to physical device cutouts across operating systems:

* **Android Hardware Snapping:** Queries `WindowInsetsCompat.getDisplayCutout()` to automatically position, size, and mask the physical camera lens inside the black island pill. Supports **Center Punch-Holes** (Samsung Galaxy S/A/M, Motorola Edge), **Left Corner Cutouts** (Pixel, OnePlus), and **Teardrop Notches**.
* **iOS Dynamic Island Integration:** Auto-detects iPhone 14 Pro, 15, and 16 series (`safeAreaInsets.top >= 54pt`) to align pixel-perfect with Apple's physical Dynamic Island inside the app, and smoothly hugs the standard notch on iPhone X through 14.
* **Web &amp; Desktop Fallback:** Floats seamlessly as an unobtrusive top-center status pill below window insets.
* **Unified Single API:** Import `android_island_bar` and use either `IslandBar` or `AndroidIslandBar` across all targets with zero platform `if/else` checks.

---

## 🛠️ Real-World Production Scenarios

### 1. Streaming Audio &amp; Podcasts (Spotify / Apple Music Style)

Includes procedural equalizer visualizer bars that bounce when active, album scrub bar, and responsive controls.

```dart
IslandBar.showMedia(
  title: 'Starboy (feat. Daft Punk)',
  artist: 'The Weeknd',
  isPlaying: true,
  progress: 0.35,
  positionText: '1:24',
  durationText: '3:50',
  accentColor: const Color(0xFF00E676),
  onPlayPause: () => togglePlayPause(),
  onNext: () => skipNext(),
  onPrevious: () => skipPrevious(),
);
```

### 2. Active VoIP &amp; Phone Calls (WhatsApp / Cellular Style)

Displays caller avatar, ongoing duration counter, and quick mute / hangup actions. Higher priority ensures it retains primary island focus.

```dart
IslandBar.showCall(
  callerName: 'Alex Mercer',
  durationText: '04:12',
  isMuted: false,
  accentColor: const Color(0xFF00E676),
  onMuteToggle: () => toggleMute(),
  onEndCall: () {
    IslandBar.dismiss('active_call');
  },
);
```

### 3. Turn-by-Turn Rideshare &amp; Navigation (Uber / Maps Style)

Renders navigation maneuvers, remaining distance, and ETA chips in compact mode, expanding into an actionable route overview card.

```dart
IslandBar.showNavigation(
  destination: 'San Francisco Int Airport',
  etaText: '18 min',
  distanceText: '12.4 mi',
  nextInstruction: 'In 500 ft, Turn Right on 4th St',
  accentColor: const Color(0xFF00B0FF),
  onTap: () => openFullMap(),
);
```

### 4. Countdown Timers &amp; Pomodoro

Circular progress ring with tabular seconds countdown, pause/resume toggle, and cancel button.

```dart
IslandBar.showTimer(
  id: 'cooking_timer',
  label: 'Pasta Timer',
  remaining: const Duration(minutes: 4, seconds: 20),
  totalDuration: const Duration(minutes: 8),
  isPaused: false,
  accentColor: const Color(0xFFFF9100),
  onPauseResume: () => toggleTimer(),
  onCancel: () => IslandBar.dismiss('cooking_timer'),
);
```

### 5. OTA Downloads &amp; Background File Transfers

Linear progress indicator with byte velocity and percentage chip.

```dart
IslandBar.showProgress(
  id: 'firmware_ota',
  title: 'Firmware_v2.4.zip',
  subtitle: '48.2 MB / 114 MB • 4.2 MB/s',
  progress: 0.42,
  accentColor: const Color(0xFF29B6F6),
  onCancel: () => cancelDownload(),
);
```

### 6. Actionable Alerts &amp; OTP Autofill

Clean snackbar replacement with one-tap action chip (e.g. "Copy OTP") and configurable auto-dismiss.

```dart
IslandBar.showAlert(
  title: 'Verification Code',
  message: 'Your login code is 849201',
  actionLabel: 'Copy 849201',
  onAction: () => copyToClipboard('849201'),
  duration: const Duration(seconds: 5),
);
```

### 7. Multi-Tasking Concurrent Split Mode

When two activities are active simultaneously (e.g., Music playback + an active Timer), the island automatically splits into a **Dual Split Island**:
- The higher-priority task occupies the primary camera cutout pill.
- The secondary task attaches as a detached floating circular bubble on the opposite side.
- Tapping either bubble expands that specific task.

```dart
// Primary task (Music)
IslandBar.show(IslandItem.media(...));

// Pushing a second task automatically initiates Split Mode
IslandBar.push(IslandItem.timer(...));
```

---

## 🧲 Gestures &amp; Physics

* **Tap:** Expands the compact pill into an interactive control card.
* **Rubber-Band Drag Down:** Pulling down on the compact pill introduces fluid dampening resistance before snapping open with a spring curve.
* **Swipe Up:** Collapses the expanded sheet, or stashes the compact pill into the camera cutout.
* **Tactile Haptics:** Built-in `HapticFeedback.lightImpact()` fires upon expansion, collapse, and snap transitions.

---

## 🚀 Getting Started

Add `android_island_bar` to your `pubspec.yaml`:

```yaml
dependencies:
  android_island_bar: ^0.2.0
```

Wrap your root application inside `MaterialApp.builder`:

```dart
import 'package:flutter/material.dart';
import 'package:android_island_bar/android_island_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return IslandBarOverlay(
          alignment: CutoutAlignment.auto, // Auto-adapts to Android punch holes & iOS Dynamic Island
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
```

---

## 🎨 Theme Customization

Pass an `IslandTheme` to `IslandBarOverlay` to customize colors, spring curves, elevation, and paddings:

```dart
IslandBarOverlay(
  theme: const IslandTheme(
    backgroundColor: Color(0xFF000000), // Pitch-black OLED cutout masking
    contentColor: Color(0xFFFFFFFF),
    accentColor: Color(0xFF00E676),
    compactHeight: 38.0,
    expandedBorderRadius: 28.0,
    enableHaptics: true,
    springCurve: Curves.easeOutBack,
  ),
  child: child!,
);
```

---

## 🛡️ Policy &amp; Permissions

* **100% Google Play Store &amp; App Store Safe:** Operates entirely within the Flutter widget tree overlay.
* **No `SYSTEM_ALERT_WINDOW` or Accessibility permissions required:** General Play Store compliance with zero rejection risk.

---

## ☕ Support &amp; Donations

If this library saves you time or powers your application, consider supporting ongoing development:

* **Buy Me A Coffee:** [buymeacoffee.com/govindtank](https://buymeacoffee.com/govindtank)
* **GitHub Sponsors:** [github.com/sponsors/govindtank](https://github.com/govindtank)

---

## 📄 License

MIT License. Copyright (c) 2026 Govind Tank.
