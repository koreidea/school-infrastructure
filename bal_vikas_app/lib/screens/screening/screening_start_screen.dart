import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/children_provider.dart';
import '../../providers/screening_provider.dart';
import '../../providers/screening_hub_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import 'screening_hub_screen.dart';
import '../../utils/telugu_transliterator.dart';
import '../../services/audit_service.dart';
import '../../providers/consent_provider.dart';
import '../consent/consent_capture_screen.dart';

class ScreeningStartScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? child;

  const ScreeningStartScreen({super.key, this.child});

  @override
  ConsumerState<ScreeningStartScreen> createState() => _ScreeningStartScreenState();
}

class _ScreeningStartScreenState extends ConsumerState<ScreeningStartScreen> {
  Map<String, dynamic>? _selectedChild;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedChild = widget.child;
  }

  int _getChildAgeMonths([Map<String, dynamic>? child]) {
    final c = child ?? _selectedChild;
    if (c == null) return 24;
    final dob = c['date_of_birth'] as String?;
    if (dob != null && dob.isNotEmpty) {
      try {
        final dobDate = DateTime.parse(dob);
        final now = DateTime.now();
        int months = (now.year - dobDate.year) * 12 + (now.month - dobDate.month);
        if (now.day < dobDate.day) months--;
        return months < 0 ? 0 : months;
      } catch (_) {}
    }
    return (c['age_months'] as int?) ?? 24;
  }

  Future<void> _startScreening() async {
    if (_selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child')),
      );
      return;
    }

    // Check guardian consent before screening
    final childId = _selectedChild!['child_id'] as int? ?? 0;
    final consentState = ref.read(consentProvider);
    final hasConsent = consentState.value?[childId] ?? false;
    if (!hasConsent) {
      final language = ref.read(languageProvider);
      final isTelugu = language == 'te';
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(child: Text(isTelugu ? 'అనుమతి అవసరం' : 'Consent Required')),
            ],
          ),
          content: Text(isTelugu
              ? 'DPDP చట్టం 2023 ప్రకారం, తనిఖీకి ముందు సంరక్షకుడి అనుమతి అవసరం. ఇప్పుడు అనుమతి నమోదు చేయాలా?'
              : 'Under DPDP Act 2023, guardian consent is required before screening. Record consent now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isTelugu ? 'రద్దు' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(isTelugu ? 'అనుమతి నమోదు చేయండి' : 'Record Consent',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (shouldProceed == true && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConsentCaptureScreen(child: _selectedChild!),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final childAgeMonths = _getChildAgeMonths();

    // Get user's users.id (table UUID) for conducted_by — NOT auth.uid()
    final currentUser = ref.read(currentUserProvider);
    final conductedBy = currentUser?.supabaseId ?? '';

    final mockSession = {
      'session_id': DateTime.now().millisecondsSinceEpoch,
      'child_id': _selectedChild!['child_id'],
      'conducted_by': conductedBy,
      'assessment_date': DateTime.now().toIso8601String().split('T')[0],
      'child_age_months': childAgeMonths,
      'status': 'in_progress',
      'device_session_id': 'dev_${DateTime.now().millisecondsSinceEpoch}',
    };

    ref.read(screeningSessionProvider.notifier).set(mockSession);

    // Reset hub if it's a different child OR if the previous session is already done
    final existingHub = ref.read(screeningHubProvider);
    final existingChildId = existingHub?.child['child_id'];
    final newChildId = _selectedChild!['child_id'];
    if (existingChildId != newChildId || (existingHub?.allDone ?? false)) {
      ref.read(screeningHubProvider.notifier).reset();
    }

    // Audit log
    AuditService.log(
      action: 'start_screening',
      entityType: 'screening_session',
      entityId: _selectedChild!['child_id'] as int?,
      entityName: _selectedChild!['name'] as String?,
    );

    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScreeningHubScreen(
          session: mockSession,
          child: _selectedChild!,
          childAgeMonths: childAgeMonths,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'కొత్త తనిఖీ' : 'New Screening'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Child
            Text(
              isTelugu ? 'పిల్లవాడిని ఎంచుకోండి' : 'Select Child',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedChild != null)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (_selectedChild!['gender'] == 'male'
                            ? Colors.blue
                            : Colors.pink)
                        .shade100,
                    child: Icon(
                      _selectedChild!['gender'] == 'male'
                          ? Icons.boy
                          : Icons.girl,
                      color: _selectedChild!['gender'] == 'male'
                          ? Colors.blue
                          : Colors.pink,
                    ),
                  ),
                  title: Text(_selectedChild!['name'] ?? 'Unknown'),
                  subtitle: Text(
                    '${_getChildAgeMonths()} ${isTelugu ? 'నెలలు' : 'months'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _selectedChild = null),
                  ),
                ),
              )
            else
              childrenAsync.when(
                data: (children) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (child['gender'] == 'male'
                                  ? Colors.blue
                                  : Colors.pink)
                              .shade100,
                          child: Icon(
                            child['gender'] == 'male'
                                ? Icons.boy
                                : Icons.girl,
                            color: child['gender'] == 'male'
                                ? Colors.blue
                                : Colors.pink,
                          ),
                        ),
                        title: Text(isTelugu
                            ? toTelugu(child['name'] ?? 'Unknown')
                            : (child['name'] ?? 'Unknown')),
                        subtitle: Text(
                          '${_getChildAgeMonths(child)} ${isTelugu ? 'నెలలు' : 'months'}',
                        ),
                        onTap: () => setState(() => _selectedChild = child),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
              ),
            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startScreening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isTelugu ? 'తనిఖీ ప్రారంభించండి' : 'Start Screening',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
