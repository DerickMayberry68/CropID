import 'package:latlong2/latlong.dart';

extension LatLngListExt on List<LatLng> {
  /// Compute a simple centroid for a polygon point list
  LatLng get centroid {
    if (isEmpty) return const LatLng(0, 0);
    final lat = map((p) => p.latitude).reduce((a, b) => a + b) / length;
    final lng = map((p) => p.longitude).reduce((a, b) => a + b) / length;
    return LatLng(lat, lng);
  }
}

extension StringExt on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension DateTimeExt on DateTime {
  String get shortDate => '${month.toString().padLeft(2, '0')}/'
      '${day.toString().padLeft(2, '0')}/$year';
}

extension DeterministicOrderExt<T> on Iterable<T> {
  /// Stable descending sort by `createdAt`, with deterministic `stableId`
  /// tie-breaker to prevent UI jitter during refresh/realtime updates.
  List<T> sortedByCreatedAtDesc({
    required DateTime? Function(T item) createdAt,
    required String Function(T item) stableId,
  }) {
    final list = toList(growable: false);
    list.sort((a, b) {
      final aTime = createdAt(a);
      final bTime = createdAt(b);
      if (aTime == null && bTime == null) {
        return stableId(a).compareTo(stableId(b));
      }
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      final byTime = bTime.compareTo(aTime); // newest first
      if (byTime != 0) return byTime;
      return stableId(a).compareTo(stableId(b));
    });
    return list;
  }
}
