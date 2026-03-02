import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/api_config.dart';
import '../../../models/school.dart';
import '../../../providers/schools_provider.dart';
import '../../schools/school_profile_screen.dart';

class MapTab extends ConsumerStatefulWidget {
  const MapTab({super.key});

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  final MapController _mapController = MapController();
  String? _selectedPriority;
  double _currentZoom = 7.0;
  bool _clusteringEnabled = true;

  // AP center coordinates
  static const _apCenter = LatLng(15.9129, 79.7400);

  // Cluster radius in degrees (roughly) — decreases with zoom
  double get _clusterRadius {
    if (_currentZoom >= 12) return 0.01;
    if (_currentZoom >= 10) return 0.05;
    if (_currentZoom >= 8) return 0.15;
    return 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final schoolsAsync = ref.watch(schoolsProvider);

    return Stack(
      children: [
        schoolsAsync.when(
          data: (schools) => _buildMap(schools),
          loading: () => _buildMap([]),
          error: (_, __) => _buildMap([]),
        ),
        // Filter chips overlay
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton('All', null),
                const SizedBox(width: 8),
                _buildFilterButton('Critical', 'CRITICAL'),
                const SizedBox(width: 8),
                _buildFilterButton('High', 'HIGH'),
                const SizedBox(width: 8),
                _buildFilterButton('Medium', 'MEDIUM'),
                const SizedBox(width: 8),
                _buildFilterButton('Low', 'LOW'),
                const SizedBox(width: 8),
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _clusteringEnabled ? Icons.bubble_chart : Icons.scatter_plot,
                        size: 14,
                        color: _clusteringEnabled ? AppColors.primary : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(_clusteringEnabled ? 'Clustered' : 'All Points'),
                    ],
                  ),
                  selected: _clusteringEnabled,
                  onSelected: (v) => setState(() => _clusteringEnabled = v),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundColor: Colors.white,
                  elevation: 2,
                ),
              ],
            ),
          ),
        ),
        // Legend
        Positioned(
          bottom: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(AppColors.priorityCritical, 'Critical'),
                  _LegendDot(AppColors.priorityHigh, 'High'),
                  _LegendDot(AppColors.priorityMedium, 'Medium'),
                  _LegendDot(AppColors.priorityLow, 'Low'),
                  if (_clusteringEnabled) ...[
                    const SizedBox(height: 4),
                    const Divider(height: 1),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('n', style: TextStyle(
                                color: Colors.white, fontSize: 8)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Cluster', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Loading overlay
        if (schoolsAsync.isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  /// Simple grid-based clustering of nearby schools
  List<_SchoolCluster> _clusterSchools(List<School> schools) {
    if (!_clusteringEnabled || _currentZoom >= 12) {
      // No clustering at high zoom — return individual markers
      return schools
          .where((s) => s.hasLocation)
          .map((s) => _SchoolCluster(
                center: LatLng(s.latitude!, s.longitude!),
                schools: [s],
              ))
          .toList();
    }

    final radius = _clusterRadius;
    final clusters = <_SchoolCluster>[];
    final used = <int>{};

    final located = schools.where((s) => s.hasLocation).toList();

    for (var i = 0; i < located.length; i++) {
      if (used.contains(i)) continue;
      final s = located[i];
      final cluster = <School>[s];
      used.add(i);

      for (var j = i + 1; j < located.length; j++) {
        if (used.contains(j)) continue;
        final other = located[j];
        final dlat = (s.latitude! - other.latitude!).abs();
        final dlng = (s.longitude! - other.longitude!).abs();
        if (dlat < radius && dlng < radius) {
          cluster.add(other);
          used.add(j);
        }
      }

      // Compute cluster center
      final avgLat = cluster.fold<double>(0, (sum, sc) => sum + sc.latitude!) /
          cluster.length;
      final avgLng = cluster.fold<double>(0, (sum, sc) => sum + sc.longitude!) /
          cluster.length;

      clusters.add(_SchoolCluster(
        center: LatLng(avgLat, avgLng),
        schools: cluster,
      ));
    }

    return clusters;
  }

  Widget _buildMap(List<School> schools) {
    final filtered = _selectedPriority == null
        ? schools
        : schools
            .where((s) => s.priorityLevel == _selectedPriority)
            .toList();

    final clusters = _clusterSchools(filtered);

    final markers = clusters.map((c) {
      if (c.schools.length == 1) {
        return _buildMarker(c.schools.first);
      } else {
        return _buildClusterMarker(c);
      }
    }).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _apCenter,
        initialZoom: 7.0,
        minZoom: 5.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
          enableMultiFingerGestureRace: true,
        ),
        onPositionChanged: (pos, _) {
          if ((pos.zoom - _currentZoom).abs() > 0.5) {
            setState(() => _currentZoom = pos.zoom);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.schoolinfra.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Marker _buildClusterMarker(_SchoolCluster cluster) {
    // Use the worst priority color in the cluster
    Color clusterColor = AppColors.priorityLow;
    for (final s in cluster.schools) {
      if (s.priorityLevel == 'CRITICAL') {
        clusterColor = AppColors.priorityCritical;
        break;
      } else if (s.priorityLevel == 'HIGH') {
        clusterColor = AppColors.priorityHigh;
      } else if (s.priorityLevel == 'MEDIUM' &&
          clusterColor != AppColors.priorityHigh) {
        clusterColor = AppColors.priorityMedium;
      }
    }

    final size = cluster.schools.length <= 5
        ? 40.0
        : cluster.schools.length <= 15
            ? 48.0
            : 56.0;

    return Marker(
      point: cluster.center,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () {
          // Zoom into cluster
          _mapController.move(cluster.center, _currentZoom + 2);
        },
        child: Container(
          decoration: BoxDecoration(
            color: clusterColor.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: clusterColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${cluster.schools.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Marker _buildMarker(School school) {
    final color = school.priorityColor;
    return Marker(
      point: LatLng(school.latitude!, school.longitude!),
      width: 36,
      height: 36,
      child: GestureDetector(
        onTap: () => _showSchoolPopup(school),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  void _showSchoolPopup(School school) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: school.priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school, color: school.priorityColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school.schoolName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${school.mandalName ?? ''}, ${school.districtName ?? ''}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (school.priorityLevel != null)
                  Chip(
                    label: Text(
                      AppConstants.priorityLabel(school.priorityLevel!),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    backgroundColor: school.priorityColor,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoItem('Category', school.categoryLabel),
                _InfoItem('Management', school.managementLabel),
                _InfoItem(
                    'Enrolment', '${school.totalEnrolment ?? "N/A"}'),
                _InfoItem('Score',
                    school.priorityScore?.toStringAsFixed(0) ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SchoolProfileScreen(school: school),
                  ));
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String? priority) {
    final isSelected = _selectedPriority == priority;
    final color = priority != null
        ? AppColors.forPriority(priority)
        : AppColors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedPriority = priority),
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      elevation: 2,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

/// Represents a group of nearby schools on the map
class _SchoolCluster {
  final LatLng center;
  final List<School> schools;

  const _SchoolCluster({required this.center, required this.schools});
}
