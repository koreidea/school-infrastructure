import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../models/school.dart';
import '../../../providers/schools_provider.dart';
import '../../schools/school_profile_screen.dart';

class SchoolsTab extends ConsumerWidget {
  const SchoolsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(filteredSchoolsProvider);
    ref.watch(searchQueryProvider);

    final districtsAsync = ref.watch(districtsProvider);
    final mandalsAsync = ref.watch(mandalsProvider);
    final selectedDistrict = ref.watch(effectiveDistrictProvider);
    final selectedMandal = ref.watch(effectiveMandalProvider);
    final canChangeDistrict = ref.watch(canChangeDistrictFilterProvider);
    final canChangeMandal = ref.watch(canChangeMandalFilterProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search schools...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).set(v),
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(ref: ref),
            ],
          ),
        ),
        // District & Mandal filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // District dropdown
              Expanded(
                child: districtsAsync.when(
                  data: (districts) => DropdownButtonFormField<int?>(
                    key: ValueKey('district_$selectedDistrict'),
                    initialValue: selectedDistrict,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: canChangeDistrict ? 'District' : 'District (locked)',
                      prefixIcon: Icon(
                        canChangeDistrict ? Icons.location_city : Icons.lock,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Districts',
                            style: TextStyle(fontSize: 13)),
                      ),
                      ...districts.map((d) => DropdownMenuItem<int?>(
                            value: d.id,
                            child: Text(d.name,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: canChangeDistrict
                        ? (v) {
                            ref.read(selectedDistrictProvider.notifier).set(v);
                            ref.read(selectedMandalProvider.notifier).set(null);
                          }
                        : null,
                  ),
                  loading: () => const SizedBox(
                      height: 48,
                      child: Center(
                          child: LinearProgressIndicator())),
                  error: (_, __) => const Text('Error loading districts'),
                ),
              ),
              const SizedBox(width: 8),
              // Mandal dropdown
              Expanded(
                child: mandalsAsync.when(
                  data: (mandals) => DropdownButtonFormField<int?>(
                    key: ValueKey('mandal_$selectedMandal'),
                    initialValue: selectedMandal,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: canChangeMandal ? 'Mandal' : 'Mandal (locked)',
                      prefixIcon: Icon(
                        canChangeMandal ? Icons.location_on : Icons.lock,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Mandals',
                            style: TextStyle(fontSize: 13)),
                      ),
                      ...mandals.map((m) => DropdownMenuItem<int?>(
                            value: m.id,
                            child: Text(m.name,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: canChangeMandal
                        ? (v) {
                            ref.read(selectedMandalProvider.notifier).set(v);
                          }
                        : null,
                  ),
                  loading: () => const SizedBox(
                      height: 48,
                      child: Center(
                          child: LinearProgressIndicator())),
                  error: (_, __) => const Text('Error loading mandals'),
                ),
              ),
            ],
          ),
        ),
        // Active filter indicators
        if (selectedDistrict != null || selectedMandal != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  canChangeDistrict ? 'Filtered' : 'Role-based filter active',
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
                const Spacer(),
                if (canChangeDistrict)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(selectedDistrictProvider.notifier).set(null);
                      ref.read(selectedMandalProvider.notifier).set(null);
                    },
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear Filters', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 28),
                    ),
                  ),
              ],
            ),
          ),
        // School list
        Expanded(
          child: schoolsAsync.when(
            data: (schools) {
              if (schools.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No schools found'),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          '${schools.length} school${schools.length != 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: schools.length,
                      itemBuilder: (ctx, i) =>
                          _SchoolCard(school: schools[i]),
                    ),
                  ),
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final WidgetRef ref;
  const _FilterChip({required this.ref});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
      onSelected: (value) {
        if (value == 'ALL') {
          ref.read(selectedPriorityProvider.notifier).set(null);
        } else {
          ref.read(selectedPriorityProvider.notifier).set(value);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'ALL', child: Text('All Schools')),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'CRITICAL',
          child: Row(children: [
            Container(width: 12, height: 12, color: AppColors.priorityCritical),
            const SizedBox(width: 8),
            const Text('Critical'),
          ]),
        ),
        PopupMenuItem(
          value: 'HIGH',
          child: Row(children: [
            Container(width: 12, height: 12, color: AppColors.priorityHigh),
            const SizedBox(width: 8),
            const Text('High Priority'),
          ]),
        ),
        PopupMenuItem(
          value: 'MEDIUM',
          child: Row(children: [
            Container(width: 12, height: 12, color: AppColors.priorityMedium),
            const SizedBox(width: 8),
            const Text('Medium Priority'),
          ]),
        ),
        PopupMenuItem(
          value: 'LOW',
          child: Row(children: [
            Container(width: 12, height: 12, color: AppColors.priorityLow),
            const SizedBox(width: 8),
            const Text('Low Priority'),
          ]),
        ),
      ],
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final School school;
  const _SchoolCard({required this.school});

  @override
  Widget build(BuildContext context) {
    final priorityColor = school.priorityColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SchoolProfileScreen(school: school),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Priority indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // School info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.schoolName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${school.mandalName ?? ''}, ${school.districtName ?? ''}',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Tag(school.categoryLabel, AppColors.primary),
                        const SizedBox(width: 8),
                        if (school.totalEnrolment != null)
                          Text('${school.totalEnrolment} students',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              // Priority badge
              if (school.priorityLevel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        school.priorityScore?.toStringAsFixed(0) ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        school.priorityLevel ?? '',
                        style: TextStyle(
                            fontSize: 9, color: priorityColor),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child:
          Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }
}
