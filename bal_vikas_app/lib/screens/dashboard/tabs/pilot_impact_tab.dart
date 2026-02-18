import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dataset_provider.dart';
import '../../../services/supabase_service.dart';
import '../widgets/challenge_dashboard_widgets.dart' show getChildIdsForScope, getChildIdsViaRpc, getChildIdsExcludingDistricts;

/// Pilot Impact Summary — one screen showing the complete
/// before → action → after narrative for the pilot.
class PilotImpactScreen extends ConsumerStatefulWidget {
  const PilotImpactScreen({super.key});

  @override
  ConsumerState<PilotImpactScreen> createState() => _PilotImpactScreenState();
}

class _PilotImpactScreenState extends ConsumerState<PilotImpactScreen> {
  bool _isLoading = true;

  // Baseline
  int _totalChildren = 0;
  int _screenedCount = 0;
  int _criticalRisk = 0;
  int _highRisk = 0;
  int _mediumRisk = 0;
  int _lowRisk = 0;
  double _avgCompositeDq = 0;

  // Actions
  int _referralsMade = 0;
  int _plansGenerated = 0;
  int _activitiesAssigned = 0;
  double _followupComplianceRate = 0;
  int _parentsSensitized = 0;
  int _trainedFunctionaries = 0;

  // Outcomes
  int _trendImproved = 0;
  int _trendSame = 0;
  int _trendWorsened = 0;
  double _exitHighRiskRate = 0;
  int _exitedHighRisk = 0;
  int _highRiskBaseline = 0;
  double _avgDelayReduction = 0;
  int _delayReductionCount = 0;
  double _referralCompletionRate = 0;
  double _avgTurnaroundDays = 0;
  Map<String, double> _domainImprovementRates = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      // Check for dataset override first
      final datasetOverride = ref.read(activeDatasetProvider);

      // Determine scope
      String? scope;
      int? scopeId;
      final isOverride = datasetOverride != null;
      final isMultiDistrict = datasetOverride?.isMultiDistrict ?? false;
      final ecdDistrictIds = datasetOverride?.districtIds ?? [];
      final sampleDistrictIds = ref.read(sampleDatasetDistrictIdsProvider);

      if (isOverride && isMultiDistrict && user.isSeniorOfficial && user.stateId != null) {
        // Multi-district ECD + SO: use state scope (child IDs fetched below)
        scope = 'state';
        scopeId = user.stateId!;
      } else if (isOverride && datasetOverride!.projectId != null) {
        scope = 'project';
        scopeId = datasetOverride.projectId!;
      } else if (user.isSupervisor && user.sectorId != null) {
        scope = 'sector';
        scopeId = user.sectorId!;
      } else if ((user.isCDPO || user.isCW || user.isEO) && user.projectId != null) {
        scope = 'project';
        scopeId = user.projectId!;
      } else if (user.isDW && user.districtId != null) {
        scope = 'district';
        scopeId = user.districtId!;
      } else if (user.isSeniorOfficial && user.stateId != null) {
        scope = 'state';
        scopeId = user.stateId!;
      }

      // Get child IDs for scope (use RPC when dataset override is active to bypass RLS)
      List<int> childIds = [];
      bool childIdsExplicitlyFiltered = false;
      if (scope == 'state' && scopeId != null) {
        if (isOverride && isMultiDistrict && ecdDistrictIds.isNotEmpty) {
          // Multi-district ECD: get children from all ECD districts
          for (final distId in ecdDistrictIds) {
            childIds.addAll(await getChildIdsViaRpc('district', distId));
          }
          childIdsExplicitlyFiltered = true;
        } else if (!isOverride && sampleDistrictIds.isNotEmpty) {
          // App Data: exclude sample districts
          childIds = await getChildIdsExcludingDistricts(scopeId, sampleDistrictIds);
          childIdsExplicitlyFiltered = true;
        }
      } else if (scope != null && scopeId != null) {
        childIds = isOverride
            ? await getChildIdsViaRpc(scope, scopeId)
            : await getChildIdsForScope(scope, scopeId);
      }

