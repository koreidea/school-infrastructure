import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../database/app_database.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';

/// Follow-up entry screen: records intervention follow-up for a child
class FollowupEntryScreen extends ConsumerStatefulWidget {
  final int childRemoteId;
  final int? screeningResultLocalId;

  const FollowupEntryScreen({
    super.key,
    required this.childRemoteId,
    this.screeningResultLocalId,
  });

  @override
  ConsumerState<FollowupEntryScreen> createState() =>
      _FollowupEntryScreenState();
}

class _FollowupEntryScreenState extends ConsumerState<FollowupEntryScreen> {
  bool _followupConducted = true;
  String _improvementStatus = 'Same';
  int _reductionInDelayMonths = 0;
  bool _domainImprovement = false;
  bool _exitHighRisk = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    try {
      final user = ref.read(currentUserProvider);
      if (kIsWeb) {
        // On web, Drift is not available — show unsupported message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Follow-up save not supported on web')),
          );
          Navigator.pop(context, false);
        }
        return;
      }
      final localId = await DatabaseService.db.challengeDao.insertFollowup(
        LocalInterventionFollowupsCompanion.insert(
          childRemoteId: Value(widget.childRemoteId),
          screeningResultLocalId: Value(widget.screeningResultLocalId),
          followupConducted: Value(_followupConducted),
          improvementStatus: Value(_improvementStatus),
          reductionInDelayMonths: Value(_reductionInDelayMonths),
          domainImprovement: Value(_domainImprovement),
          exitHighRisk: Value(_exitHighRisk),
          notes: Value(_notesController.text.isEmpty
              ? null
              : _notesController.text),
          createdBy: Value(user?.supabaseId),
          followupDate:
              Value(DateTime.now().toIso8601String().split('T')[0]),
        ),
      );
      await DatabaseService.db.syncQueueDao.enqueue(
        entityType: 'followup',
        entityLocalId: localId,
        operation: 'insert',
        priority: 3,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow-up saved')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'ఫాలో-అప్ నమోదు' : 'Follow-up Entry'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Follow-up conducted?
            SwitchListTile(
              title: Text(isTelugu
                  ? 'ఫాలో-అప్ నిర్వహించబడిందా?'
                  : 'Follow-up Conducted?'),
              value: _followupConducted,
              onChanged: (v) => setState(() => _followupConducted = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Improvement status
            Text(
              isTelugu ? 'మెరుగుదల స్థితి' : 'Improvement Status',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'Improved',
                  label: Text(isTelugu ? 'మెరుగు' : 'Improved'),
                  icon: const Icon(Icons.trending_up, size: 18),
                ),
                ButtonSegment(
                  value: 'Same',
                  label: Text(isTelugu ? 'అదే' : 'Same'),
                  icon: const Icon(Icons.horizontal_rule, size: 18),
                ),
                ButtonSegment(
                  value: 'Worsened',
                  label: Text(isTelugu ? 'తీవ్రం' : 'Worsened'),
                  icon: const Icon(Icons.trending_down, size: 18),
                ),
              ],
              selected: {_improvementStatus},
              onSelectionChanged: (v) =>
                  setState(() => _improvementStatus = v.first),
            ),
            const SizedBox(height: 20),

            // Reduction in delay months
            Text(
              isTelugu
                  ? 'ఆలస్యంలో తగ్గింపు (నెలలు)'
                  : 'Reduction in Delay (months)',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _reductionInDelayMonths > 0
                      ? () => setState(() => _reductionInDelayMonths--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_reductionInDelayMonths',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _reductionInDelayMonths++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Domain improvement
            CheckboxListTile(
              title: Text(
                  isTelugu ? 'డొమైన్ మెరుగుదల' : 'Domain Improvement'),
              value: _domainImprovement,
              onChanged: (v) =>
                  setState(() => _domainImprovement = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            // Exit high risk
            CheckboxListTile(
              title: Text(isTelugu
                  ? 'హై రిస్క్ నుండి బయటపడ్డారా?'
                  : 'Exited High Risk?'),
              value: _exitHighRisk,
              onChanged: (v) => setState(() => _exitHighRisk = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isTelugu ? 'గమనికలు' : 'Notes',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.save),
                label: Text(
                  isTelugu ? 'సేవ్ చేయండి' : 'Save Follow-up',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
