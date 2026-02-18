import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/children_provider.dart';
import '../../../providers/intervention_provider.dart';
import '../../../providers/screening_results_storage.dart';
import '../../../services/supabase_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../utils/telugu_transliterator.dart';
import '../../children/child_list_screen.dart';
import '../../children/child_profile_screen.dart';
import '../../children/child_status_card.dart';
import '../../interventions/activity_list_screen.dart';
import '../../profile/profile_edit_screen.dart';
import '../../../models/user.dart';

/// Enhanced Parent Dashboard — child-friendly, simplified risk indicators,
/// next appointment, tips, and activity tracking.
class ParentHomeTab extends ConsumerStatefulWidget {
  const ParentHomeTab({super.key});

  @override
  ConsumerState<ParentHomeTab> createState() => _ParentHomeTabState();
}

class _ParentHomeTabState extends ConsumerState<ParentHomeTab> {
  // Follow-up data per child: {childId: {next_followup_date, improvement_status, ...}}
  Map<int, Map<String, dynamic>> _followupData = {};
  bool _followupLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFollowupData();
  }

  Future<void> _loadFollowupData() async {
    try {
      final children = ref.read(childrenProvider).value ?? [];
      final childIds = children.map((c) => c['child_id'] as int).toList();
      if (childIds.isEmpty) return;

      if (ConnectivityService.isOnline) {
        final data = await SupabaseService.client
            .from('intervention_followups')
            .select()
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);

        final map = <int, Map<String, dynamic>>{};
        for (final row in data) {
          final cid = row['child_id'] as int;
          if (!map.containsKey(cid)) {
            map[cid] = row;
          }
        }
        if (mounted) {
          setState(() {
            _followupData = map;
            _followupLoaded = true;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _followupLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final childrenAsync = ref.watch(childrenProvider);
    final localResults = ref.watch(screeningResultsStorageProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(childrenProvider);
        ref.invalidate(screeningResultsStorageProvider);
        await _loadFollowupData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(user, isTelugu),
            const SizedBox(height: 20),

            // Next Appointment Card
            _buildNextAppointmentCard(childrenAsync, isTelugu),
            const SizedBox(height: 20),

            // My Children Section with simplified risk
            _buildSectionHeader(
              isTelugu ? 'నా పిల్లలు' : 'My Children',
              isTelugu ? 'అన్నీ చూడండి' : 'View All',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChildListScreen())),
            ),
            const SizedBox(height: 12),
            _buildChildrenCards(childrenAsync, localResults, isTelugu),
            const SizedBox(height: 20),

            // Today's Activities
            _buildSectionHeader(
              isTelugu ? 'నేటి కార్యకలాపాలు' : "Today's Activities",
              null,
              null,
            ),
            const SizedBox(height: 12),
            _buildTodaysActivities(childrenAsync, localResults, isTelugu),
            const SizedBox(height: 20),

            // Development Progress
            Text(
              isTelugu ? 'అభివృద్ధి పురోగతి' : 'Development Progress',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDevelopmentProgress(childrenAsync, localResults, isTelugu),
            const SizedBox(height: 20),

            // Developmental Tips
            _buildTipsCard(isTelugu),
            const SizedBox(height: 20),

            // Emergency Helpline (if any child is HIGH risk)
            _buildEmergencyCard(childrenAsync, localResults, isTelugu),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── WELCOME CARD ───────────────────────────────────────────────────

  Widget _buildWelcomeCard(dynamic user, bool isTelugu) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF6A3DE8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                backgroundImage: user?.profilePhotoUrl != null
                    ? NetworkImage(user!.profilePhotoUrl!)
                    : null,
                child: user?.profilePhotoUrl == null
                    ? const Icon(Icons.family_restroom,
                        size: 30, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTelugu ? 'స్వాగతం' : 'Welcome',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      isTelugu
                          ? toTelugu(user?.name ?? 'Parent')
                          : (user?.name ?? 'Parent'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTelugu
                          ? 'మీ బిడ్డ అభివృద్ధిని ట్రాక్ చేయండి'
                          : 'Track your child\'s development',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  // ─── NEXT APPOINTMENT CARD ──────────────────────────────────────────

  Widget _buildNextAppointmentCard(
      AsyncValue<List<Map<String, dynamic>>> childrenAsync, bool isTelugu) {
    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty || !_followupLoaded) {
          return const SizedBox.shrink();
        }

        // Find the nearest upcoming followup
        DateTime? nearestDate;
        String? childName;
        for (final child in children) {
          final cid = child['child_id'] as int;
          final fu = _followupData[cid];
          if (fu != null && fu['next_followup_date'] != null) {
            final dt = DateTime.tryParse(fu['next_followup_date'].toString());
            if (dt != null && (nearestDate == null || dt.isBefore(nearestDate))) {
              nearestDate = dt;
              childName = isTelugu
                  ? toTelugu(child['name'] ?? '')
                  : (child['name'] ?? '');
            }
          }
        }

        if (nearestDate == null) return const SizedBox.shrink();

        final daysUntil = nearestDate.difference(DateTime.now()).inDays;
        final isOverdue = daysUntil < 0;
        final isSoon = daysUntil <= 3 && daysUntil >= 0;

        String dateText;
        if (daysUntil == 0) {
          dateText = isTelugu ? 'ఈ రోజు' : 'Today';
        } else if (daysUntil == 1) {
          dateText = isTelugu ? 'రేపు' : 'Tomorrow';
        } else if (isOverdue) {
          dateText = isTelugu
              ? '${-daysUntil} రోజులు ఆలస్యం'
              : '${-daysUntil} days overdue';
        } else {
          dateText = isTelugu
              ? '$daysUntil రోజులలో'
              : 'In $daysUntil days';
        }

        final bgColor = isOverdue
            ? AppColors.riskHigh.withValues(alpha: 0.1)
            : isSoon
                ? Colors.orange.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.08);
        final iconColor = isOverdue
            ? AppColors.riskHigh
            : isSoon
                ? Colors.orange
                : AppColors.primary;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: bgColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.calendar_today, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'తదుపరి ఫాలో-అప్' : 'Next Follow-up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$childName — $dateText',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '${nearestDate.day}/${nearestDate.month}/${nearestDate.year}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isOverdue
                      ? Icons.warning_amber_rounded
                      : Icons.event_available,
                  color: iconColor,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── SECTION HEADER ─────────────────────────────────────────────────

  Widget _buildSectionHeader(
      String title, String? actionText, VoidCallback? onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (actionText != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionText)),
      ],
    );
  }

  // ─── CHILDREN CARDS (simplified risk) ───────────────────────────────

  Widget _buildChildrenCards(
    AsyncValue<List<Map<String, dynamic>>> childrenAsync,
    Map<int, SavedScreeningResult> localResults,
    bool isTelugu,
  ) {
    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.child_care,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      isTelugu ? 'ఇంకా పిల్లలు లేరు' : 'No children added yet',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          children: children.map((child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ChildStatusCard(
                childData: child,
                result: localResults[child['child_id'] as int],
                followup: _followupData[child['child_id'] as int],
                isTelugu: isTelugu,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChildProfileScreen(child: Child.fromMap(child)),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () =>
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  // ─── TODAY'S ACTIVITIES ─────────────────────────────────────────────

  Widget _buildTodaysActivities(
    AsyncValue<List<Map<String, dynamic>>> childrenAsync,
    Map<int, SavedScreeningResult> localResults,
    bool isTelugu,
  ) {
    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return _placeholderCard(
              isTelugu
                  ? 'కార్యకలాపాలను చూడటానికి స్క్రీనింగ్ పూర్తి చేయండి'
                  : 'Complete a screening to see activities',
              Icons.fitness_center);
        }

        // Collect ALL children with screening results
        final screenedChildren = <Map<String, dynamic>>[];
        for (final c in children) {
          final cid = c['child_id'] as int;
          if (localResults.containsKey(cid)) {
            screenedChildren.add(c);
          }
        }

        if (screenedChildren.isEmpty) {
          return _placeholderCard(
              isTelugu
                  ? 'కార్యకలాపాలను చూడటానికి స్క్రీనింగ్ పూర్తి చేయండి'
                  : 'Complete a screening to see activities',
              Icons.fitness_center);
        }

        // Show activities for each child
        return Column(
          children: screenedChildren.map((child) {
            final childId = child['child_id'] as int;
            final ageMonths = child['age_months'] as int? ?? 0;
            final childName = isTelugu
                ? toTelugu(child['name'] ?? '')
                : (child['name'] ?? '');

            return _buildChildActivitiesSection(
                childId, ageMonths, childName, child, isTelugu);
          }).toList(),
        );
      },
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildChildActivitiesSection(
    int childId,
    int ageMonths,
    String childName,
    Map<String, dynamic> childData,
    bool isTelugu,
  ) {
    final activitiesAsync = ref.watch(
        recommendedActivitiesProvider((childId, ageMonths, null)));

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              color: AppColors.riskLow.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.celebration,
                        color: AppColors.riskLow, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$childName — ${isTelugu ? 'అన్ని రంగాలు బాగున్నాయి!' : 'All on track!'}',
                        style: const TextStyle(
                            color: AppColors.riskLow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                childName,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
              ),
            ),
            ...activities.take(2).map((a) => _ParentActivityCard(
                  activity: a,
                  isTelugu: isTelugu,
                  onTap: () =>
                      showActivityDetailSheet(context, a, isTelugu),
                )),
            if (activities.length > 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActivityListScreen(
                        childId: childId,
                        child: childData,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(isTelugu
                      ? 'మరిన్ని చూడండి'
                      : 'See more'),
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── DEVELOPMENT PROGRESS ───────────────────────────────────────────

  Widget _buildDevelopmentProgress(
    AsyncValue<List<Map<String, dynamic>>> childrenAsync,
    Map<int, SavedScreeningResult> localResults,
    bool isTelugu,
  ) {
    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return _placeholderCard(
              isTelugu
                  ? 'పురోగతి చూడటానికి స్క్రీనింగ్ పూర్తి చేయండి'
                  : 'Complete a screening to see progress',
              Icons.show_chart);
        }

        // Collect ALL children with screening results
        final screenedChildren = <MapEntry<Map<String, dynamic>, SavedScreeningResult>>[];
        for (final c in children) {
          final cid = c['child_id'] as int;
          final result = localResults[cid];
          if (result != null) {
            screenedChildren.add(MapEntry(c, result));
          }
        }

        if (screenedChildren.isEmpty) {
          return _placeholderCard(
              isTelugu
                  ? 'పురోగతి చూడటానికి స్క్రీనింగ్ పూర్తి చేయండి'
                  : 'Complete a screening to see progress',
              Icons.show_chart);
        }

        return Column(
          children: screenedChildren.map((entry) {
            final child = entry.key;
            final result = entry.value;
            final childName = isTelugu
                ? toTelugu(child['name'] ?? '')
                : (child['name'] ?? '');
            return _buildChildProgressCard(childName, result, isTelugu);
          }).toList(),
        );
      },
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildChildProgressCard(String childName, SavedScreeningResult result, bool isTelugu) {
    final domains = [
      {'key': 'gm', 'en': 'Gross Motor', 'te': 'స్థూల చలనం', 'icon': Icons.directions_run},
      {'key': 'fm', 'en': 'Fine Motor', 'te': 'సూక్ష్మ చలనం', 'icon': Icons.pan_tool_alt},
      {'key': 'lc', 'en': 'Language', 'te': 'భాష', 'icon': Icons.record_voice_over},
      {'key': 'cog', 'en': 'Thinking', 'te': 'ఆలోచన', 'icon': Icons.psychology},
      {'key': 'se', 'en': 'Social Skills', 'te': 'సామాజిక నైపుణ్యాలు', 'icon': Icons.people},
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(childName,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...domains.map((d) {
              final dq = result.domainDqScores['${d['key']}_dq'] ?? 0.0;
              final isDelayed =
                  result.domainDelays['${d['key']}_delay'] ?? false;
              final value = (dq / 100).clamp(0.0, 1.0);
              final color =
                  isDelayed ? AppColors.riskHigh : AppColors.riskLow;
              final icon = d['icon'] as IconData;

              // Parent-friendly status
              String status;
              if (dq >= 85) {
                status = isTelugu ? 'బాగుంది' : 'On Track';
              } else if (dq >= 70) {
                status = isTelugu ? 'కొంచెం ఆలస్యం' : 'Needs Support';
              } else {
                status = isTelugu ? 'సహాయం అవసరం' : 'Needs Attention';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isTelugu
                                    ? d['te'] as String
                                    : d['en'] as String,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── TIPS CARD ──────────────────────────────────────────────────────

  Widget _buildTipsCard(bool isTelugu) {
    final tips = isTelugu
        ? [
            'రోజూ 15 నిమిషాలు మీ బిడ్డతో ఆడుకోండి',
            'మీ బిడ్డతో బొమ్మల పుస్తకాలు చదవండి',
            'మీ బిడ్డ చేసే ప్రతి చిన్న విజయాన్ని ప్రశంసించండి',
            'మీ బిడ్డతో రంగులు, ఆకారాల గురించి మాట్లాడండి',
          ]
        : [
            'Play with your child for 15 minutes every day',
            'Read picture books together with your child',
            'Praise every small achievement your child makes',
            'Talk to your child about colors, shapes, and objects',
          ];

    // Use day of year to cycle tips
    final tipIndex = DateTime.now().difference(DateTime(2025)).inDays % tips.length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTelugu ? 'నేటి చిట్కా' : "Today's Tip",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF795548),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tips[tipIndex],
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF5D4037), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── EMERGENCY CARD (shown only if HIGH risk) ───────────────────────

  Widget _buildEmergencyCard(
    AsyncValue<List<Map<String, dynamic>>> childrenAsync,
    Map<int, SavedScreeningResult> localResults,
    bool isTelugu,
  ) {
    return childrenAsync.when(
      data: (children) {
        final hasHighRisk = children.any((c) {
          final r = localResults[c['child_id'] as int];
          return r != null && r.overallRisk == 'HIGH';
        });

        if (!hasHighRisk) return const SizedBox.shrink();

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.riskHigh.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.riskHigh.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_hospital,
                      color: AppColors.riskHigh, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu
                            ? 'ముఖ్యమైన సమాచారం'
                            : 'Important Information',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.riskHigh,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTelugu
                            ? 'మీ బిడ్డకు అదనపు మద్దతు అవసరం. దయచేసి మీ AWW లేదా నజీకి ఆరోగ్య కేంద్రాన్ని సంప్రదించండి.'
                            : 'Your child needs additional support. Please contact your AWW or nearest health centre for guidance.',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.riskHigh, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 16, color: AppColors.riskHigh),
                          const SizedBox(width: 4),
                          Text(
                            isTelugu ? 'RBSK హెల్ప్‌లైన్: 104' : 'RBSK Helpline: 104',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.riskHigh,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── HELPER ─────────────────────────────────────────────────────────

  Widget _placeholderCard(String message, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ACTIVITY CARD — Parent-friendly with large tap targets
// ══════════════════════════════════════════════════════════════════════════

class _ParentActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final bool isTelugu;
  final VoidCallback onTap;

  const _ParentActivityCard({
    required this.activity,
    required this.isTelugu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final domain = activity['domain'] as String? ?? '';
    final title = isTelugu
        ? (activity['activity_title_te'] ?? activity['activity_title'] ?? '')
        : (activity['activity_title'] ?? '');
    final duration = activity['duration_minutes'] as int? ?? 15;
    final materials = isTelugu
        ? (activity['materials_needed_te'] ?? activity['materials_needed'] ?? '')
        : (activity['materials_needed'] ?? '');
    final domainColor = getDomainColor(domain);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: domainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(getDomainIcon(domain), color: domainColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('$duration ${isTelugu ? 'నిమి' : 'min'}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: domainColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            getDomainDisplayName(domain, isTelugu),
                            style: TextStyle(
                                fontSize: 11,
                                color: domainColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    if (materials.toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              materials.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
