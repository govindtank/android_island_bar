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
