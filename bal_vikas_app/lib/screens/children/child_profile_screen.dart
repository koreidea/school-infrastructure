import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/screening_results_storage.dart';
import '../../services/database_service.dart';
import '../screening/screening_start_screen.dart';
import '../interventions/activity_list_screen.dart';
import '../../utils/telugu_transliterator.dart';
import '../../services/audit_service.dart';
import '../../widgets/consent_status_banner.dart';
import 'child_progress_section.dart';

class ChildProfileScreen extends ConsumerStatefulWidget {
  final Child child;

  const ChildProfileScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen> {
  List<Map<String, dynamic>> _screeningHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreeningHistory();
    // Audit: log child profile view
    AuditService.log(
      action: 'view_child',
      entityType: 'child',
      entityId: widget.child.childId,
      entityName: widget.child.name,
    );
  }

  Future<void> _loadScreeningHistory() async {
    // Load latest screening result from Drift DB and update in-memory storage
    if (!kIsWeb) {
      try {
        final db = DatabaseService.db;
        final driftResult = await db.screeningDao
            .getLatestResultForChildByRemoteId(widget.child.childId);
        if (driftResult != null) {
          final existing = ref.read(screeningResultsStorageProvider)[widget.child.childId];
          // Use Drift result if no in-memory result, or if Drift result is newer/same time
          if (existing == null || !existing.date.isAfter(driftResult.createdAt)) {
            final domainDqs = <String, double>{};
            final domainDelays = <String, bool>{};
            if (driftResult.gmDq != null) { domainDqs['gm_dq'] = driftResult.gmDq!; domainDelays['gm_delay'] = driftResult.gmDq! < 85; }
            if (driftResult.fmDq != null) { domainDqs['fm_dq'] = driftResult.fmDq!; domainDelays['fm_delay'] = driftResult.fmDq! < 85; }
            if (driftResult.lcDq != null) { domainDqs['lc_dq'] = driftResult.lcDq!; domainDelays['lc_delay'] = driftResult.lcDq! < 85; }
            if (driftResult.cogDq != null) { domainDqs['cog_dq'] = driftResult.cogDq!; domainDelays['cog_delay'] = driftResult.cogDq! < 85; }
            if (driftResult.seDq != null) { domainDqs['se_dq'] = driftResult.seDq!; domainDelays['se_delay'] = driftResult.seDq! < 85; }

            final concerns = driftResult.concernsJson != null
                ? (jsonDecode(driftResult.concernsJson!) as List).cast<String>()
                : <String>[];
            final concernsTe = driftResult.concernsTeJson != null
                ? (jsonDecode(driftResult.concernsTeJson!) as List).cast<String>()
                : <String>[];

            ref.read(screeningResultsStorageProvider.notifier).saveResult(
              widget.child.childId,
              SavedScreeningResult(
                childId: widget.child.childId,
                date: driftResult.createdAt,
                overallRisk: driftResult.overallRisk,
                overallRiskTe: driftResult.overallRiskTe,
                referralNeeded: driftResult.referralNeeded,
                domainDqScores: domainDqs,
                domainDelays: domainDelays,
                concerns: concerns,
                concernsTe: concernsTe,
                toolsCompleted: driftResult.toolsCompleted,
                toolsSkipped: driftResult.toolsSkipped,
              ),
            );
          }
        }
      } catch (_) {}
    }

    try {
      final history = await ref.read(
        childScreeningsProvider(widget.child.childId).future,
      );
      if (mounted) {
        setState(() {
          _screeningHistory = history;
          _isLoading = false;
        });
      }

      // If no result yet but backend history has data, use latest backend entry
      final currentResult = ref.read(screeningResultsStorageProvider)[widget.child.childId];
      if (currentResult == null && history.isNotEmpty) {
        final latest = history.first;
        final risk = latest['overall_risk'] as String? ?? 'LOW';
        final domainDqs = <String, double>{};
        final domainDelays = <String, bool>{};
        if (latest['gm_dq'] != null) { domainDqs['gm_dq'] = (latest['gm_dq'] as num).toDouble(); domainDelays['gm_delay'] = domainDqs['gm_dq']! < 85; }
        if (latest['fm_dq'] != null) { domainDqs['fm_dq'] = (latest['fm_dq'] as num).toDouble(); domainDelays['fm_delay'] = domainDqs['fm_dq']! < 85; }
        if (latest['lc_dq'] != null) { domainDqs['lc_dq'] = (latest['lc_dq'] as num).toDouble(); domainDelays['lc_delay'] = domainDqs['lc_dq']! < 85; }
        if (latest['cog_dq'] != null) { domainDqs['cog_dq'] = (latest['cog_dq'] as num).toDouble(); domainDelays['cog_delay'] = domainDqs['cog_dq']! < 85; }
        if (latest['se_dq'] != null) { domainDqs['se_dq'] = (latest['se_dq'] as num).toDouble(); domainDelays['se_delay'] = domainDqs['se_dq']! < 85; }

        ref.read(screeningResultsStorageProvider.notifier).saveResult(
          widget.child.childId,
          SavedScreeningResult(
            childId: widget.child.childId,
            date: DateTime.tryParse(latest['created_at'] as String? ?? '') ?? DateTime.now(),
            overallRisk: risk,
            overallRiskTe: '',
            referralNeeded: (latest['referral_needed'] as bool?) ?? risk == 'HIGH',
            domainDqScores: domainDqs,
            domainDelays: domainDelays,
            concerns: const [],
            concernsTe: const [],
            toolsCompleted: (latest['tools_completed'] as int?) ?? 0,
            toolsSkipped: (latest['tools_skipped'] as int?) ?? 0,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = ref.watch(languageProvider) == 'te';
    final child = widget.child;

    // Check local screening results
    final savedResult = ref.watch(screeningResultsStorageProvider)[child.childId];

    // Check if child has any screenings (local or backend)
    final hasScreenings = savedResult != null || _screeningHistory.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu
            ? '${toTelugu(child.name)} ప్రొఫైల్'
            : '${child.name}\'s Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
                  onRefresh: _loadScreeningHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Consent Status Banner
                        ConsentStatusBanner(
                          childRemoteId: widget.child.childId,
                          child: {
                            'child_id': widget.child.childId,
                            'name': widget.child.name,
                            'date_of_birth': widget.child.dateOfBirth,
                            'gender': widget.child.gender,
                          },
                        ),
                        // Child Header Card
                        _buildChildHeaderCard(child, isTelugu),
                        const SizedBox(height: 24),

                        if (!hasScreenings) ...[
                          // No screening yet - show prompt
                          _buildFirstScreeningPrompt(isTelugu),
                        ] else ...[
                          // Has screenings - show all stats
                          // Risk Status Card
                          _buildRiskStatusCard(isTelugu, savedResult),
                          const SizedBox(height: 24),

                          // Development Stats
                          _buildDevelopmentStatsCard(isTelugu, savedResult),
                          const SizedBox(height: 24),

                          // Progress Section (DQ trend, risk change, referrals)
                          ChildProgressSection(
                            childRemoteId: widget.child.childId,
                            isTelugu: isTelugu,
                          ),
                          const SizedBox(height: 24),

                          // Concerns from screening
                          if (savedResult != null && savedResult.concerns.isNotEmpty) ...[
                            _buildConcernsCard(isTelugu, savedResult),
                            const SizedBox(height: 24),
                          ],

                          // Screening History
                          _buildScreeningHistoryCard(isTelugu, savedResult),
                          const SizedBox(height: 24),
                        ],

                        // Action Buttons
                        _buildActionButtons(isTelugu),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildChildHeaderCard(Child child, bool isTelugu) {
    final ageText = '${child.currentAgeMonths} ${isTelugu ? 'నెలలు' : 'months'}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: child.photoUrl != null 
                  ? NetworkImage(child.photoUrl!) 
                  : null,
              child: child.photoUrl == null
                  ? const Icon(Icons.child_care, size: 40, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTelugu ? toTelugu(child.name) : child.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isTelugu ? 'వయస్సు' : 'Age'}: $ageText',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isTelugu ? 'జెండర్' : 'Gender'}: ${child.gender == 'male' 
                        ? (isTelugu ? 'మగ' : 'Male') 
                        : (isTelugu ? 'ఆడ' : 'Female')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isTelugu ? 'ID' : 'ID'}: ${child.childUniqueId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskStatusCard(bool isTelugu, SavedScreeningResult? savedResult) {
    final overallRisk = savedResult?.overallRisk ?? 'LOW';
    final referralNeeded = savedResult?.referralNeeded ?? false;
    final riskColor = _getRiskColor(overallRisk);
    final riskText = _getRiskText(overallRisk, isTelugu);

    return Card(
      color: riskColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  overallRisk == 'LOW' ? Icons.check_circle : Icons.warning_amber,
                  color: riskColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'మొత్తం ప్రమాదం' : 'Overall Risk',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        riskText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (savedResult != null)
                  Column(
                    children: [
                      Text(
                        '${savedResult.toolsCompleted}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: riskColor),
                      ),
                      Text(
                        isTelugu ? 'సాధనాలు' : 'tools',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (referralNeeded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.riskHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.medical_services, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isTelugu ? 'రెఫరల్ అవసరం' : 'Referral Needed',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentStatsCard(bool isTelugu, SavedScreeningResult? savedResult) {
    final domains = [
      {'key': 'gm', 'nameEn': 'Gross Motor', 'nameTe': 'స్థూల చలనం', 'icon': Icons.directions_run},
      {'key': 'fm', 'nameEn': 'Fine Motor', 'nameTe': 'సూక్ష్మ చలనం', 'icon': Icons.back_hand},
      {'key': 'lc', 'nameEn': 'Language', 'nameTe': 'భాష', 'icon': Icons.record_voice_over},
      {'key': 'cog', 'nameEn': 'Cognitive', 'nameTe': 'జ్ఞానాత్మకం', 'icon': Icons.psychology},
      {'key': 'se', 'nameEn': 'Social-Emotional', 'nameTe': 'సామాజిక-భావోద్వేగ', 'icon': Icons.people},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'అభివృద్ధి గణాంకాలు' : 'Development Stats',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...domains.map((domain) {
              final key = domain['key'] as String;
              final dq = savedResult?.domainDqScores['${key}_dq'];

              // 3-tier DQ coloring: green >= 85, orange 70-84, red < 70
              Color dqColor(double v) {
                if (v >= 85) return AppColors.riskLow;
                if (v >= 70) return AppColors.riskMedium;
                return AppColors.riskHigh;
              }

              final barColor = dq != null ? dqColor(dq as double) : AppColors.riskLow;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(domain['icon'] as IconData, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTelugu ? domain['nameTe'] as String : domain['nameEn'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (dq != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: ((dq as double) / 100).clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'DQ: ${dq.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: barColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (dq != null && (dq as double) < 70)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.riskHigh.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isTelugu ? 'ఆలస్యం' : 'Delay',
                          style: const TextStyle(
                            color: AppColors.riskHigh,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (dq != null && (dq as double) < 85)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.riskMedium.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isTelugu ? 'తేలిక ఆలస్యం' : 'Mild Delay',
                          style: const TextStyle(
                            color: AppColors.riskMedium,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (dq != null)
                      const Icon(Icons.check_circle, color: AppColors.riskLow, size: 20),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreeningHistoryCard(bool isTelugu, SavedScreeningResult? savedResult) {
    // Build screening list: local results + backend screenings
    final screenings = <Map<String, dynamic>>[];

    if (savedResult != null) {
      screenings.add({
        'status': 'completed',
        'assessment_date': '${savedResult.date.year}-${savedResult.date.month.toString().padLeft(2, '0')}-${savedResult.date.day.toString().padLeft(2, '0')}',
        'child_age_months': widget.child.currentAgeMonths,
        'tools_completed': savedResult.toolsCompleted,
        'overall_risk': savedResult.overallRisk,
        'is_local': true,
      });
    }

    for (final s in _screeningHistory) {
      // Skip if same session as local result (avoid duplicate)
      if (savedResult != null && s['is_local'] == true) continue;
      screenings.add(s);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  isTelugu ? 'స్క్రీనింగ్ చరిత్ర' : 'Screening History',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (screenings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isTelugu ? 'ఇంకా స్క్రీనింగ్ లేదు' : 'No screenings yet',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...screenings.take(3).map((s) {
                final isCompleted = s['status'] == 'completed';
                final risk = s['overall_risk'] as String?;
                final riskColor = risk != null ? _getRiskColor(risk) : null;
                return ListTile(
                  leading: Icon(
                    isCompleted ? Icons.check_circle : Icons.pending,
                    color: isCompleted ? (riskColor ?? AppColors.riskLow) : AppColors.riskMedium,
                  ),
                  title: Text('${s['assessment_date']}'),
                  subtitle: Text(
                    '${s['child_age_months']} ${isTelugu ? 'నెలలు' : 'months'}'
                    '${s['tools_completed'] != null ? ' • ${s['tools_completed']} ${isTelugu ? 'సాధనాలు' : 'tools'}' : ''}',
                  ),
                  trailing: risk != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskColor!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getRiskText(risk, isTelugu),
                            style: TextStyle(
                              fontSize: 11,
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const Icon(Icons.chevron_right),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildConcernsCard(bool isTelugu, SavedScreeningResult savedResult) {
    final concerns = isTelugu ? savedResult.concernsTe : savedResult.concerns;
    if (concerns.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  isTelugu ? 'ఆందోళనలు' : 'Concerns',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...concerns.take(5).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(c, style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isTelugu) {
    final isParent = ref.watch(currentUserProvider)?.isParent ?? false;

    return Column(
      children: [
        if (!isParent) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScreeningStartScreen(
                      child: {
                        'child_id': widget.child.childId,
                        'child_unique_id': widget.child.childUniqueId,
                        'name': widget.child.name,
                        'date_of_birth': widget.child.dateOfBirth.toIso8601String().split('T')[0],
                        'gender': widget.child.gender,
                        'age_months': widget.child.currentAgeMonths,
                        'photo_url': widget.child.photoUrl,
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.assessment),
              label: Text(
                isTelugu ? 'కొత్త స్క్రీనింగ్ ప్రారంభించండి' : 'Start New Screening',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityListScreen(
                    childId: widget.child.childId,
                    child: {
                      'child_id': widget.child.childId,
                      'name': widget.child.name,
                      'age_months': widget.child.currentAgeMonths,
                    },
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            icon: const Icon(Icons.sports_esports),
            label: Text(
              isTelugu ? 'కార్యకలాపాలు చూడండి' : 'View Activities',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstScreeningPrompt(bool isTelugu) {
    final isParent = ref.watch(currentUserProvider)?.isParent ?? false;

    return Card(
      color: AppColors.primaryLight.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.assessment_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isTelugu
                  ? 'ఇంకా స్క్రీనింగ్ చేయబడలేదు'
                  : 'No Screening Done Yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isParent
                  ? (isTelugu
                      ? 'మీ పిల్లవాడికి ఇంకా స్క్రీనింగ్ చేయబడలేదు. AWW ద్వారా స్క్రీనింగ్ నిర్వహించబడుతుంది.'
                      : 'No screening has been done yet. Screening will be conducted by the AWW.')
                  : (isTelugu
                      ? 'మీ పిల్లవాడి అభివృద్ధి మూల్యాంకనం చేయడానికి మొదటి స్క్రీనింగ్ ప్రారంభించండి'
                      : 'Start the first screening to assess your child\'s development'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isParent) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreeningStartScreen(
                          child: {
                            'child_id': widget.child.childId,
                            'child_unique_id': widget.child.childUniqueId,
                            'name': widget.child.name,
                            'date_of_birth': widget.child.dateOfBirth.toIso8601String().split('T')[0],
                            'gender': widget.child.gender,
                            'age_months': widget.child.currentAgeMonths,
                            'photo_url': widget.child.photoUrl,
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    isTelugu ? 'మొదటి స్క్రీనింగ్ ప్రారంభించండి' : 'Start First Screening',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return AppColors.riskHigh;
      case 'MEDIUM-HIGH':
      case 'MEDIUM':
        return AppColors.riskMedium;
      case 'LOW':
      default:
        return AppColors.riskLow;
    }
  }

  String _getRiskText(String risk, bool isTelugu) {
    final riskMap = {
      'HIGH': isTelugu ? 'అధిక ప్రమాదం' : 'High Risk',
      'MEDIUM-HIGH': isTelugu ? 'మధ్యస్థ-అధిక ప్రమాదం' : 'Medium-High Risk',
      'MEDIUM': isTelugu ? 'మధ్యస్థ ప్రమాదం' : 'Medium Risk',
      'LOW': isTelugu ? 'తక్కువ ప్రమాదం' : 'Low Risk',
    };
    return riskMap[risk.toUpperCase()] ?? risk;
  }
}
