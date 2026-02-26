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

  // AP center coordinates
  static const _apCenter = LatLng(15.9129, 79.7400);

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

  Widget _buildMap(List<School> schools) {
    final filtered = _selectedPriority == null
        ? schools
        : schools
            .where((s) => s.priorityLevel == _selectedPriority)
            .toList();

    final markers = filtered
        .where((s) => s.hasLocation)
        .map((s) => _buildMarker(s))
        .toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _apCenter,
        initialZoom: 7.0,
        minZoom: 5.0,
        maxZoom: 18.0,
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
