import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dataset_provider.dart';
import '../../../services/prediction_service.dart';
import '../../../services/supabase_service.dart';
import '../widgets/challenge_dashboard_widgets.dart' show getChildIdsViaRpc;

/// Model Validation Dashboard — shows accuracy metrics and confusion matrix
/// for the AI risk prediction engine against ground-truth screening results.
class ModelValidationScreen extends ConsumerStatefulWidget {
  const ModelValidationScreen({super.key});

  @override
  ConsumerState<ModelValidationScreen> createState() =>
      _ModelValidationScreenState();
}

class _ModelValidationScreenState extends ConsumerState<ModelValidationScreen> {
  ModelValidationResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runValidation();
  }

  Future<void> _runValidation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final datasetOverride = ref.read(activeDatasetProvider);
      final isOverride = datasetOverride != null;

      ModelValidationResult result;

      if (isOverride) {
        // Dataset override active — fetch from Supabase via RPC
        final isMultiDistrict = datasetOverride.isMultiDistrict;
        final ecdDistrictIds = datasetOverride.districtIds ?? [];
        final user = ref.read(currentUserProvider);

        // Determine child IDs for this dataset
        List<int> childIds = [];
        if (isMultiDistrict && (user?.isSeniorOfficial ?? false) && ecdDistrictIds.isNotEmpty) {
          for (final distId in ecdDistrictIds) {
            childIds.addAll(await getChildIdsViaRpc('district', distId));
          }
        } else if (datasetOverride.projectId != null) {
          childIds = await getChildIdsViaRpc('project', datasetOverride.projectId!);
        }

        if (childIds.isEmpty) {
          result = ModelValidationResult.empty();
        } else {
          // Fetch screening results via RPC (in batches)
          final screeningResults = <Map<String, dynamic>>[];
          for (var i = 0; i < childIds.length; i += 200) {
            final batch = childIds.sublist(
                i, i + 200 > childIds.length ? childIds.length : i + 200);
            final rows = await SupabaseService.client.rpc(
              'get_screening_results_for_children',
              params: {'p_child_ids': batch},
            );
            screeningResults.addAll((rows as List)
                .map<Map<String, dynamic>>(
                    (r) => Map<String, dynamic>.from(r as Map)));
          }

          // Fetch children data for DOB/age
          final childrenData = <Map<String, dynamic>>[];
          for (var i = 0; i < childIds.length; i += 200) {
            final batch = childIds.sublist(
                i, i + 200 > childIds.length ? childIds.length : i + 200);
            final rows = await SupabaseService.client.rpc(
              'get_table_for_children',
              params: {'p_table_name': 'children', 'p_child_ids': batch},
            );
            childrenData.addAll((rows as List)
                .map<Map<String, dynamic>>(
                    (r) => Map<String, dynamic>.from(r as Map)));
          }

          result = await PredictionService.validateModelFromSupabase(
            screeningResults: screeningResults,
            children: childrenData,
          );
        }
      } else {
        // No override — use local Drift database
        result = await PredictionService.validateModel();
      }

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu
            ? 'మోడల్ ధృవీకరణ డాష్‌బోర్డ్'
            : 'Model Validation Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _result == null || _result!.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.analytics_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              isTelugu
                                  ? 'ధృవీకరించడానికి స్క్రీనింగ్ డేటా లేదు'
                                  : 'No screening data available for validation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _runValidation,
                      child: _buildContent(isTelugu),
                    ),
    );
  }

  Widget _buildContent(bool isTelugu) {
    final r = _result!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        _buildHeader(r, isTelugu),
        const SizedBox(height: 16),

        // Hero metrics
        _buildHeroMetrics(r, isTelugu),
        const SizedBox(height: 16),

        // Confusion matrix
        _buildConfusionMatrix(r, isTelugu),
        const SizedBox(height: 16),

        // Per-category breakdown
        _buildPerCategoryBreakdown(r, isTelugu),
        const SizedBox(height: 16),

        // Methodology
        _buildMethodology(isTelugu),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(ModelValidationResult r, bool isTelugu) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.verified, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTelugu
                        ? 'AI ప్రమాద అంచనా ధృవీకరణ'
                        : 'AI Risk Prediction Validation',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTelugu
                        ? '${r.total} పిల్లల ఫలితాలపై ధృవీకరించబడింది'
                        : 'Validated against ${r.total} child screening results',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroMetrics(ModelValidationResult r, bool isTelugu) {
    final accuracyPct = (r.accuracy * 100).toStringAsFixed(1);
    final sensitivityPct = (r.sensitivity * 100).toStringAsFixed(1);
    final specificityPct = (r.specificity * 100).toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            value: '$accuracyPct%',
            label: isTelugu ? 'ఖచ్చితత్వం' : 'Accuracy',
            sublabel: isTelugu
                ? '${r.correct}/${r.total} సరైనవి'
                : '${r.correct}/${r.total} correct',
            color: _accuracyColor(r.accuracy),
            icon: Icons.check_circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            value: '$sensitivityPct%',
            label: isTelugu ? 'సున్నితత్వం' : 'Sensitivity',
            sublabel: isTelugu
                ? 'ప్రమాద గుర్తింపు రేటు'
                : 'At-risk detection rate',
            color: _accuracyColor(r.sensitivity),
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            value: '$specificityPct%',
            label: isTelugu ? 'నిర్దిష్టత' : 'Specificity',
            sublabel: isTelugu
                ? 'ఆరోగ్యకరమైన ధృవీకరణ'
                : 'Healthy confirmation',
            color: _accuracyColor(r.specificity),
            icon: Icons.shield,
          ),
        ),
      ],
    );
  }

  Widget _buildConfusionMatrix(ModelValidationResult r, bool isTelugu) {
    final categories = r.categories;
    final categoryLabels = {
      'LOW': isTelugu ? 'తక్కువ' : 'Low',
      'MEDIUM': isTelugu ? 'మధ్యస్థం' : 'Medium',
      'HIGH': isTelugu ? 'అధికం' : 'High',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'కన్ఫ్యూజన్ మాత్రిక్స్' : 'Confusion Matrix',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isTelugu
                  ? 'వాస్తవ (అడ్డు వరుస) vs అంచనా (నిలువు వరుస)'
                  : 'Actual (row) vs Predicted (column)',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Matrix table
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(80),
              },
              children: [
                // Header row
                TableRow(
                  decoration:
                      BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    _matrixCell('', isHeader: true),
                    for (final p in categories)
                      _matrixCell(
                        isTelugu
                            ? '${categoryLabels[p]}\n(${isTelugu ? 'అంచనా' : 'Pred'})'
                            : '${categoryLabels[p]}\n(Pred)',
                        isHeader: true,
                      ),
                  ],
                ),
                // Data rows
                for (final actual in categories)
                  TableRow(
                    children: [
                      _matrixCell(
                        '${categoryLabels[actual]}\n(${isTelugu ? 'వాస్తవ' : 'Actual'})',
                        isHeader: true,
                      ),
                      for (final predicted in categories)
                        _matrixCell(
                          '${r.confusionMatrix[actual]?[predicted] ?? 0}',
                          isCorrect: actual == predicted,
                          count: r.confusionMatrix[actual]?[predicted] ?? 0,
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _matrixCell(String text,
      {bool isHeader = false, bool isCorrect = false, int count = 0}) {
    Color bgColor;
    if (isHeader) {
      bgColor = Colors.grey.shade50;
    } else if (isCorrect && count > 0) {
      bgColor = Colors.green.shade50;
    } else if (!isCorrect && count > 0) {
      bgColor = Colors.red.shade50;
    } else {
      bgColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      color: bgColor,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 11 : 16,
          fontWeight:
              (isHeader || (isCorrect && count > 0)) ? FontWeight.bold : null,
          color: isCorrect && count > 0
              ? Colors.green.shade800
              : (!isCorrect && count > 0)
                  ? Colors.red.shade800
                  : AppColors.text,
        ),
      ),
    );
  }

  Widget _buildPerCategoryBreakdown(ModelValidationResult r, bool isTelugu) {
    final categoryLabels = {
      'LOW': isTelugu ? 'తక్కువ ప్రమాదం' : 'Low Risk',
      'MEDIUM': isTelugu ? 'మధ్యస్థ ప్రమాదం' : 'Medium Risk',
      'HIGH': isTelugu ? 'అధిక ప్రమాదం' : 'High Risk',
    };
    final categoryColors = {
      'LOW': AppColors.riskLow,
      'MEDIUM': AppColors.riskMedium,
      'HIGH': AppColors.riskHigh,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu
                  ? 'వర్గం వారీ పనితీరు'
                  : 'Per-Category Performance',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final cat in r.categories) ...[
              _CategoryRow(
                label: categoryLabels[cat] ?? cat,
                sensitivity: r.perCategorySensitivity[cat] ?? 0,
                precision: r.perCategoryPrecision[cat] ?? 0,
                color: categoryColors[cat] ?? AppColors.primary,
                isTelugu: isTelugu,
                // Compute correct/total for this category
                correct: _getCategoryCorrect(r, cat),
                total: _getCategoryTotal(r, cat),
              ),
              if (cat != r.categories.last)
                Divider(height: 16, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }

  int _getCategoryCorrect(ModelValidationResult r, String cat) {
    return r.confusionMatrix[cat]?[cat] ?? 0;
  }

  int _getCategoryTotal(ModelValidationResult r, String cat) {
    final row = r.confusionMatrix[cat];
    if (row == null) return 0;
    return row.values.fold(0, (sum, v) => sum + v);
  }

  Widget _buildMethodology(bool isTelugu) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  isTelugu ? 'పద్ధతి' : 'Methodology',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _methodItem(
              isTelugu
                  ? 'గ్రౌండ్ ట్రూత్: సాధన-ఆధారిత DQ స్కోరింగ్ నుండి వాస్తవ ప్రమాద వర్గం'
                  : 'Ground truth: Actual risk category from tool-based DQ scoring',
            ),
            _methodItem(
              isTelugu
                  ? 'అంచనా: ఫార్ములా-ఆధారిత ప్రిడిక్టర్ 30+ ఫీచర్లతో'
                  : 'Prediction: Formula-based predictor with 30+ extracted features',
            ),
            _methodItem(
              isTelugu
                  ? 'బరువు మూలాలు: Lancet 2016 ECD, DSM-5 PPV, WHO నర్చరింగ్ కేర్'
                  : 'Weight sources: Lancet 2016 ECD Series, DSM-5 PPV ratios, WHO Nurturing Care',
            ),
            _methodItem(
              isTelugu
                  ? 'భాగాలు: అభివృద్ధి (40%), బహుళ-డొమైన్ (15%), పరిస్థితులు (20%), పర్యావరణం (15%), పథం (10%)'
                  : 'Components: Developmental (40%), Multi-domain (15%), Conditions (20%), Environment (15%), Trajectory (10%)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Color _accuracyColor(double value) {
    if (value >= 0.95) return Colors.green.shade700;
    if (value >= 0.85) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}

/// Single metric card with large value, label, and icon.
class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
            Text(sublabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// Row showing per-category sensitivity and precision.
class _CategoryRow extends StatelessWidget {
  final String label;
  final double sensitivity;
  final double precision;
  final Color color;
  final bool isTelugu;
  final int correct;
  final int total;

  const _CategoryRow({
    required this.label,
    required this.sensitivity,
    required this.precision,
    required this.color,
    required this.isTelugu,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text(
                '$correct / $total ${isTelugu ? 'సరైనవి' : 'correct'}',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Text('${(sensitivity * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Text(isTelugu ? 'రీకాల్' : 'Recall',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Text('${(precision * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Text(isTelugu ? 'ప్రిసిషన్' : 'Precision',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
