## 0.1.0

* **Initial Release of `android_island_bar`**
* **Native DisplayCutout Snapping:** Android `WindowInsets` integration to detect and hug physical camera cutouts (center punch hole, left punch hole, teardrop notch, and floating mode).
* **Multi-Task Split Mode:** Automatically splits into primary cutout pill and detached secondary floating bubble when concurrent tasks run (e.g., Music + Timer).
* **Interactive Gestures & Physics:** Squishy rubber-band drag-to-expand, swipe-up to stash/dismiss, and haptic feedback.
* **4 Built-In Live Presets:**
  * `IslandItem.media`: Animated audio visualizer, album scrub, play/pause controls.
  * `IslandItem.timer`: Circular progress ring with live countdown.
  * `IslandItem.progress`: Download/upload progress bar with byte metrics.
  * `IslandItem.alert`: Quick toast/snackbar replacement with actionable chips (e.g. OTP copy).
* **Zero Risky Permissions:** Pure Flutter overlay architecture that complies 100% with Google Play Store policies.
* **Global Bus Controller:** One-line programmatic control from anywhere via `AndroidIslandBar.show(...)`, `AndroidIslandBar.update(...)`, `AndroidIslandBar.dismiss()`.
