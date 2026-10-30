# android_island_bar

<p align="center">
  <a href="https://pub.dev/packages/android_island_bar"><img src="https://img.shields.io/pub/v/android_island_bar.svg?style=flat-square&color=00E676" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/android_island_bar/score"><img src="https://img.shields.io/pub/points/android_island_bar?style=flat-square&color=00B0FF" alt="Pub Points"></a>
  <a href="https://github.com/govindtank/android_island_bar"><img src="https://img.shields.io/badge/platform-flutter%20%7C%20android-blue?style=flat-square" alt="Platform"></a>
  <a href="https://github.com/govindtank/android_island_bar/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://github.com/govindtank/android_island_bar/stargazers"><img src="https://img.shields.io/github/stars/govindtank/android_island_bar?style=flat-square&color=FFD700" alt="GitHub Stars"></a>
</p>

<p align="center">
  <strong>The True Hardware-Cutout Morphing Dynamic Island for Android &amp; Flutter.</strong><br>
  Snaps directly to physical camera punch-holes with spring physics, multi-task split bubbles, and zero dangerous permissions.
</p>

---

<p align="center">
  <img src="https://raw.githubusercontent.com/govindtank/android_island_bar/main/doc/assets/infographic.svg" width="100%" alt="Android Island Bar Architecture and Infographic" />
</p>

---

## ⚡ Why Developers Choose `android_island_bar`

Most "Dynamic Island" Flutter libraries are hardcoded for iPhone Pro dimensions. On Android, this looks awkward because physical screens feature diverse punch-hole cutouts (center, left-corner, teardrop notches).

`android_island_bar` solves this with **native hardware integration and fluid physics**:

* 🎯 **Hardware Cutout Auto-Snapping**: Queries Android's `DisplayCutout` (`WindowInsets`) to automatically hug and nest inside your device's camera hole (Center, Left-punch, Teardrop Notch, or Floating).
* 🔀 **Multi-Task Split Mode**: When two tasks run simultaneously (e.g., Music + Countdown Timer), the island automatically morphs into a **Dual Split Island** — primary pill on the cutout + a detached secondary bubble.
* 🧲 **Squishy Rubber-Band Drag &amp; Haptics**: Pull down with real drag dampening and spring snap-back. Swipe up to stash or collapse with light tactile haptics.
* 📦 **4 Plug-and-Play Presets**:
  * `IslandItem.media`: Procedural live audio equalizer visualizer, album scrub, play/pause.
  * `IslandItem.timer`: Circular countdown spinner with tabular time figures.
  * `IslandItem.progress`: Download/upload status bar with byte metrics.
  * `IslandItem.alert`: Quick toast/snackbar replacement with actionable chips (e.g. "Copy OTP").
* 🛡️ **Zero Dangerous Permissions**: Pure Flutter overlay layer. No `SYSTEM_ALERT_WINDOW` or accessibility services required — **100% Google Play Store safe**.
* 🚀 **1-Line Global Bus**: Trigger or dismiss items from any widget, bloc, or service using `AndroidIslandBar.show(...)`.

---

## 📊 Comparison Matrix

| Feature | `android_island_bar` | Standard Dynamic Island Packages | Native Android `SYSTEM_ALERT_WINDOW` Apps |
| :--- | :---: | :---: | :---: |
| **Android DisplayCutout Snapping** | **Yes (Auto-adapts to lens)** | No (Hardcoded iOS coords) | Custom hacky service |
| **Multi-Task Split Mode** | **Yes (Primary + Detached Bubble)** | No | Limited |
| **Play Store Policy Safe** | **100% Safe (No risky permissions)** | Safe | High Rejection Risk |
| **Built-in Presets** | **Media, Timer, Progress, Alert** | Custom only | Mixed |
| **Live Audio Waveform Visualizer** | **Built-in Procedural Canvas** | No | No |
| **Rubber-Band Physics &amp; Haptics** | **Yes** | Linear Animation | No |
| **Cross-Platform Fallback** | **Android, iOS, Web, macOS, Desktop** | iOS only | Android only |

---

## 🚀 Getting Started

Add `android_island_bar` to your `pubspec.yaml`:

```yaml
dependencies:
  android_island_bar: ^0.1.0
```

### 1. Wrap Your App in `MaterialApp.builder`

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
        return AndroidIslandBarOverlay(
          alignment: CutoutAlignment.auto, // Auto-hugs hardware camera cutout
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
```

---

## 💡 Usage Examples

### 1. Show Media Player with Animated Visualizer

```dart
AndroidIslandBar.showMedia(
  title: 'Starboy (feat. Daft Punk)',
  artist: 'The Weeknd',
  isPlaying: true,
  progress: 0.35,
  positionText: '1:24',
  durationText: '3:50',
  onPlayPause: () => print('Toggled playback'),
  onNext: () => print('Next track'),
);
```

### 2. Show Countdown Timer

```dart
AndroidIslandBar.showTimer(
  id: 'cooking_timer',
  label: 'Pasta Timer',
  remaining: const Duration(minutes: 4, seconds: 20),
  totalDuration: const Duration(minutes: 8),
  onPauseResume: () => print('Timer paused/resumed'),
  onCancel: () => AndroidIslandBar.dismiss('cooking_timer'),
);
```

### 3. Show File Download / Upload Progress

```dart
AndroidIslandBar.showProgress(
  id: 'firmware_update',
  title: 'Downloading update.zip',
  subtitle: '45 MB / 100 MB • 4.2 MB/s',
  progress: 0.45,
  onCancel: () => AndroidIslandBar.dismiss('firmware_update'),
);
```

### 4. Show OTP / Notification Alert Chip

```dart
AndroidIslandBar.showAlert(
  title: 'Verification Code',
  message: 'Your OTP is 849201',
  actionLabel: 'Copy OTP',
  onAction: () {
    // Copy code to clipboard
  },
  duration: const Duration(seconds: 5),
);
```

### 5. Multi-Tasking Split Island (Concurrent Tasks)

When you trigger multiple tasks, `android_island_bar` automatically splits the pill into a primary card and a detached secondary bubble:

```dart
// Start media playback
AndroidIslandBar.show(IslandItem.media(...));

// Add a timer concurrently -> Island morphs into Dual Split Mode!
AndroidIslandBar.push(IslandItem.timer(...));
```

---

## 🎨 Custom Styling &amp; Theming

Customize colors, elevation, border radius, spring curves, and padding using `IslandTheme`:

```dart
AndroidIslandBarOverlay(
  theme: const IslandTheme(
    backgroundColor: Color(0xFF000000), // Pitch-black OLED cutout bleed
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

## 📱 Hardware Cutout Alignment Options

| Mode | Behavior |
| :--- | :--- |
| `CutoutAlignment.auto` | Auto-detects Android `DisplayCutout` and centers on the camera lens. |
| `CutoutAlignment.centerPunch` | Forces alignment around center camera punch-hole (Samsung Galaxy S/A/M, Motorola Edge). |
| `CutoutAlignment.leftPunch` | Aligns with offset left punch-hole (OnePlus, Pixel, Xiaomi). |
| `CutoutAlignment.notch` | Seamlessly hugs top edge teardrop notch screens. |
| `CutoutAlignment.floating` | Detached floating pill below status bar (ideal for tablets, foldables, or notchless devices). |

---

## 🧪 Testing and Verification

Run tests:

```bash
flutter test
```

Run the example app:

```bash
cd example
flutter run
```

---

## 📄 License

Apache License 2.0. Copyright (c) 2026 Govind Tank.
