import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consent_provider.dart';
import '../../widgets/signature_pad.dart';

/// Full-screen consent capture form — DPDP Act 2023 Section 9 compliance.
///
/// Shown during child registration or before first screening.
/// Records guardian name, relation, consent text acknowledgment,
/// and finger-drawn digital signature.
class ConsentCaptureScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> child;

  const ConsentCaptureScreen({super.key, required this.child});

  @override
  ConsumerState<ConsentCaptureScreen> createState() =>
      _ConsentCaptureScreenState();
}

class _ConsentCaptureScreenState extends ConsumerState<ConsentCaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _signatureKey = GlobalKey<SignaturePadState>();

  String _guardianRelation = 'mother';
  bool _consentChecked = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    final childName = widget.child['name'] as String? ??
        widget.child['child_name'] as String? ??
        '';
    final childDob = widget.child['date_of_birth'] as String? ?? '';
    final childId = widget.child['child_id'] as int? ??
        widget.child['id'] as int? ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu
            ? 'సంరక్షకుడి అనుమతి'
            : 'Guardian Consent'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // DPDP badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTelugu
                          ? 'DPDP చట్టం 2023, సెక్షన్ 9 ప్రకారం'
                          : 'As per DPDP Act 2023, Section 9',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Child info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Icons.child_care,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (childDob.isNotEmpty)
                            Text(
                              '${isTelugu ? 'పుట్టిన తేదీ' : 'DOB'}: $childDob',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Guardian details section
            Text(
              isTelugu ? 'సంరక్షకుడి వివరాలు' : 'Guardian Details',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Guardian name
            TextFormField(
              controller: _guardianNameController,
              decoration: InputDecoration(
                labelText: isTelugu ? 'సంరక్షకుడి పేరు *' : 'Guardian Name *',
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return isTelugu
                      ? 'సంరక్షకుడి పేరు అవసరం'
                      : 'Guardian name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Guardian relation
            DropdownButtonFormField<String>(
              value: _guardianRelation,
              decoration: InputDecoration(
                labelText: isTelugu ? 'సంబంధం *' : 'Relation *',
                prefixIcon: const Icon(Icons.family_restroom),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: 'mother',
                    child: Text(isTelugu ? 'తల్లి (Mother)' : 'Mother')),
                DropdownMenuItem(
                    value: 'father',
                    child: Text(isTelugu ? 'తండ్రి (Father)' : 'Father')),
                DropdownMenuItem(
                    value: 'guardian',
                    child: Text(isTelugu
                        ? 'సంరక్షకుడు (Guardian)'
                        : 'Guardian')),
              ],
              onChanged: (v) => setState(() => _guardianRelation = v ?? 'mother'),
            ),
            const SizedBox(height: 12),

            // Guardian phone (optional)
            TextFormField(
              controller: _guardianPhoneController,
              decoration: InputDecoration(
                labelText: isTelugu
                    ? 'ఫోన్ నంబర్ (ఐచ్ఛికం)'
                    : 'Phone Number (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Consent text
            Text(
              isTelugu
                  ? 'డేటా సేకరణ అనుమతి పత్రం'
                  : 'Data Collection Consent Notice',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Container(
              height: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTelugu) ...[
                      _consentSectionTe(),
                      const Divider(height: 24),
                      _consentSectionEn(),
                    ] else ...[
                      _consentSectionEn(),
                      const Divider(height: 24),
                      _consentSectionTe(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Signature section
            Text(
              isTelugu
                  ? 'సంరక్షకుడి సంతకం'
                  : 'Guardian Signature',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SignaturePad(
              key: _signatureKey,
              height: 120,
              clearLabel: isTelugu ? 'క్లియర్' : 'Clear',
            ),
            const SizedBox(height: 16),

            // Consent checkbox
            CheckboxListTile(
              value: _consentChecked,
              onChanged: (v) => setState(() => _consentChecked = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                isTelugu
                    ? 'నేను, ${_guardianNameController.text.isNotEmpty ? _guardianNameController.text : '[సంరక్షకుడి పేరు]'}, పైన పేర్కొన్న సమాచార సేకరణకు నా అనుమతి ఇస్తున్నాను.'
                    : 'I, ${_guardianNameController.text.isNotEmpty ? _guardianNameController.text : '[Guardian Name]'}, give my consent for the above-mentioned data collection.',
                style: const TextStyle(fontSize: 13),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Timestamp
            Text(
              '${isTelugu ? 'తేదీ' : 'Date'}: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}  '
              '${isTelugu ? 'సమయం' : 'Time'}: ${TimeOfDay.now().format(context)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    label: Text(isTelugu ? 'తిరస్కరించండి' : 'Decline'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving || !_consentChecked
                        ? null
                        : () => _saveConsent(childId, childName),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.verified_user),
                    label: Text(
                        isTelugu ? 'అనుమతి ఇవ్వండి' : 'Give Consent'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _saveConsent(int childId, String childName) async {
    if (!_formKey.currentState!.validate()) return;

    final signatureState = _signatureKey.currentState;
    if (signatureState == null || signatureState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(languageProvider) == 'te'
              ? 'దయచేసి సంతకం చేయండి'
              : 'Please provide your signature'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final signatureBase64 = await signatureState.toBase64Png();
      final user = ref.read(currentUserProvider);
      final language = ref.read(languageProvider);

      await ref.read(consentProvider.notifier).saveConsent(
            childRemoteId: childId,
            guardianName: _guardianNameController.text.trim(),
            guardianRelation: _guardianRelation,
            guardianPhone: _guardianPhoneController.text.trim().isEmpty
                ? null
                : _guardianPhoneController.text.trim(),
            consentPurpose: 'data_collection',
            collectedByUserId: user?.supabaseId ?? '${user?.userId}',
            collectedByRole: user?.roleCode ?? 'AWW',
            digitalSignatureBase64: signatureBase64,
            languageUsed: language,
            childName: childName,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'te'
                ? 'అనుమతి విజయవంతంగా నమోదు చేయబడింది'
                : 'Consent recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _consentSectionEn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purpose of Data Collection:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          'The Bal Vikas Early Childhood Development Platform collects your child\'s personal data including: name, date of birth, gender, developmental screening responses, nutritional measurements, and health assessment results.',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'This data is used solely for:\n'
          '(1) Developmental screening and early identification of delays\n'
          '(2) Generating referrals to healthcare professionals\n'
          '(3) Planning age-appropriate interventions and home activities\n'
          '(4) Monitoring progress over time\n'
          '(5) Aggregated reporting for government program evaluation',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'Data Access:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          'Your child\'s data is accessible to the assigned Anganwadi Worker (AWW) and their supervisory hierarchy (Supervisor, CDPO, District Welfare Officer). Aggregated, anonymized data may be used for state-level reporting.',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'Your Rights:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          'You have the right to:\n'
          '(1) Access your child\'s data\n'
          '(2) Request correction of inaccurate data\n'
          '(3) Withdraw consent at any time\n'
          '(4) Request erasure of data\n\n'
          'Contact your AWW or CDPO to exercise these rights.',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'Data Retention: Data will be retained for the duration of the child\'s enrollment in the ICDS program, plus 3 years after exit, unless earlier deletion is requested.',
          style: TextStyle(fontSize: 12.5),
        ),
      ],
    );
  }

  Widget _consentSectionTe() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'సమాచార సేకరణ ఉద్దేశ్యం:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          'బాల్ వికాస్ ప్రారంభ బాల్య అభివృద్ధి వేదిక మీ బిడ్డ వ్యక్తిగత డేటాను సేకరిస్తుంది: పేరు, పుట్టిన తేదీ, లింగం, అభివృద్ధి పరీక్ష ప్రతిస్పందనలు, పోషకాహార కొలతలు, మరియు ఆరోగ్య మూల్యాంకన ఫలితాలు.',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'ఈ డేటా కేవలం ఈ కింది ఉద్దేశ్యాలకు మాత్రమే ఉపయోగించబడుతుంది:\n'
          '(1) అభివృద్ధి పరీక్ష మరియు ఆలస్యాలను ముందుగా గుర్తించడం\n'
          '(2) ఆరోగ్య నిపుణులకు రిఫరల్స్ రూపొందించడం\n'
          '(3) వయస్సుకు తగిన జోక్యాలు మరియు ఇంటి కార్యకలాపాలను ప్లాన్ చేయడం\n'
          '(4) కాలక్రమేణా పురోగతిని పర్యవేక్షించడం\n'
          '(5) ప్రభుత్వ కార్యక్రమ మూల్యాంకనం కోసం సమగ్ర నివేదికలు',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'డేటా ప్రాప్యత:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          'మీ బిడ్డ డేటాను కేటాయించిన అంగన్వాడి వర్కర్ (AWW) మరియు వారి పర్యవేక్షణ శ్రేణి (సూపర్వైజర్, CDPO, జిల్లా సంక్షేమ అధికారి) ప్రాప్యత కలిగి ఉంటారు.',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'మీ హక్కులు:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          'మీకు ఈ హక్కులు ఉన్నాయి:\n'
          '(1) మీ బిడ్డ డేటాను చూడడం\n'
          '(2) తప్పుడు డేటాను సరిదిద్దమని అభ్యర్థించడం\n'
          '(3) ఎప్పుడైనా అనుమతిని ఉపసంహరించుకోవడం\n'
          '(4) డేటా తొలగింపును అభ్యర్థించడం\n\n'
          'ఈ హక్కులను వినియోగించడానికి మీ AWW లేదా CDPOని సంప్రదించండి.',
          style: TextStyle(fontSize: 12.5),
        ),
        SizedBox(height: 8),
        Text(
          'డేటా భద్రపరచడం: ICDS కార్యక్రమంలో బిడ్డ నమోదు కాలం + నిష్క్రమణ తర్వాత 3 సంవత్సరాల పాటు డేటా భద్రపరచబడుతుంది.',
          style: TextStyle(fontSize: 12.5),
        ),
      ],
    );
  }
}
