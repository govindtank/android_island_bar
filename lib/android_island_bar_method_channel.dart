import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'android_island_bar_platform_interface.dart';
import 'src/models/battery_snapshot.dart';
import 'src/models/cutout_info.dart';
import 'src/models/media_snapshot.dart';

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

  @override
  Future<BatterySnapshot> getBatteryInfo() async {
    try {
      final map = await methodChannel.invokeMapMethod<dynamic, dynamic>(
        'getBatteryInfo',
      );
      return BatterySnapshot.fromMap(map);
    } catch (_) {
      return const BatterySnapshot(
        percent: -1,
        isCharging: false,
        temperatureC: 0.0,
        isFastCharge: false,
      );
    }
  }

  @override
  Future<MediaSnapshot> getMediaSnapshot() async {
    try {
      final map = await methodChannel.invokeMapMethod<dynamic, dynamic>(
        'getMediaSnapshot',
      );
      return MediaSnapshot.fromMap(map);
    } catch (_) {
      return const MediaSnapshot(accessGranted: false, hasSession: false);
    }
  }

  @override
  Future<void> openMediaAccessSettings() {
    return methodChannel.invokeMethod<void>('openMediaAccessSettings');
  }

  @override
  Future<void> controlMedia(String action) {
    return methodChannel.invokeMethod<void>('controlMedia', {'action': action});
  }
}
