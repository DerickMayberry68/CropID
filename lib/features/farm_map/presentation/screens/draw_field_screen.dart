import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/location_service.dart';
import '../../data/models/field.dart';
import '../../providers/farm_map_provider.dart';
import '../widgets/draw_field_toolbar.dart';
import '../../../../core/utils/extensions.dart';

/// Screen for drawing a new field polygon on the map.
/// Farmer taps points; polygon closes when they tap the first point
/// or press the Done button. Saves to Supabase on confirm.
class DrawFieldScreen extends ConsumerStatefulWidget {
  const DrawFieldScreen({super.key});

  @override
  ConsumerState<DrawFieldScreen> createState() => _DrawFieldScreenState();
}

class _DrawFieldScreenState extends ConsumerState<DrawFieldScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _points = [];
  bool _isSaving = false;
  static const double _closeThresholdPixels = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnLocation();
    });
  }

  Future<void> _centerOnLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      _mapController.move(
        LatLng(pos.latitude, pos.longitude),
        AppConstants.defaultMapZoom,
      );
    }
  }

  /// Returns true if [tap] is close enough to the first point to close the polygon.
  bool _isNearFirstPoint(LatLng tap) {
    if (_points.isEmpty) return false;
    final camera = _mapController.camera;
    final tapPx = camera.latLngToScreenPoint(tap);
    final firstPx = camera.latLngToScreenPoint(_points.first);
    final dx = tapPx.x - firstPx.x;
    final dy = tapPx.y - firstPx.y;
    return (dx * dx + dy * dy) < _closeThresholdPixels * _closeThresholdPixels;
  }

  void _onMapTap(TapPosition _, LatLng point) {
    if (_points.length >= 3 && _isNearFirstPoint(point)) {
      _confirmField();
      return;
    }
    setState(() => _points.add(point));
  }

  void _undoLastPoint() {
    if (_points.isEmpty) return;
    setState(() => _points.removeLast());
  }

  void _clearAll() => setState(() => _points.clear());

  Future<void> _confirmField() async {
    if (_points.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Draw at least 3 points to create a field')),
      );
      return;
    }

    // Show name dialog before saving
    final name = await _showNameDialog();
    if (name == null || !mounted) return;

    setState(() => _isSaving = true);

    final boundaryPoints =
        _points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();

    final field = Field(
      id: const Uuid().v4(),
      farmerId: '', // set by repository from current user
      name: name,
      boundaryPoints: boundaryPoints,
      visibility: FieldVisibility.private,
    );

    final result = await ref.read(fieldRepositoryProvider).createField(field);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (err) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $err'))),
      (_) {
        ref.invalidate(myFieldsProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Field "$name" created')),
        );
      },
    );
  }

  Future<String?> _showNameDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name this field'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. North 40, Back Pasture...',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
            child: const Text('Save Field'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = ref.watch(mapCenterProvider);
    final hasPoints = _points.isNotEmpty;
    final canClose = _points.length >= 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Field Boundary'),
        actions: [
          if (hasPoints)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo last point',
              onPressed: _undoLastPoint,
            ),
          if (hasPoints)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: AppConstants.defaultMapZoom,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.osmTileUrl,
                userAgentPackageName: 'app.cropid',
              ),

              // ── Existing fields (ghost layer for reference) ──────
              PolygonLayer(
                polygons: (ref.watch(myFieldsProvider).value ?? [])
                    .where((f) => f.latLngBoundary.isNotEmpty)
                    .map((f) => Polygon(
                          points: f.latLngBoundary,
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderColor: AppTheme.primaryGreen.withOpacity(0.5),
                          borderStrokeWidth: 1.5,
                          label: f.name,
                          labelStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ))
                    .toList(),
              ),

              // ── Completed polygon preview ────────────────────────
              if (_points.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _points,
                      color: AppTheme.primaryGreen.withOpacity(0.25),
                      borderColor: AppTheme.primaryGreen,
                      borderStrokeWidth: 2.5,
                    ),
                  ],
                ),

              // ── Line connecting points while drawing ─────────────
              if (_points.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points,
                      color: AppTheme.primaryGreen,
                      strokeWidth: 2.5,
                    ),
                  ],
                ),

              // ── Point markers ────────────────────────────────────
              MarkerLayer(
                markers: _points.asMap().entries.map((entry) {
                  final isFirst = entry.key == 0;
                  return Marker(
                    point: entry.value,
                    width: isFirst ? 20 : 12,
                    height: isFirst ? 20 : 12,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFirst
                            ? AppTheme.accentAmber
                            : AppTheme.primaryGreen,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Instruction banner ─────────────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: DrawFieldToolbar(
              pointCount: _points.length,
              canClose: canClose,
              isSaving: _isSaving,
              onDone: canClose ? _confirmField : null,
            ),
          ),
        ],
      ),
    );
  }
}
