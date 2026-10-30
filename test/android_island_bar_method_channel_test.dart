import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:android_island_bar/android_island_bar_method_channel.dart';
import 'package:android_island_bar/android_island_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelAndroidIslandBar platform =
      MethodChannelAndroidIslandBar();
  const MethodChannel channel = MethodChannel('android_island_bar');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getPlatformVersion') {
        return 'Android 14';
      }
      if (methodCall.method == 'getCutoutInfo') {
        return <String, dynamic>{
          'hasCutout': true,
          'cutoutType': 'center_punch',
          'safeInsetTop': 36.0,
          'safeInsetBottom': 0.0,
          'safeInsetLeft': 0.0,
          'safeInsetRight': 0.0,
          'rects': [
            <String, dynamic>{
              'left': 180.0,
              'top': 0.0,
              'right': 220.0,
              'bottom': 36.0,
              'width': 40.0,
              'height': 36.0,
              'centerX': 200.0,
              'centerY': 18.0,
            }
          ],
        };
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), 'Android 14');
  });

  test('getCutoutInfo', () async {
    final cutout = await platform.getCutoutInfo();
    expect(cutout.hasCutout, isTrue);
    expect(cutout.cutoutType, CutoutType.centerPunch);
    expect(cutout.safeInsetTop, 36.0);
    expect(cutout.primaryRect?.width, 40.0);
  });
}
