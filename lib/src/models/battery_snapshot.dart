/// Real device battery and power telemetry from Android BatteryManager.
class BatterySnapshot {
  const BatterySnapshot({
    required this.percent,
    required this.isCharging,
    required this.temperatureC,
    required this.isFastCharge,
  });

  final int percent;
  final bool isCharging;
  final double temperatureC;
  final bool isFastCharge;

  factory BatterySnapshot.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const BatterySnapshot(
        percent: -1,
        isCharging: false,
        temperatureC: 0.0,
        isFastCharge: false,
      );
    }
    return BatterySnapshot(
      percent: (map['percent'] as num?)?.toInt() ?? -1,
      isCharging: map['isCharging'] as bool? ?? false,
      temperatureC: (map['temperatureC'] as num?)?.toDouble() ?? 0.0,
      isFastCharge: map['isFastCharge'] as bool? ?? false,
    );
  }
}
