import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'android_island_bar_platform_interface.dart';
import 'src/models/cutout_info.dart';

/// A web implementation of the AndroidIslandBarPlatform of the AndroidIslandBar plugin.
class AndroidIslandBarWeb extends AndroidIslandBarPlatform {
  /// Constructs a AndroidIslandBarWeb
  AndroidIslandBarWeb();

  /// Registers this class as the default instance of [AndroidIslandBarPlatform].
  static void registerWith(Registrar registrar) {
    AndroidIslandBarPlatform.instance = AndroidIslandBarWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  @override
  Future<CutoutInfo> getCutoutInfo() async {
    return CutoutInfo.empty;
  }
}
