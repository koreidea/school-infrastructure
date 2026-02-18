import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

/// Bilingual (EN/TE) privacy policy screen — DPDP Act 2023 compliance.
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'గోప్యతా విధానం' : 'Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.shield, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  isTelugu
                      ? 'డిజిటల్ వ్యక్తిగత డేటా రక్షణ చట్టం, 2023'
                      : 'Digital Personal Data Protection Act, 2023',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTelugu ? 'సంస్కరణ 1.0 | ఫిబ్రవరి 2026' : 'Version 1.0 | February 2026',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.info_outline,
            titleEn: '1. Introduction & Scope',
            titleTe: '1. పరిచయం & పరిధి',
            contentEn:
                'This Privacy Policy describes how the Bal Vikas Early Childhood Development Platform ("Platform") collects, uses, stores, and protects personal data of children aged 0-6 years and their guardians, in compliance with the Digital Personal Data Protection Act, 2023 (DPDP Act).\n\n'
                'The Platform is operated under the oversight of the Women Development & Child Welfare Department (WD&CW), Government of Andhra Pradesh, as part of the Integrated Child Development Services (ICDS) program.',
            contentTe:
                'ఈ గోప్యతా విధానం బాల్ వికాస్ ప్రారంభ బాల్య అభివృద్ధి వేదిక ("వేదిక") 0-6 సంవత్సరాల పిల్లలు మరియు వారి సంరక్షకుల వ్యక్తిగత డేటాను ఎలా సేకరిస్తుంది, ఉపయోగిస్తుంది, నిల్వ చేస్తుంది మరియు రక్షిస్తుంది అనే విషయాలను వివరిస్తుంది.\n\n'
                'ఈ వేదిక ఆంధ్రప్రదేశ్ ప్రభుత్వం, మహిళా అభివృద్ధి & శిశు సంక్షేమ శాఖ (WD&CW) పర్యవేక్షణలో నిర్వహించబడుతుంది.',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.business,
            titleEn: '2. Data Fiduciary',
            titleTe: '2. డేటా విశ్వసనీయుడు',
            contentEn:
                'The Data Fiduciary under DPDP Act is:\n\n'
                'Women Development & Child Welfare Department\n'
                'Government of Andhra Pradesh\n'
                'Secretariat, Velagapudi, Amaravati\n'
                'Andhra Pradesh, India',
            contentTe:
                'DPDP చట్టం ప్రకారం డేటా విశ్వసనీయుడు:\n\n'
                'మహిళా అభివృద్ధి & శిశు సంక్షేమ శాఖ\n'
                'ఆంధ్రప్రదేశ్ ప్రభుత్వం\n'
                'సచివాలయం, వెలగపూడి, అమరావతి\n'
                'ఆంధ్రప్రదేశ్, భారతదేశం',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.list_alt,
            titleEn: '3. Personal Data Collected',
            titleTe: '3. సేకరించబడే వ్యక్తిగత డేటా',
            contentEn:
                'We collect the following categories of personal data:\n\n'
                'Child Data:\n'
                '• Name, date of birth, gender\n'
                '• Anganwadi Centre (AWC) assignment\n'
                '• Developmental screening responses (CDC, RBSK, MCHAT, ISAA, ADHD, SDQ)\n'
                '• Nutritional measurements (height, weight, MUAC)\n'
                '• Health assessment results and risk classifications\n'
                '• Referral and intervention records\n\n'
                'Guardian Data:\n'
                '• Name, phone number, relation to child\n'
                '• Consent records and signatures\n\n'
                'Staff Data:\n'
                '• Name, phone number, role, assigned location',
            contentTe:
                'మేము ఈ కింది వ్యక్తిగత డేటా వర్గాలను సేకరిస్తాము:\n\n'
                'పిల్లల డేటా:\n'
                '• పేరు, పుట్టిన తేదీ, లింగం\n'
                '• అంగన్వాడి కేంద్రం (AWC) కేటాయింపు\n'
                '• అభివృద్ధి పరీక్ష ప్రతిస్పందనలు (CDC, RBSK, MCHAT, ISAA, ADHD, SDQ)\n'
                '• పోషకాహార కొలతలు (ఎత్తు, బరువు, MUAC)\n'
                '• ఆరోగ్య మూల్యాంకన ఫలితాలు మరియు ప్రమాద వర్గీకరణలు\n'
                '• రిఫరల్ మరియు జోక్యం రికార్డులు\n\n'
                'సంరక్షకుల డేటా:\n'
                '• పేరు, ఫోన్ నంబర్, పిల్లలతో సంబంధం\n'
                '• అనుమతి రికార్డులు మరియు సంతకాలు',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.track_changes,
            titleEn: '4. Purpose of Processing',
            titleTe: '4. ప్రాసెసింగ్ ఉద్దేశ్యం',
            contentEn:
                'Personal data is processed exclusively for:\n\n'
                '1. Early identification of developmental delays and disabilities\n'
                '2. Risk stratification and prioritization of children\n'
                '3. Generating referrals to healthcare professionals\n'
                '4. Planning personalized, age-appropriate interventions\n'
                '5. Monitoring developmental progress over time\n'
                '6. Program performance evaluation and reporting\n'
                '7. Capacity building and workforce training',
            contentTe:
                'వ్యక్తిగత డేటా ప్రత్యేకంగా ఈ కింది ఉద్దేశ్యాలకు మాత్రమే ప్రాసెస్ చేయబడుతుంది:\n\n'
                '1. అభివృద్ధి ఆలస్యాలు మరియు వైకల్యాలను ముందుగా గుర్తించడం\n'
                '2. పిల్లల ప్రమాద స్తరీకరణ మరియు ప్రాధాన్యత\n'
                '3. ఆరోగ్య నిపుణులకు రిఫరల్స్ రూపొందించడం\n'
                '4. వ్యక్తిగత, వయస్సుకు తగిన జోక్యాలను ప్రణాళిక చేయడం\n'
                '5. కాలక్రమేణా అభివృద్ధి పురోగతిని పర్యవేక్షించడం\n'
                '6. కార్యక్రమ పనితీరు మూల్యాంకనం మరియు నివేదికలు',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.gavel,
            titleEn: '5. Legal Basis (DPDP Act)',
            titleTe: '5. చట్టపరమైన ఆధారం (DPDP చట్టం)',
            contentEn:
                '• Section 4: Processing based on consent of the Data Principal\n'
                '• Section 7: Consent must be free, specific, informed, unconditional, and unambiguous\n'
                '• Section 9: Special protections for children\'s data — requires verifiable consent from parent/lawful guardian\n'
                '• Section 17: Government processing for welfare programs (ICDS)',
            contentTe:
                '• సెక్షన్ 4: డేటా ప్రిన్సిపల్ అనుమతి ఆధారంగా ప్రాసెసింగ్\n'
                '• సెక్షన్ 7: అనుమతి స్వేచ్ఛగా, నిర్దిష్టంగా, సమాచారంతో, షరతులు లేకుండా ఉండాలి\n'
                '• సెక్షన్ 9: పిల్లల డేటాకు ప్రత్యేక రక్షణలు — తల్లిదండ్రులు/సంరక్షకుడి ధృవీకరణ అనుమతి అవసరం\n'
                '• సెక్షన్ 17: సంక్షేమ కార్యక్రమాల (ICDS) కోసం ప్రభుత్వ ప్రాసెసింగ్',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.child_care,
            titleEn: '6. Children\'s Data Protection',
            titleTe: '6. పిల్లల డేటా రక్షణ',
            contentEn:
                'Under Section 9 of the DPDP Act:\n\n'
                '• Processing of children\'s data requires verifiable consent from a parent or lawful guardian\n'
                '• No behavioral tracking or profiling of children for commercial purposes\n'
                '• No targeted advertising directed at children\n'
                '• Data is used solely for child welfare and development purposes\n'
                '• Children\'s data is subject to enhanced security measures',
            contentTe:
                'DPDP చట్టం సెక్షన్ 9 ప్రకారం:\n\n'
                '• పిల్లల డేటా ప్రాసెసింగ్‌కు తల్లిదండ్రులు లేదా సంరక్షకుడి ధృవీకరణ అనుమతి అవసరం\n'
                '• వాణిజ్య ఉద్దేశ్యాల కోసం పిల్లల ప్రవర్తన ట్రాకింగ్ లేదా ప్రొఫైలింగ్ లేదు\n'
                '• పిల్లలకు లక్ష్యంగా చేసుకున్న ప్రకటనలు లేవు\n'
                '• డేటా కేవలం పిల్లల సంక్షేమం మరియు అభివృద్ధి ఉద్దేశ్యాలకు మాత్రమే ఉపయోగించబడుతుంది',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.share,
            titleEn: '7. Data Sharing & Access Controls',
            titleTe: '7. డేటా భాగస్వామ్యం & ప్రాప్యత నియంత్రణలు',
            contentEn:
                'Access to personal data is strictly role-based:\n\n'
                '• Parent: Own children\'s data only\n'
                '• AWW (Anganwadi Worker): Children at their assigned centre\n'
                '• Supervisor: Children across their sector\n'
                '• CDPO: Children across their project/mandal\n'
                '• District Officer: Aggregated district-level data\n'
                '• Senior Official: Aggregated state-level data\n\n'
                'Higher-level officials see aggregated/anonymized reports. Individual child data is accessible only to direct service providers (AWW, Supervisor).',
            contentTe:
                'వ్యక్తిగత డేటా ప్రాప్యత కఠినంగా పాత్ర-ఆధారితం:\n\n'
                '• తల్లిదండ్రి: తమ పిల్లల డేటా మాత్రమే\n'
                '• AWW (అంగన్వాడి వర్కర్): వారి కేంద్రంలోని పిల్లలు\n'
                '• సూపర్వైజర్: వారి సెక్టార్ లోని పిల్లలు\n'
                '• CDPO: వారి ప్రాజెక్ట్/మండలంలోని పిల్లలు\n'
                '• జిల్లా అధికారి: సమగ్ర జిల్లా-స్థాయి డేటా\n'
                '• సీనియర్ అధికారి: సమగ్ర రాష్ట్ర-స్థాయి డేటా',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.schedule,
            titleEn: '8. Data Retention Policy',
            titleTe: '8. డేటా భద్రపరచే విధానం',
            contentEn:
                '• Active data: Retained during child\'s enrollment in ICDS program\n'
                '• Post-enrollment: Retained for 3 years after program exit\n'
                '• Aggregated data: May be retained indefinitely for research/analysis\n'
                '• Deleted data: Permanently removed upon verified erasure request\n'
                '• Audit logs: Retained for 5 years for compliance verification',
            contentTe:
                '• క్రియాశీల డేటా: ICDS కార్యక్రమంలో పిల్లల నమోదు సమయంలో భద్రపరచబడుతుంది\n'
                '• నమోదు తర్వాత: కార్యక్రమం నుండి నిష్క్రమణ తర్వాత 3 సంవత్సరాల పాటు భద్రపరచబడుతుంది\n'
                '• సమగ్ర డేటా: పరిశోధన/విశ్లేషణ కోసం నిరవధికంగా భద్రపరచబడవచ్చు\n'
                '• తొలగించబడిన డేటా: ధృవీకరించబడిన తొలగింపు అభ్యర్థన మేరకు శాశ్వతంగా తొలగించబడుతుంది',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.person,
            titleEn: '9. Data Principal Rights',
            titleTe: '9. డేటా ప్రిన్సిపల్ హక్కులు',
            contentEn:
                'Under the DPDP Act, you have the right to:\n\n'
                '1. Right to Access: View all personal data held about your child\n'
                '2. Right to Correction: Request correction of inaccurate or incomplete data\n'
                '3. Right to Erasure: Request deletion of personal data\n'
                '4. Right to Withdraw Consent: Withdraw consent at any time\n'
                '5. Right to Grievance Redressal: File complaints regarding data processing\n\n'
                'To exercise these rights, contact your assigned AWW or CDPO.',
            contentTe:
                'DPDP చట్టం ప్రకారం, మీకు ఈ హక్కులు ఉన్నాయి:\n\n'
                '1. ప్రాప్యత హక్కు: మీ బిడ్డ గురించి ఉన్న అన్ని వ్యక్తిగత డేటాను చూడటం\n'
                '2. సవరణ హక్కు: తప్పుడు లేదా అసంపూర్ణ డేటాను సరిదిద్దమని అభ్యర్థించడం\n'
                '3. తొలగింపు హక్కు: వ్యక్తిగత డేటా తొలగింపును అభ్యర్థించడం\n'
                '4. అనుమతి ఉపసంహరణ హక్కు: ఎప్పుడైనా అనుమతిని ఉపసంహరించుకోవడం\n'
                '5. ఫిర్యాదు పరిష్కార హక్కు: డేటా ప్రాసెసింగ్ గురించి ఫిర్యాదులు దాఖలు చేయడం\n\n'
                'ఈ హక్కులను వినియోగించడానికి, మీ AWW లేదా CDPOని సంప్రదించండి.',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.security,
            titleEn: '10. Security Measures',
            titleTe: '10. భద్రతా చర్యలు',
            contentEn:
                '• Role-based access controls at application and database levels\n'
                '• Encrypted data transmission (TLS/HTTPS)\n'
                '• Offline-first architecture with secure local storage\n'
                '• Audit logging of all data access events\n'
                '• Data anonymization for aggregated reports\n'
                '• Regular security assessments and updates',
            contentTe:
                '• అనువర్తనం మరియు డేటాబేస్ స్థాయిలలో పాత్ర-ఆధారిత ప్రాప్యత నియంత్రణలు\n'
                '• ఎన్‌క్రిప్టెడ్ డేటా ప్రసారం (TLS/HTTPS)\n'
                '• సురక్షిత స్థానిక నిల్వతో ఆఫ్‌లైన్-ఫస్ట్ ఆర్కిటెక్చర్\n'
                '• అన్ని డేటా ప్రాప్యత సంఘటనల ఆడిట్ లాగింగ్\n'
                '• సమగ్ర నివేదికల కోసం డేటా అనామకీకరణ',
            isTelugu: isTelugu,
          ),

          _buildSection(
            icon: Icons.support_agent,
            titleEn: '11. Grievance Redressal & Contact',
            titleTe: '11. ఫిర్యాదు పరిష్కారం & సంప్రదించడం',
            contentEn:
                'For data protection queries or to exercise your rights:\n\n'
                '• Contact your assigned Anganwadi Worker (AWW)\n'
                '• Contact your sector CDPO office\n'
                '• District Welfare Officer (DWO)\n\n'
                'Women Development & Child Welfare Department\n'
                'Government of Andhra Pradesh\n'
                'Secretariat, Velagapudi, Amaravati',
            contentTe:
                'డేటా రక్షణ ప్రశ్నల కోసం లేదా మీ హక్కులను వినియోగించడానికి:\n\n'
                '• మీ కేటాయించిన అంగన్వాడి వర్కర్ (AWW)ని సంప్రదించండి\n'
                '• మీ సెక్టార్ CDPO కార్యాలయాన్ని సంప్రదించండి\n'
                '• జిల్లా సంక్షేమ అధికారి (DWO)\n\n'
                'మహిళా అభివృద్ధి & శిశు సంక్షేమ శాఖ\n'
                'ఆంధ్రప్రదేశ్ ప్రభుత్వం\n'
                'సచివాలయం, వెలగపూడి, అమరావతి',
            isTelugu: isTelugu,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String titleEn,
    required String titleTe,
    required String contentEn,
    required String contentTe,
    required bool isTelugu,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          isTelugu ? titleTe : titleEn,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        childrenPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          // Primary language
          Text(
            isTelugu ? contentTe : contentEn,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          const Divider(height: 24),
          // Secondary language (smaller)
          Text(
            isTelugu ? contentEn : contentTe,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
