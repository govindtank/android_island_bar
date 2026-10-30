## 0.2.2

* **Corrected Buy Me A Coffee URL:** Updated donation target to `buymeacoffee.com/govindtanko` in `pubspec.yaml` and `README.md`.
* **Redesigned Hero Graphic Showcase:** Completely redesigned `hero_showcase.svg` with spacious card architecture, generous inner margins (≥20px clearance), and elimination of all long text strings that bypassed container borders.

## 0.2.1

* **Fixed Expanded View Closing Prematurely:**
  * Fixed hit-testing in `IslandPill` and `IslandOverlay`: inner taps on expanded card padding and buttons now stay opaque and never bubble through to the backdrop dismiss listener.
  * Preserved expanded state during continuous updates (e.g. countdown timers, download progression, audio scrubs). Auto-dismiss timers are safely paused while the island is expanded.
  * Secondary split bubbles now promote the selected item to primary before expanding cleanly.
* **Pixel-Perfect Widget Border Wrapping:**
  * Added strict SVG `<clipPath>` definitions to all showcase assets (`hero_showcase.svg`, `infographic.svg`) and generous inner padding to ensure no text, waveform bars, or badges bleed over the widget's corner borders.
* **Performance:** Eliminated root widget rebuilds in the showcase app by switching ticking streams to in-place island updates.

## 0.2.0

* **Cross-Platform Support (Android, iOS & Web):**
  * Added native iOS Swift implementation detecting iPhone 14 Pro / 15 / 16 series Dynamic Island geometry (`safeAreaInsets.top >= 54pt`) and standard notch on iPhone X–14.
  * Added Web implementation with zero-overhead fallback.
  * Full platform support declared: Android, iOS, Web, macOS, Linux, and Windows.
* **Universal Single API:**
  * Added `IslandBar`, `IslandBarOverlay`, and `IslandBarController` aliases for clean, cross-platform codebases.
* **New Production Scenarios:**
  * Added `IslandItem.call` for VoIP & Cellular phone calls (duration counter, mute toggle, hangup button).
  * Added `IslandItem.navigation` for Turn-by-Turn Rideshare and Maps tracking (ETA, maneuvers, distance).
* **Live In-Browser Demo:** Deployed live interactive web showcase and camera cutout simulator to GitHub Pages.
* **OSI-Approved MIT License & Funding links:** Added full MIT license and community donation links (GitHub Sponsors & Buy Me A Coffee).

## 0.1.0

* Initial release of `android_island_bar`.
* Native Android `DisplayCutout` snapping.
* Multi-task concurrent split mode.
* Fluid morphing container and presets (Media, Timer, Progress, Alert).
