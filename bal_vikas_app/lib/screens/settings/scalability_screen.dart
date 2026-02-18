import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

/// In-app scalability architecture showcase
class ScalabilityScreen extends ConsumerWidget {
  const ScalabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'స్కేలబిలిటీ ఆర్కిటెక్చర్' : 'Scalability Architecture'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.rocket_launch, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isTelugu
                              ? 'పైలట్ నుండి జాతీయ స్థాయికి'
                              : 'From Pilot to National Scale',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                      isTelugu
                          ? '10 AWCలు → 13.7 లక్షల AWCలు\n200 పిల్లలు → 8+ కోట్ల పిల్లలు'
                          : '10 AWCs → 13.7 Lakh AWCs\n200 Children → 8+ Crore Children',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Scaling Phases
            Text(
              isTelugu ? 'స్కేలింగ్ దశలు' : 'Scaling Phases',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _PhaseCard(
              phase: '1',
              title: isTelugu ? 'పైలట్ (ప్రస్తుతం)' : 'Pilot (Current)',
              stats: isTelugu
                  ? '10 AWCలు • 200 పిల్లలు • 20 వినియోగదారులు'
                  : '10 AWCs • 200 Children • 20 Users',
              color: AppColors.riskLow,
              isActive: true,
            ),
            _PhaseCard(
              phase: '2',
              title: isTelugu ? 'జిల్లా స్థాయి' : 'District Scale',
              stats: isTelugu
                  ? '150 AWCలు • 3,000 పిల్లలు • 200 వినియోగదారులు'
                  : '150 AWCs • 3,000 Children • 200 Users',
              color: AppColors.riskMedium,
            ),
            _PhaseCard(
              phase: '3',
              title: isTelugu ? 'రాష్ట్ర స్థాయి' : 'State Scale',
              stats: isTelugu
                  ? '3,250 AWCలు • 65,000 పిల్లలు • 4,000 వినియోగదారులు'
                  : '3,250 AWCs • 65,000 Children • 4,000 Users',
              color: Colors.orange,
            ),
            _PhaseCard(
              phase: '4',
              title: isTelugu ? 'జాతీయ స్థాయి' : 'National Scale',
              stats: isTelugu
                  ? '13.7 లక్షల AWCలు • 8+ కోట్ల పిల్లలు'
                  : '13.7 Lakh AWCs • 8+ Crore Children',
              color: AppColors.riskHigh,
            ),
            const SizedBox(height: 24),

            // Architecture Pillars
            Text(
              isTelugu ? 'ఆర్కిటెక్చర్ స్తంభాలు' : 'Architecture Pillars',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _PillarCard(
              icon: Icons.cloud_off,
              title: isTelugu ? 'ఆఫ్‌లైన్-ఫస్ట్' : 'Offline-First',
              description: isTelugu
                  ? 'ఇంటర్నెట్ లేకుండా పూర్తి స్క్రీనింగ్. డేటా స్థానికంగా నిల్వ, కనెక్ట్ అయినప్పుడు ఆటోమేటిక్ సింక్.'
                  : 'Full screening without internet. Data stored locally in SQLite, auto-syncs when connected.',
              items: isTelugu
                  ? ['Drift SQLite స్థానిక DB', 'ప్రాధాన్యత క్రమ సింక్ క్యూ', 'ఆటోమేటిక్ రీట్రై']
                  : ['Drift SQLite local DB', 'Priority-ordered sync queue', 'Automatic retry on reconnect'],
            ),
            _PillarCard(
              icon: Icons.account_tree,
              title: isTelugu ? 'ICDS సోపానక్రమం' : 'ICDS Hierarchy',
              description: isTelugu
                  ? 'రాష్ట్రం → జిల్లా → ప్రాజెక్ట్ → సెక్టార్ → AWC. ప్రతి స్థాయి డ్రిల్-డౌన్ ఉంటుంది.'
                  : 'State → District → Project → Sector → AWC. Every level has drill-down dashboards.',
              items: isTelugu
                  ? ['7 పాత్రలు, స్కోప్-ఆధారిత', 'RLS భద్రత', 'డైనమిక్ సబ్-యూనిట్ కార్డులు']
                  : ['7 roles, scope-based access', 'Row-Level Security (RLS)', 'Dynamic sub-unit cards'],
            ),
            _PillarCard(
              icon: Icons.extension,
              title: isTelugu ? 'ప్లగ్-ఇన్ స్క్రీనింగ్ టూల్స్' : 'Plug-in Screening Tools',
              description: isTelugu
                  ? '14 స్క్రీనింగ్ సాధనాలు ప్లగ్-ఇన్ ఆర్కిటెక్చర్‌తో. కొత్త సాధనం జోడించడానికి 3 ఫైళ్ళు మాత్రమే.'
                  : '14 screening tools with plug-in architecture. Adding a new tool requires only 3 files.',
              items: isTelugu
                  ? ['ఎనమ్ → కాన్ఫిగ్ → స్కోరర్', 'వయసు-ఫిల్టర్డ్ ఆటో', 'కాన్ఫిగరబుల్ థ్రెషోల్డ్‌లు']
                  : ['Enum → Config → Scorer', 'Age-filtered auto-display', 'Configurable thresholds'],
            ),
            _PillarCard(
              icon: Icons.translate,
              title: isTelugu ? 'బహుభాష మద్దతు' : 'Multi-Language Support',
              description: isTelugu
                  ? 'ఇంగ్లీష్ + తెలుగు ఇన్‌లైన్ ద్విభాషా. 22 భారతీయ భాషలకు విస్తరించగలదు.'
                  : 'English + Telugu inline bilingual. Extensible to 22 Indian languages.',
              items: isTelugu
                  ? ['ఇన్‌లైన్ _te ఫీల్డ్‌లు', 'రన్‌టైమ్ టాగుల్', 'లిప్యంతరీకరణ యుటిలిటీ']
                  : ['Inline _te fields', 'Runtime toggle', 'Transliteration utility'],
            ),
            _PillarCard(
              icon: Icons.speed,
              title: isTelugu ? 'పనితీరు ఆప్టిమైజేషన్' : 'Performance Optimization',
              description: isTelugu
                  ? 'లేజీ లోడింగ్, సెలెక్టివ్ సింక్, బ్యాక్‌గ్రౌండ్ ప్రాసెసింగ్.'
                  : 'Lazy loading, selective sync, background processing.',
              items: isTelugu
                  ? ['పేజినేటెడ్ లిస్ట్‌లు (50/పేజీ)', 'అధికార పరిధి సింక్ మాత్రమే', 'బ్యాక్‌గ్రౌండ్ ఐసొలేట్ సింక్']
                  : ['Paginated lists (50/page)', 'Jurisdiction-scoped sync only', 'Background isolate sync'],
            ),
            const SizedBox(height: 24),

            // Current Stats
            Text(
              isTelugu ? 'ప్రస్తుత సామర్థ్యాలు' : 'Current Capabilities',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatChip(value: '14', label: isTelugu ? 'స్క్రీనింగ్ సాధనాలు' : 'Screening Tools'),
                _StatChip(value: '7', label: isTelugu ? 'పాత్రలు' : 'Roles'),
                _StatChip(value: '2', label: isTelugu ? 'భాషలు' : 'Languages'),
                _StatChip(value: '5', label: isTelugu ? 'ICDS స్థాయిలు' : 'ICDS Levels'),
                _StatChip(value: '30', label: isTelugu ? 'కార్యకలాపాలు' : 'Activities'),
                _StatChip(value: '100%', label: isTelugu ? 'ఆఫ్‌లైన్' : 'Offline'),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final String phase;
  final String title;
  final String stats;
  final Color color;
  final bool isActive;

  const _PhaseCard({
    required this.phase,
    required this.title,
    required this.stats,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(phase, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (isActive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('ACTIVE', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Text(stats, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ])),
        ]),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> items;

  const _PillarCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              const Icon(Icons.check_circle, size: 16, color: AppColors.riskLow),
              const SizedBox(width: 8),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}
