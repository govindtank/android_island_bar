import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'android_island_bar_method_channel.dart';
import 'src/models/battery_snapshot.dart';
import 'src/models/cutout_info.dart';
import 'src/models/media_snapshot.dart';

/// The interface that platform-specific implementations of android_island_bar must extend.
abstract class AndroidIslandBarPlatform extends PlatformInterface {
  /// Constructs a AndroidIslandBarPlatform.
  AndroidIslandBarPlatform() : super(token: _token);

  static final Object _token = Object();

  static AndroidIslandBarPlatform _instance = MethodChannelAndroidIslandBar();

  /// The default instance of [AndroidIslandBarPlatform] to use.
  static AndroidIslandBarPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AndroidIslandBarPlatform] when
  /// they register themselves.
  static set instance(AndroidIslandBarPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the host platform OS version string.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Queries native Android DisplayCutout insets and bounding rectangles.
  Future<CutoutInfo> getCutoutInfo() {
    throw UnimplementedError('getCutoutInfo() has not been implemented.');
  }

  /// Queries real device battery percentage and charging telemetry.
  Future<BatterySnapshot> getBatteryInfo() {
    throw UnimplementedError('getBatteryInfo() has not been implemented.');
  }

  /// Returns the active Android media session, when notification access is granted.
  Future<MediaSnapshot> getMediaSnapshot() {
    throw UnimplementedError('getMediaSnapshot() has not been implemented.');
  }

  /// Opens Android notification access settings for the app.
  Future<void> openMediaAccessSettings() {
    throw UnimplementedError(
        'openMediaAccessSettings() has not been implemented.');
  }

  /// Sends a transport command to the current media session.
  Future<void> controlMedia(String action) {
    throw UnimplementedError('controlMedia() has not been implemented.');
  }
}
