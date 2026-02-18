import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../database/app_database.dart';
import '../../models/screening_tool.dart';
import '../../providers/auth_provider.dart';
import '../../providers/screening_hub_provider.dart';
import '../../services/database_service.dart';

/// Dedicated nutrition assessment screen for the ECD challenge.
/// Captures height, weight, MUAC measurements and computes risk flags.
class NutritionChallengeScreen extends ConsumerStatefulWidget {
  final ScreeningToolConfig toolConfig;
  final int childAgeMonths;
  final void Function(Map<String, dynamic> responses) onComplete;

  const NutritionChallengeScreen({
    super.key,
    required this.toolConfig,
    required this.childAgeMonths,
    required this.onComplete,
  });

  @override
  ConsumerState<NutritionChallengeScreen> createState() =>
      _NutritionChallengeScreenState();
}

class _NutritionChallengeScreenState
    extends ConsumerState<NutritionChallengeScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _muacController = TextEditingController();
  bool _anemia = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _muacController.dispose();
    super.dispose();
  }

  /// Compute nutrition flags based on measurements and age
  Map<String, dynamic> _computeFlags() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final muac = double.tryParse(_muacController.text) ?? 0;

    // Simplified WHO z-score approximation for field use
    // Underweight: weight-for-age < -2SD (simplified threshold by age)
    bool underweight = false;
    if (widget.childAgeMonths <= 12 && weight > 0) {
      underweight = weight < 6.0;
    } else if (widget.childAgeMonths <= 24 && weight > 0) {
      underweight = weight < 8.5;
    } else if (widget.childAgeMonths <= 36 && weight > 0) {
      underweight = weight < 10.0;
    } else if (widget.childAgeMonths <= 48 && weight > 0) {
      underweight = weight < 12.0;
    } else if (weight > 0) {
      underweight = weight < 14.0;
    }

    // Stunting: height-for-age < -2SD
    bool stunting = false;
    if (widget.childAgeMonths <= 12 && height > 0) {
      stunting = height < 68;
    } else if (widget.childAgeMonths <= 24 && height > 0) {
      stunting = height < 78;
    } else if (widget.childAgeMonths <= 36 && height > 0) {
      stunting = height < 87;
    } else if (widget.childAgeMonths <= 48 && height > 0) {
      stunting = height < 94;
    } else if (height > 0) {
      stunting = height < 100;
    }

    // Wasting: MUAC < 12.5cm for children 6-59 months
    bool wasting = false;
    if (muac > 0 && widget.childAgeMonths >= 6) {
      wasting = muac < 12.5;
    }

    // Nutrition score: count of flags (0-4)
    int score = 0;
    if (underweight) score++;
    if (stunting) score++;
    if (wasting) score++;
    if (_anemia) score++;

    String risk = 'Low';
    if (score >= 3) {
      risk = 'High';
    } else if (score >= 1) {
      risk = 'Moderate';
    }

    return {
      'height_cm': height,
      'weight_kg': weight,
      'muac_cm': muac,
      'underweight': underweight,
      'stunting': stunting,
      'wasting': wasting,
      'anemia': _anemia,
      'nutrition_score': score,
      'nutrition_risk': risk,
    };
  }

  Future<void> _onSubmit() async {
    final flags = _computeFlags();

    // Save to dedicated Drift table
    if (!kIsWeb) {
      try {
        final hub = ref.read(screeningHubProvider);
        final childRemoteId = hub?.child['child_id'] as int?;
        final sessionLocalId = hub?.localSessionId;

        if (childRemoteId != null) {
          final localId = await DatabaseService.db.challengeDao.insertNutrition(
            LocalNutritionAssessmentsCompanion.insert(
              childRemoteId: Value(childRemoteId),
              sessionLocalId: Value(sessionLocalId),
              heightCm: Value(flags['height_cm'] as double?),
              weightKg: Value(flags['weight_kg'] as double?),
              muacCm: Value(flags['muac_cm'] as double?),
              underweight: Value(flags['underweight'] as bool),
              stunting: Value(flags['stunting'] as bool),
              wasting: Value(flags['wasting'] as bool),
              anemia: Value(flags['anemia'] as bool),
              nutritionScore: Value(flags['nutrition_score'] as int),
              nutritionRisk: Value(flags['nutrition_risk'] as String),
              assessedDate:
                  Value(DateTime.now().toIso8601String().split('T')[0]),
            ),
          );
          await DatabaseService.db.syncQueueDao.enqueue(
            entityType: 'nutrition',
            entityLocalId: localId,
            operation: 'insert',
            priority: 3,
          );
        }
      } catch (_) {}
    }

    // Complete tool in hub (normal flow)
    widget.onComplete(flags);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'పోషణ అంచనా' : 'Nutrition Assessment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu
                  ? 'పిల్లల కొలతలను నమోదు చేయండి'
                  : 'Enter child measurements',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Height
            _buildMeasurementField(
              label: isTelugu ? 'ఎత్తు (సెం.మీ)' : 'Height (cm)',
              controller: _heightController,
              hint: isTelugu ? 'ఉదా: 75.5' : 'e.g. 75.5',
            ),
            const SizedBox(height: 16),

            // Weight
            _buildMeasurementField(
              label: isTelugu ? 'బరువు (కి.గ్రా)' : 'Weight (kg)',
              controller: _weightController,
              hint: isTelugu ? 'ఉదా: 9.2' : 'e.g. 9.2',
            ),
            const SizedBox(height: 16),

            // MUAC
            _buildMeasurementField(
              label: isTelugu ? 'MUAC (సెం.మీ)' : 'MUAC (cm)',
              controller: _muacController,
              hint: isTelugu ? 'ఉదా: 13.5' : 'e.g. 13.5',
            ),
            const SizedBox(height: 20),

            // Anemia checkbox
            CheckboxListTile(
              title: Text(
                isTelugu ? 'రక్తహీనత (అనీమియా)' : 'Anemia',
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                isTelugu
                    ? 'రక్త పరీక్ష ఆధారంగా గుర్తించబడింది'
                    : 'Identified based on blood test',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              value: _anemia,
              onChanged: (v) => setState(() => _anemia = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isTelugu ? 'సమర్పించండి' : 'Submit',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
