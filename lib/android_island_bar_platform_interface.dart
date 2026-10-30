import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'android_island_bar_method_channel.dart';
import 'src/models/cutout_info.dart';

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
}
