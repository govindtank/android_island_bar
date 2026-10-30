import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'android_island_bar_platform_interface.dart';
import 'src/models/cutout_info.dart';

/// An implementation of [AndroidIslandBarPlatform] that uses method channels.
class MethodChannelAndroidIslandBar extends AndroidIslandBarPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('android_island_bar');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<CutoutInfo> getCutoutInfo() async {
    try {
      final map = await methodChannel.invokeMapMethod<dynamic, dynamic>(
        'getCutoutInfo',
      );
      return CutoutInfo.fromMap(map);
    } catch (e) {
      // Graceful fallback on non-Android platforms or if API < 28
      return CutoutInfo.empty;
    }
  }
}
