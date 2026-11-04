/// Snapshot of the media session currently active on Android.
class MediaSnapshot {
  const MediaSnapshot({
    required this.accessGranted,
    required this.hasSession,
    this.title = '',
    this.artist = '',
    this.album = '',
    this.packageName = '',
    this.appLabel = '',
    this.isPlaying = false,
    this.positionMs = 0,
    this.durationMs = 0,
  });

  final bool accessGranted;
  final bool hasSession;
  final String title;
  final String artist;
  final String album;
  final String packageName;
  final String appLabel;
  final bool isPlaying;
  final int positionMs;
  final int durationMs;

  double get progress =>
      durationMs <= 0 ? 0 : (positionMs / durationMs).clamp(0.0, 1.0);

  String get positionText => _format(positionMs);
  String get durationText => _format(durationMs);

  factory MediaSnapshot.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const MediaSnapshot(accessGranted: false, hasSession: false);
    }
    return MediaSnapshot(
      accessGranted: map['accessGranted'] as bool? ?? false,
      hasSession: map['hasSession'] as bool? ?? false,
      title: map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? '',
      album: map['album'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
      appLabel: map['appLabel'] as String? ?? '',
      isPlaying: map['isPlaying'] as bool? ?? false,
      positionMs: (map['positionMs'] as num?)?.round() ?? 0,
      durationMs: (map['durationMs'] as num?)?.round() ?? 0,
    );
  }

  static String _format(int milliseconds) {
    final seconds = (milliseconds / 1000).floor().clamp(0, 99 * 60 * 60);
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}