      // Fetch screening results
      List<Map<String, dynamic>> results;
      if (childIds.isNotEmpty) {
        if (isOverride) {
          // Batch RPC for screening results to bypass RLS
          results = [];
          for (var i = 0; i < childIds.length; i += 200) {
            final batch = childIds.sublist(i, (i + 200).clamp(0, childIds.length));
            final rows = await SupabaseService.client.rpc(
              'get_screening_results_for_children',
              params: {'p_child_ids': batch},
            );
            for (final r in (rows as List)) {
              results.add(Map<String, dynamic>.from(r as Map));
            }
          }
        } else {
          results = await SupabaseService.getScreeningResultsForChildren(childIds);
        }
      } else if (scope == 'state' && !childIdsExplicitlyFiltered) {
        // Blanket query ONLY when no filtering was applied
        results = await SupabaseService.client
            .from('screening_results')
            .select('*')
            .order('created_at', ascending: false)
            .limit(5000);
        childIds = results.map((r) => r['child_id'] as int).toSet().toList();
      } else {
        results = [];
      }

      // Deduplicate: latest per child
      final latestPerChild = <int, Map<String, dynamic>>{};
      for (final r in results) {
        final cid = r['child_id'] as int?;
        if (cid != null && !latestPerChild.containsKey(cid)) {
          latestPerChild[cid] = r;
        }
      }
      final uniqueResults = latestPerChild.values.toList();

