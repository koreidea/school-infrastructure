import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/schools_provider.dart';
import '../../l10n/app_localizations.dart';

class RaiseDemandScreen extends ConsumerStatefulWidget {
  const RaiseDemandScreen({super.key});

  @override
  ConsumerState<RaiseDemandScreen> createState() => _RaiseDemandScreenState();
}

class _RaiseDemandScreenState extends ConsumerState<RaiseDemandScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedInfraType;
  int _quantity = 1;
  late String _planYear;
  String _justification = '';
  bool _submitting = false;

  final _quantityController = TextEditingController(text: '1');
  final _justificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    _planYear = '$startYear';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  double get _unitCost =>
      _selectedInfraType != null
          ? (AppConstants.unitCosts[_selectedInfraType] ?? 0)
          : 0;

  double get _totalCost => _quantity * _unitCost;

  List<String> get _availableYears {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    return List.generate(3, (i) => '${startYear + i}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('hm_raise_request')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.construction, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('hm_raise_request'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Submit infrastructure requirements for your school',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 1. Infrastructure Type
              Text(l10n.translate('hm_infra_type'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedInfraType,
                hint: const Text('Select infrastructure type'),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: AppConstants.allInfraTypes.map((type) {
                  final cost = AppConstants.unitCosts[type] ?? 0;
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      '${AppConstants.infraTypeLabel(type)} (₹${cost.toStringAsFixed(2)}L)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedInfraType = val),
                validator: (val) =>
                    val == null ? 'Please select an infrastructure type' : null,
              ),

              // Show selected type info
              if (_selectedInfraType != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.forInfraType(_selectedInfraType!).withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(AppConstants.infraTypeIcon(_selectedInfraType!),
                          size: 20,
                          color: AppColors.forInfraType(_selectedInfraType!)),
                      const SizedBox(width: 8),
                      Text(
                        '₹${_unitCost.toStringAsFixed(2)} Lakhs ${l10n.translate('hm_per_unit')}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.forInfraType(_selectedInfraType!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // 2. Quantity
              Text(l10n.translate('hm_quantity'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: const Icon(Icons.inventory_2),
                  hintText: '1-10',
                ),
                onChanged: (v) => setState(() => _quantity = int.tryParse(v) ?? 1),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Minimum 1 unit';
                  if (n > 10) return 'Maximum 10 units per request';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Auto-Calculated Cost
              if (_selectedInfraType != null) ...[
                Text(l10n.translate('hm_estimated_cost'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '₹${_totalCost.toStringAsFixed(2)} Lakhs',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_quantity × ₹${_unitCost.toStringAsFixed(2)}L = ₹${_totalCost.toStringAsFixed(2)}L',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.translate('hm_auto_cost'),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Plan Year
              Text(l10n.translate('hm_plan_year'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _planYear,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                items: _availableYears.map((y) {
                  final nextY = (int.parse(y) + 1) % 100;
                  return DropdownMenuItem<String>(
                    value: y,
                    child: Text('$y-${nextY.toString().padLeft(2, '0')}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _planYear = val);
                },
              ),
              const SizedBox(height: 20),

              // 5. Justification
              Text(l10n.translate('hm_justification'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _justificationController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'Describe why this infrastructure is needed...',
                  hintStyle: const TextStyle(fontSize: 13),
                ),
                onChanged: (v) => _justification = v,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _submitting
                        ? 'Submitting...'
                        : l10n.translate('hm_submit_request'),
                    style: const TextStyle(fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInfraType == null) return;

    final l10n = AppLocalizations.of(context);
    final schoolId = ref.read(effectiveSchoolIdProvider);
    if (schoolId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No school assigned to your account'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check for duplicate
    final existingDemands = ref.read(demandPlansProvider).value ?? [];
    final hasDuplicate = existingDemands.any((d) =>
        d.infraType == _selectedInfraType &&
        d.planYear == int.parse(_planYear) &&
        d.isAIPending &&
        d.isOfficerPending);

    if (hasDuplicate) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Duplicate Request'),
          content: Text(l10n.translate('hm_duplicate_warning')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.translate('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _submitting = true);

    final success =
        await ref.read(createDemandProvider.notifier).createDemandPlan(
              schoolId: schoolId,
              planYear: int.parse(_planYear),
              infraType: _selectedInfraType!,
              physicalCount: _quantity,
              financialAmount: _totalCost,
              justification:
                  _justification.isNotEmpty ? _justification : null,
            );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      final resultMsg = ref.read(createDemandProvider).value;
      final isOffline = resultMsg?.contains('offline') ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOffline
                ? l10n.translate('hm_request_saved_offline')
                : l10n.translate('hm_request_submitted'),
          ),
          backgroundColor:
              isOffline ? AppColors.statusFlagged : AppColors.statusApproved,
        ),
      );
      Navigator.pop(context);
    }
  }
}
