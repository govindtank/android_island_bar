import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_island_bar/android_island_bar.dart';
import 'package:android_island_bar/android_island_bar_platform_interface.dart';
import 'package:android_island_bar/android_island_bar_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAndroidIslandBarPlatform
    with MockPlatformInterfaceMixin
    implements AndroidIslandBarPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('Android 14');

  @override
  Future<CutoutInfo> getCutoutInfo() => Future.value(
        const CutoutInfo(
          hasCutout: true,
          cutoutType: CutoutType.centerPunch,
          safeInsetTop: 36.0,
          safeInsetBottom: 0.0,
          safeInsetLeft: 0.0,
          safeInsetRight: 0.0,
          rects: [Rect.fromLTWH(180, 0, 40, 36)],
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final AndroidIslandBarPlatform initialPlatform =
      AndroidIslandBarPlatform.instance;

  test('$MethodChannelAndroidIslandBar is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAndroidIslandBar>());
  });

  test('getPlatformVersion and getCutoutInfo via mock platform', () async {
    final fakePlatform = MockAndroidIslandBarPlatform();
    AndroidIslandBarPlatform.instance = fakePlatform;

    expect(await AndroidIslandBar.getPlatformVersion(), 'Android 14');
    final cutout = await AndroidIslandBar.getCutoutInfo();
    expect(cutout.hasCutout, isTrue);
    expect(cutout.cutoutType, CutoutType.centerPunch);
    expect(cutout.primaryRect, const Rect.fromLTWH(180, 0, 40, 36));
  });

  group('AndroidIslandBarController and Item lifecycle', () {
    final controller = AndroidIslandBarController.instance;

    setUp(() {
      controller.clear();
    });

    test('showing an item updates primary item and transitions to compact', () {
      final media = IslandItem.media(
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        isPlaying: true,
      );

      controller.show(media);
      expect(controller.state, IslandState.compact);
      expect(controller.primaryItem?.id, 'media_player');
      expect(controller.primaryItem?.title, 'Blinding Lights');
    });

    test('pushing a second item transitions to split mode', () {
      final media = IslandItem.media(
        title: 'Song A',
        artist: 'Artist A',
      );
      final timer = IslandItem.timer(
        label: 'Pasta',
        remaining: const Duration(minutes: 5),
        totalDuration: const Duration(minutes: 10),
      );

      controller.show(media);
      expect(controller.state, IslandState.compact);

      controller.push(timer);
      expect(controller.state, IslandState.split);
      expect(controller.items.length, 2);
    });

    test('expanding and collapsing toggles state', () {
      final progress = IslandItem.progress(
        title: 'Download file',
        progress: 0.45,
      );

      controller.show(progress);
      expect(controller.state, IslandState.compact);

      controller.expand();
      expect(controller.state, IslandState.expanded);

      // Verify that calling show/update with new progress while expanded PRESERVES expanded state!
      controller.show(IslandItem.progress(
        title: 'Download file',
        progress: 0.46,
      ));
      expect(controller.state, IslandState.expanded);

      controller.collapse();
      expect(controller.state, IslandState.compact);

      controller.stash();
      expect(controller.state, IslandState.hidden);
    });

    test('dismissing item removes it and restores state', () {
      final alert = IslandItem.alert(
        id: 'otp',
        title: 'OTP Received',
        message: 'Your code is 849201',
      );

      controller.show(alert);
      expect(controller.state, IslandState.compact);

      controller.dismiss('otp');
      expect(controller.state, IslandState.hidden);
      expect(controller.primaryItem, isNull);
    });

    test('showing a call item has top priority', () {
      final call = IslandItem.call(
        callerName: 'Alex Mercer',
        durationText: '02:45',
      );
      final media = IslandItem.media(
        title: 'Song',
        artist: 'Artist',
      );

      controller.show(media);
      controller.show(call);

      expect(controller.primaryItem?.id, 'active_call');
      expect(controller.state, IslandState.split);
    });

    test('showing a navigation item sets correct properties', () {
      final nav = IslandItem.navigation(
        destination: 'Airport',
        etaText: '12 min',
        distanceText: '5 mi',
        nextInstruction: 'Turn left',
      );

      controller.show(nav);
      expect(controller.primaryItem?.id, 'navigation');
      expect(controller.primaryItem?.title, 'Airport');
    });

    test('universal alias IslandBar calls succeed', () {
      IslandBar.clear();
      expect(IslandBar.controller.items.isEmpty, isTrue);

      IslandBar.show(IslandItem.alert(title: 'Test'));
      expect(IslandBar.controller.state, IslandState.compact);
    });
  });
}