      // === BASELINE METRICS ===
      int critical = 0, high = 0, medium = 0, low = 0, referrals = 0;
      double compositeSum = 0;
      int compositeCount = 0;
      final domainSums = <String, double>{'GM': 0, 'FM': 0, 'LC': 0, 'COG': 0, 'SE': 0};
      final domainCounts = <String, int>{'GM': 0, 'FM': 0, 'LC': 0, 'COG': 0, 'SE': 0};
      final delayCounts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final r in uniqueResults) {
        final numDelays = (r['num_delays'] as num?)?.toInt() ?? 0;
        final compositeDq = (r['composite_dq'] as num?)?.toDouble();
        final risk = r['overall_risk']?.toString() ?? '';

        if (numDelays >= 4 || (compositeDq != null && compositeDq > 0 && compositeDq < 50)) {
          critical++;
        } else if (risk == 'HIGH') {
          high++;
        } else if (risk == 'MEDIUM') {
          medium++;
        } else if (risk == 'LOW') {
          low++;
        }
        if (r['referral_needed'] == true) referrals++;

        if (compositeDq != null && compositeDq > 0) {
          compositeSum += compositeDq;
          compositeCount++;
        }

        final nd = numDelays.clamp(0, 5);
        delayCounts[nd] = (delayCounts[nd] ?? 0) + 1;

        // Domain DQs
        for (final entry in [
          ['GM', 'gm_dq'], ['FM', 'fm_dq'], ['LC', 'lc_dq'],
          ['COG', 'cog_dq'], ['SE', 'se_dq']
        ]) {
          final val = (r[entry[1]] as num?)?.toDouble();
          if (val != null && val > 0) {
            domainSums[entry[0]] = domainSums[entry[0]]! + val;
            domainCounts[entry[0]] = domainCounts[entry[0]]! + 1;
          }
        }
      }

      final domainAvg = <String, double>{};
      for (final key in domainSums.keys) {
        if (domainCounts[key]! > 0) {
          domainAvg[key] = domainSums[key]! / domainCounts[key]!;
        }
      }

      // === ACTION METRICS ===
      int plansGen = 0, activitiesAssn = 0;
      int tImproved = 0, tSame = 0, tWorsened = 0;
      double avgDelayRed = 0;
      int delayRedCount = 0;

      if (childIds.isNotEmpty) {
        try {
          final fuData = await SupabaseService.client
              .from('intervention_followups')
              .select('child_id, reduction_in_delay_months, intervention_plan_generated, home_activities_assigned, improvement_status')
              .inFilter('child_id', childIds);

          double redSum = 0;
          final fuChildren = <int>{};
          final improvedSet = <int>{};
          final sameSet = <int>{};
          final worsenedSet = <int>{};
          for (final f in fuData) {
            final cid = f['child_id'] as int;
            fuChildren.add(cid);
            final red = (f['reduction_in_delay_months'] as num?)?.toInt() ?? 0;
            if (red > 0) { redSum += red; delayRedCount++; }
            if (f['intervention_plan_generated'] == true) plansGen++;
            activitiesAssn += (f['home_activities_assigned'] as num?)?.toInt() ?? 0;
            final status = f['improvement_status']?.toString();
            if (status == 'Improved') {
              improvedSet.add(cid);
            } else if (status == 'Same') {
              sameSet.add(cid);
            } else if (status == 'Worsened') {
              worsenedSet.add(cid);
            }
          }
          avgDelayRed = delayRedCount > 0 ? redSum / delayRedCount : 0;
          // fuChildren tracked for potential future use
          tImproved = improvedSet.length;
          tSame = sameSet.length;
          tWorsened = worsenedSet.length;
        } catch (_) {}
      }

      // Referral metrics
      int refTotal = 0, refCompleted = 0;
      double refRate = 0, avgTurnaround = 0;
      int turnaroundSamples = 0;
      if (childIds.isNotEmpty) {
        try {
          final referralData = await SupabaseService.client
              .from('referrals')
              .select('child_id, referral_status, referred_date, completed_date')
              .inFilter('child_id', childIds);
          final uniqueReferrals = <int, String>{};
          for (final ref in referralData) {
            final cid = ref['child_id'] as int;
            final status = ref['referral_status']?.toString() ?? 'Pending';
            if (!uniqueReferrals.containsKey(cid) || status == 'Completed') {
              uniqueReferrals[cid] = status;
            }
          }
          refTotal = uniqueReferrals.length;
          refCompleted = uniqueReferrals.values.where((s) => s == 'Completed').length;
          refRate = refTotal > 0 ? (refCompleted / refTotal) * 100 : 0;

          // Turnaround
          double turnaroundSum = 0;
          for (final ref in referralData) {
            if (ref['referral_status'] == 'Completed' &&
                ref['referred_date'] != null && ref['completed_date'] != null) {
              final start = DateTime.tryParse(ref['referred_date'].toString());
              final end = DateTime.tryParse(ref['completed_date'].toString());
              if (start != null && end != null) {
                turnaroundSum += end.difference(start).inDays;
                turnaroundSamples++;
              }
            }
          }
          avgTurnaround = turnaroundSamples > 0 ? turnaroundSum / turnaroundSamples : 0;
        } catch (_) {}
      }

      // Follow-up compliance
      double fuRate = 0;
      if (childIds.isNotEmpty) {
        try {
          final fuDue = uniqueResults.where((r) {
            final risk = r['overall_risk']?.toString() ?? '';
            return risk == 'HIGH' || r['referral_needed'] == true;
          }).length + critical;
          final followupData = await SupabaseService.client
              .from('intervention_followups')
              .select('child_id, followup_conducted')
              .inFilter('child_id', childIds)
              .eq('followup_conducted', true);
          final fuConducted = followupData.map((f) => f['child_id'] as int).toSet().length;
          fuRate = fuDue > 0 ? (fuConducted / fuDue) * 100 : 0;
        } catch (_) {}
      }

      // Workforce & parents
      int trainedFunc = 0, pSensitized = 0;
      if (childIds.isNotEmpty) {
        try {
          final wfData = await SupabaseService.client
              .from('workforce_training')
              .select('user_id, trained')
              .eq('trained', true);
          trainedFunc = wfData.length;
        } catch (_) {}
        try {
          final pData = await SupabaseService.client
              .from('parent_engagement')
              .select('child_id, sensitized, interventions_assigned')
              .inFilter('child_id', childIds);
          for (final p in pData) {
            if (p['sensitized'] == true) pSensitized++;
          }
        } catch (_) {}
      }

      // Exit from high-risk
      int hrBaseline = 0, hrExited = 0;
      double hrExitRate = 0;
      Map<String, double> domainImpRates = {};
      if (results.isNotEmpty) {
        try {
          final resultsByChild = <int, List<Map<String, dynamic>>>{};
          for (final r in results) {
            final cid = r['child_id'] as int?;
            if (cid == null) continue;
            resultsByChild.putIfAbsent(cid, () => []).add(r);
          }

          final domains = ['gm', 'fm', 'lc', 'cog', 'se'];
          final domainKeys = {
            'gm': 'gm_dq', 'fm': 'fm_dq', 'lc': 'lc_dq',
            'cog': 'cog_dq', 'se': 'se_dq',
          };
          final domainImpCounts = <String, int>{};
          final domainTotPaired = <String, int>{};
          for (final d in domains) {
            domainImpCounts[d.toUpperCase()] = 0;
            domainTotPaired[d.toUpperCase()] = 0;
          }

          for (final entry in resultsByChild.entries) {
            final childResults = entry.value;
            if (childResults.length < 2) continue;

            final baseline = childResults.last;
            final latest = childResults.first;

            final baselineRisk = baseline['overall_risk']?.toString() ?? '';
            final baselineDelays = (baseline['num_delays'] as num?)?.toInt() ?? 0;
            final baselineDq = (baseline['composite_dq'] as num?)?.toDouble();
            final wasHighRisk = baselineRisk == 'HIGH' ||
                baselineDelays >= 4 ||
                (baselineDq != null && baselineDq > 0 && baselineDq < 50);

            if (wasHighRisk) {
              hrBaseline++;
              final latestRisk = latest['overall_risk']?.toString() ?? '';
              final latestDelays = (latest['num_delays'] as num?)?.toInt() ?? 0;
              final latestDq = (latest['composite_dq'] as num?)?.toDouble();
              final isStillHighRisk = latestRisk == 'HIGH' ||
                  latestDelays >= 4 ||
                  (latestDq != null && latestDq > 0 && latestDq < 50);
              if (!isStillHighRisk) hrExited++;
            }

            for (final d in domains) {
              final key = domainKeys[d]!;
              final baseDq = (baseline[key] as num?)?.toDouble();
              final latDq = (latest[key] as num?)?.toDouble();
              if (baseDq != null && baseDq > 0 && latDq != null && latDq > 0) {
                final dKey = d.toUpperCase();
                domainTotPaired[dKey] = domainTotPaired[dKey]! + 1;
                if (latDq > baseDq) {
                  domainImpCounts[dKey] = domainImpCounts[dKey]! + 1;
                }
              }
            }
          }

          hrExitRate = hrBaseline > 0 ? (hrExited / hrBaseline) * 100 : 0;
          for (final d in domains) {
            final dKey = d.toUpperCase();
            final total = domainTotPaired[dKey] ?? 0;
            domainImpRates[dKey] = total > 0
                ? (domainImpCounts[dKey]! / total) * 100
                : 0;
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _totalChildren = childIds.length;
          _screenedCount = uniqueResults.length;
          _criticalRisk = critical;
          _highRisk = high;
          _mediumRisk = medium;
          _lowRisk = low;
          _avgCompositeDq = compositeCount > 0 ? compositeSum / compositeCount : 0;
          _referralsMade = referrals;
          _plansGenerated = plansGen;
          _activitiesAssigned = activitiesAssn;
          _followupComplianceRate = fuRate;
          _parentsSensitized = pSensitized;
          _trainedFunctionaries = trainedFunc;
          _trendImproved = tImproved;
          _trendSame = tSame;
          _trendWorsened = tWorsened;
          _exitHighRiskRate = hrExitRate;
          _exitedHighRisk = hrExited;
          _highRiskBaseline = hrBaseline;
          _avgDelayReduction = avgDelayRed;
          _delayReductionCount = delayRedCount;
          _referralCompletionRate = refRate;
          _avgTurnaroundDays = avgTurnaround;
          _domainImprovementRates = domainImpRates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'పైలట్ ప్రభావ సారాంశం' : 'Pilot Impact Summary'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _buildContent(isTelugu),
            ),
    );
  }

  Widget _buildContent(bool isTelugu) {
    final atRiskCount = _criticalRisk + _highRisk + _mediumRisk;
    final atRiskPct = _screenedCount > 0
        ? (atRiskCount / _screenedCount * 100).toStringAsFixed(0)
        : '0';
    final trendTotal = _trendImproved + _trendSame + _trendWorsened;
    final improvedPct = trendTotal > 0
        ? (_trendImproved / trendTotal * 100).toStringAsFixed(0)
        : '0';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero stats
        _buildHeroCards(isTelugu, atRiskPct, improvedPct),
        const SizedBox(height: 20),

        // Section 1: Baseline
        _buildSectionHeader(
          Icons.flag,
          isTelugu ? 'స్క్రీనింగ్ బేస్‌లైన్' : 'Screening Baseline',
          Colors.blue,
          isTelugu,
        ),
        _buildBaselineSection(isTelugu),
        const SizedBox(height: 8),

        // Arrow connector
        _buildArrow(),
        const SizedBox(height: 8),

        // Section 2: Actions Taken
        _buildSectionHeader(
          Icons.build,
          isTelugu ? 'చర్యలు తీసుకున్నవి' : 'Actions Taken',
          Colors.orange,
          isTelugu,
        ),
        _buildActionsSection(isTelugu),
        const SizedBox(height: 8),

        // Arrow connector
        _buildArrow(),
        const SizedBox(height: 8),

        // Section 3: Outcomes
        _buildSectionHeader(
          Icons.trending_up,
          isTelugu ? 'ఫలితాలు & ప్రభావం' : 'Outcomes & Impact',
          Colors.green,
          isTelugu,
        ),
        _buildOutcomesSection(isTelugu),
        const SizedBox(height: 16),

        // Domain improvement
        _buildDomainImprovementSection(isTelugu),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeroCards(bool isTelugu, String atRiskPct, String improvedPct) {
    return Row(
      children: [
        Expanded(
          child: _HeroCard(
            value: '$_screenedCount',
            label: isTelugu ? 'పిల్లలు తనిఖీ' : 'Children Screened',
            icon: Icons.people,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HeroCard(
            value: '$atRiskPct%',
            label: isTelugu ? 'ప్రమాదంలో ఉన్నారు' : 'At Risk',
            icon: Icons.warning_amber_rounded,
            color: AppColors.riskHigh,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HeroCard(
            value: '$improvedPct%',
            label: isTelugu ? 'మెరుగుపడ్డారు' : 'Improved',
            icon: Icons.trending_up,
            color: AppColors.riskLow,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HeroCard(
            value: '${_avgDelayReduction.toStringAsFixed(1)}mo',
            label: isTelugu ? 'ఆలస్యం తగ్గింపు' : 'Delay Reduced',
            icon: Icons.speed,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      IconData icon, String title, Color color, bool isTelugu) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildBaselineSection(bool isTelugu) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(
              label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children',
              value: '$_totalChildren',
              icon: Icons.people_outline,
            ),
            _StatRow(
              label: isTelugu ? 'తనిఖీ చేయబడ్డారు' : 'Screened',
              value: '$_screenedCount',
              icon: Icons.assignment_turned_in,
            ),
            const Divider(height: 16),
            // Risk distribution
            _StatRow(
              label: isTelugu ? 'క్రిటికల్ ప్రమాదం' : 'Critical Risk',
              value: '$_criticalRisk',
              icon: Icons.error,
              valueColor: Colors.purple,
            ),
            _StatRow(
              label: isTelugu ? 'అధిక ప్రమాదం' : 'High Risk',
              value: '$_highRisk',
              icon: Icons.warning,
              valueColor: AppColors.riskHigh,
            ),
            _StatRow(
              label: isTelugu ? 'మధ్యస్థ ప్రమాదం' : 'Medium Risk',
              value: '$_mediumRisk',
              icon: Icons.info,
              valueColor: AppColors.riskMedium,
            ),
            _StatRow(
              label: isTelugu ? 'తక్కువ ప్రమాదం' : 'Low Risk',
              value: '$_lowRisk',
              icon: Icons.check_circle,
              valueColor: AppColors.riskLow,
            ),
            const Divider(height: 16),
            _StatRow(
              label: isTelugu ? 'సగటు DQ స్కోర్' : 'Average DQ Score',
              value: _avgCompositeDq.toStringAsFixed(1),
              icon: Icons.analytics,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(bool isTelugu) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(
              label: isTelugu
                  ? 'జోక్య ప్రణాళికలు రూపొందించబడ్డాయి'
                  : 'Intervention Plans Generated',
              value: '$_plansGenerated',
              icon: Icons.description,
            ),
            _StatRow(
              label: isTelugu
                  ? 'కార్యకలాపాలు కేటాయించబడ్డాయి'
                  : 'Activities Assigned',
              value: '$_activitiesAssigned',
              icon: Icons.fitness_center,
            ),
            _StatRow(
              label: isTelugu ? 'రెఫరల్లు చేయబడ్డాయి' : 'Referrals Made',
              value: '$_referralsMade',
              icon: Icons.local_hospital,
            ),
            const Divider(height: 16),
            _StatRow(
              label: isTelugu
                  ? 'ఫాలో-అప్ కంప్లయన్స్ రేటు'
                  : 'Follow-up Compliance Rate',
              value: '${_followupComplianceRate.toStringAsFixed(0)}%',
              icon: Icons.event_available,
              valueColor: _followupComplianceRate >= 75
                  ? AppColors.riskLow
                  : AppColors.riskMedium,
            ),
            _StatRow(
              label: isTelugu
                  ? 'తల్లిదండ్రులు సంవేదనశీలం చేయబడ్డారు'
                  : 'Parents Sensitized',
              value: '$_parentsSensitized',
              icon: Icons.family_restroom,
            ),
            _StatRow(
              label: isTelugu
                  ? 'శిక్షణ పొందిన సిబ్బంది'
                  : 'Functionaries Trained',
              value: '$_trainedFunctionaries',
              icon: Icons.school,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomesSection(bool isTelugu) {
    final trendTotal = _trendImproved + _trendSame + _trendWorsened;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Trend bar
            if (trendTotal > 0) ...[
              Row(
                children: [
                  Icon(Icons.trending_up,
                      color: AppColors.riskLow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isTelugu
                        ? 'అభివృద్ధి ధోరణి'
                        : 'Developmental Trend',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      if (_trendImproved > 0)
                        Expanded(
                          flex: _trendImproved,
                          child: Container(
                            color: AppColors.riskLow,
                            alignment: Alignment.center,
                            child: Text(
                              '$_trendImproved',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if (_trendSame > 0)
                        Expanded(
                          flex: _trendSame,
                          child: Container(
                            color: AppColors.riskMedium,
                            alignment: Alignment.center,
                            child: Text(
                              '$_trendSame',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if (_trendWorsened > 0)
                        Expanded(
                          flex: _trendWorsened,
                          child: Container(
                            color: AppColors.riskHigh,
                            alignment: Alignment.center,
                            child: Text(
                              '$_trendWorsened',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _legendItem(
                      AppColors.riskLow,
                      isTelugu ? 'మెరుగుపడ్డారు' : 'Improved'),
                  _legendItem(
                      AppColors.riskMedium,
                      isTelugu ? 'అదే' : 'Same'),
                  _legendItem(
                      AppColors.riskHigh,
                      isTelugu ? 'క్షీణించారు' : 'Worsened'),
                ],
              ),
              const Divider(height: 20),
            ],
            _StatRow(
              label: isTelugu
                  ? 'అధిక-ప్రమాద నిష్క్రమణ రేటు'
                  : 'Exit from High-Risk Rate',
              value: '${_exitHighRiskRate.toStringAsFixed(0)}%',
              sublabel: '$_exitedHighRisk / $_highRiskBaseline',
              icon: Icons.exit_to_app,
              valueColor: AppColors.riskLow,
            ),
            _StatRow(
              label: isTelugu
                  ? 'సగటు ఆలస్యం తగ్గింపు'
                  : 'Avg Delay Reduction',
              value:
                  '${_avgDelayReduction.toStringAsFixed(1)} ${isTelugu ? 'నెలలు' : 'months'}',
              sublabel:
                  '$_delayReductionCount ${isTelugu ? 'పిల్లలు' : 'children'}',
              icon: Icons.speed,
              valueColor: _avgDelayReduction >= 2
                  ? AppColors.riskLow
                  : AppColors.riskMedium,
            ),
            _StatRow(
              label: isTelugu
                  ? 'రెఫరల్ పూర్తి రేటు'
                  : 'Referral Completion Rate',
              value: '${_referralCompletionRate.toStringAsFixed(0)}%',
              icon: Icons.local_hospital,
              valueColor: _referralCompletionRate >= 70
                  ? AppColors.riskLow
                  : AppColors.riskMedium,
            ),
            _StatRow(
              label: isTelugu
                  ? 'సగటు రెఫరల్ టర్నరౌండ్'
                  : 'Avg Referral Turnaround',
              value:
                  '${_avgTurnaroundDays.toStringAsFixed(0)} ${isTelugu ? 'రోజులు' : 'days'}',
              icon: Icons.timer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainImprovementSection(bool isTelugu) {
    if (_domainImprovementRates.isEmpty) return const SizedBox.shrink();

    final domainLabels = {
      'GM': isTelugu ? 'స్థూల చలనం' : 'Gross Motor',
      'FM': isTelugu ? 'సూక్ష్మ చలనం' : 'Fine Motor',
      'LC': isTelugu ? 'భాష' : 'Language',
      'COG': isTelugu ? 'జ్ఞానాత్మకం' : 'Cognitive',
      'SE': isTelugu ? 'సామాజిక-భావోద్వేగ' : 'Social-Emotional',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu
                  ? 'డొమైన్ వారీ మెరుగుదల రేట్లు'
                  : 'Domain-wise Improvement Rates',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final domain in ['GM', 'FM', 'LC', 'COG', 'SE'])
              if (_domainImprovementRates.containsKey(domain)) ...[
                _DomainBar(
                  label: domainLabels[domain] ?? domain,
                  rate: _domainImprovementRates[domain] ?? 0,
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return Center(
      child: Icon(Icons.arrow_downward, color: Colors.grey.shade400, size: 28),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _HeroCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final String? sublabel;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13)),
                if (sublabel != null)
                  Text(sublabel!,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.text)),
        ],
      ),
    );
  }
}

class _DomainBar extends StatelessWidget {
  final String label;
  final double rate;

  const _DomainBar({required this.label, required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = rate >= 60
        ? AppColors.riskLow
        : rate >= 30
            ? AppColors.riskMedium
            : AppColors.riskHigh;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text('${rate.toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (rate / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
