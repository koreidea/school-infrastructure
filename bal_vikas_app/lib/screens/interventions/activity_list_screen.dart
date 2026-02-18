import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/intervention_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../services/tts_service.dart';
import '../../services/activity_pdf_service.dart';

/// Activity list screen showing recommended activities for a child
class ActivityListScreen extends ConsumerStatefulWidget {
  final int? childId;
  final Map<String, dynamic>? child;

  const ActivityListScreen({
    super.key,
    this.childId,
    this.child,
  });

  @override
  ConsumerState<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends ConsumerState<ActivityListScreen> {
  int? _selectedChildId;
  Map<String, dynamic>? _selectedChild;
  String _selectedDomainFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.childId;
    _selectedChild = widget.child;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final childrenAsync = ref.watch(childrenProvider);

    // If no child selected, show child selection
    if (_selectedChild == null && _selectedChildId == null) {
      return _buildChildSelectionScreen(childrenAsync, isTelugu);
    }

    // Get child details if we have ID but not full child data
    final childDetailAsync = _selectedChildId != null && _selectedChild == null
        ? ref.watch(childDetailProvider(_selectedChildId!))
        : null;

    if (childDetailAsync != null) {
      return childDetailAsync.when(
        data: (child) {
          if (child != null) {
            _selectedChild = child;
          }
          return _buildActivitiesScreen(isTelugu);
        },
        loading: () => Scaffold(
          appBar: AppBar(
            title: Text(isTelugu ? 'కార్యకలాపాలు' : 'Activities'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => _buildActivitiesScreen(isTelugu),
      );
    }

    return _buildActivitiesScreen(isTelugu);
  }

  /// Build child selection screen
  Widget _buildChildSelectionScreen(AsyncValue<List<Map<String, dynamic>>> childrenAsync, bool isTelugu) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'కార్యకలాపాలు' : 'Activities'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: childrenAsync.when(
        data: (children) {
          if (children.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.child_care,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isTelugu ? 'పిల్లలు కనుగొనబడలేదు' : 'No children found',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTelugu 
                      ? 'కార్యకలాపాల కోసం ఒక బిడ్డను ఎంచుకోండి' 
                      : 'Select a child to view activities',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...children.map((child) => _ChildSelectionCard(
                  child: child,
                  isTelugu: isTelugu,
                  onTap: () {
                    setState(() {
                      _selectedChildId = child['child_id'] as int;
                      _selectedChild = child;
                    });
                  },
                )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(isTelugu ? 'లోడ్ చేయడంలో లోపం' : 'Error loading children'),
        ),
      ),
    );
  }

  /// Build activities screen for selected child
  Widget _buildActivitiesScreen(bool isTelugu) {
    final child = _selectedChild;
    if (child == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isTelugu ? 'కార్యకలాపాలు' : 'Activities'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.riskHigh),
              const SizedBox(height: 16),
              Text(isTelugu ? 'బిడ్డ వివరాలు లోడ్ చేయలేదు' : 'Could not load child details'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {
                  _selectedChild = null;
                  _selectedChildId = null;
                }),
                child: Text(isTelugu ? 'వెనుకకు' : 'Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    final childId = child['child_id'] as int;
    final childAge = child['age_months'] as int;

    // Get recommended activities (uses local screening results if available)
    final activitiesAsync = ref.watch(recommendedActivitiesProvider((childId, childAge, null)));

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'కార్యకలాపాలు' : 'Activities'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Change child button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedChild = null;
                _selectedChildId = null;
              });
            },
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            label: Text(
              isTelugu ? 'మార్చు' : 'Change',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) {
          // Filter by domain if selected
          final filteredActivities = _selectedDomainFilter == 'all'
              ? activities
              : activities.where((a) => a['domain'] == _selectedDomainFilter).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child info card
                _ChildInfoCard(
                  child: child,
                  isTelugu: isTelugu,
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isTelugu 
                            ? 'సిఫార్సు చేయబడిన కార్యకలాపాలు' 
                            : 'Recommended Activities',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Activity count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredActivities.length}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Domain filter chips
                _buildDomainFilterChips(isTelugu),
                const SizedBox(height: 16),

                // Activities list
                if (filteredActivities.isEmpty)
                  _buildEmptyState(isTelugu)
                else
                  ...filteredActivities.map((activity) => _ActivityCard(
                    activity: activity,
                    isTelugu: isTelugu,
                    onTap: () => _showActivityDetails(activity, isTelugu),
                  )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.riskHigh),
              const SizedBox(height: 16),
              Text(
                isTelugu ? 'లోడ్ చేయడంలో లోపం' : 'Error loading activities',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build domain filter chips
  Widget _buildDomainFilterChips(bool isTelugu) {
    final domains = [
      {'code': 'all', 'name': isTelugu ? 'అన్నీ' : 'All', 'name_te': 'అన్నీ'},
      {'code': DomainCodes.gm, 'name': 'Gross Motor', 'name_te': 'స్థూల చలనం'},
      {'code': DomainCodes.fm, 'name': 'Fine Motor', 'name_te': 'సూక్ష్మ చలనం'},
      {'code': DomainCodes.lc, 'name': 'Language', 'name_te': 'భాష'},
      {'code': DomainCodes.cog, 'name': 'Cognitive', 'name_te': 'జ్ఞానాత్మకం'},
      {'code': DomainCodes.se, 'name': 'Social', 'name_te': 'సామాజిక'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: domains.map((domain) {
          final isSelected = _selectedDomainFilter == domain['code'];
          final label = isTelugu ? domain['name_te'] : domain['name'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDomainFilter = domain['code']!;
                  });
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.text,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(bool isTelugu) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isTelugu ? 'కార్యకలాపాలు కనుగొనబడలేదు' : 'No activities found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTelugu 
                ? 'దయచేసి వేరే ఫిల్టర్ ఎంచుకోండి' 
                : 'Please try a different filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Show activity details bottom sheet
  void _showActivityDetails(Map<String, dynamic> activity, bool isTelugu) {
    showActivityDetailSheet(context, activity, isTelugu, child: _selectedChild);
  }
}

/// Child selection card
class _ChildSelectionCard extends StatelessWidget {
  final Map<String, dynamic> child;
  final bool isTelugu;
  final VoidCallback onTap;

  const _ChildSelectionCard({
    required this.child,
    required this.isTelugu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = child['name'] as String;
    final age = child['age_months'] as int;
    final ageText = _getAgeText(age, isTelugu);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.child_care,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ageText,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAgeText(int months, bool isTelugu) {
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    
    if (isTelugu) {
      if (years > 0 && remainingMonths > 0) {
        return '$years సంవత్సరాలు $remainingMonths నెలలు';
      } else if (years > 0) {
        return '$years సంవత్సరాలు';
      } else {
        return '$months నెలలు';
      }
    } else {
      if (years > 0 && remainingMonths > 0) {
        return '$years years $remainingMonths months';
      } else if (years > 0) {
        return '$years years';
      } else {
        return '$months months';
      }
    }
  }
}

/// Child info card showing selected child details
class _ChildInfoCard extends StatelessWidget {
  final Map<String, dynamic> child;
  final bool isTelugu;

  const _ChildInfoCard({
    required this.child,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context) {
    final name = child['name'] as String;
    final age = child['age_months'] as int;
    final ageText = _getAgeText(age, isTelugu);

    return Card(
      color: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.child_care,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ageText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isTelugu ? 'ఎంచుకున్నారు' : 'Selected',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAgeText(int months, bool isTelugu) {
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    
    if (isTelugu) {
      if (years > 0 && remainingMonths > 0) {
        return '$years సంవత్సరాలు $remainingMonths నెలలు';
      } else if (years > 0) {
        return '$years సంవత్సరాలు';
      } else {
        return '$months నెలలు';
      }
    } else {
      if (years > 0 && remainingMonths > 0) {
        return '$years years $remainingMonths months';
      } else if (years > 0) {
        return '$years years';
      } else {
        return '$months months';
      }
    }
  }
}

/// Activity card widget
class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final bool isTelugu;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.activity,
    required this.isTelugu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isTelugu 
        ? activity['activity_title_te'] ?? activity['activity_title']
        : activity['activity_title'];
    final domain = activity['domain'] as String;
    final duration = activity['duration_minutes'] as int;
    final hasVideo = activity['has_video'] as bool? ?? false;
    final riskLevel = activity['risk_level'] as String? ?? 'LOW';

    final domainColor = _getDomainColor(domain);
    final domainName = _getDomainName(domain, isTelugu);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/activities/${activity['activity_code'] ?? ''}.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: domainColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getDomainIcon(domain),
                          color: domainColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and domain
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: domainColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                domainName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: domainColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (riskLevel == 'HIGH') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.riskHigh.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isTelugu ? 'అధిక ప్రాధాన్యత' : 'High Priority',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.riskHigh,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Video indicator
                  if (hasVideo)
                    const Icon(
                      Icons.play_circle_outline,
                      color: AppColors.primary,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Duration
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$duration ${isTelugu ? 'నిమిషాలు' : 'min'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isTelugu ? 'ఇంకా చదవండి →' : 'Read more →',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case DomainCodes.gm:
        return Colors.blue;
      case DomainCodes.fm:
        return Colors.green;
      case DomainCodes.lc:
        return Colors.orange;
      case DomainCodes.cog:
        return Colors.purple;
      case DomainCodes.se:
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }

  IconData _getDomainIcon(String domain) {
    switch (domain) {
      case DomainCodes.gm:
        return Icons.directions_run;
      case DomainCodes.fm:
        return Icons.back_hand;
      case DomainCodes.lc:
        return Icons.record_voice_over;
      case DomainCodes.cog:
        return Icons.psychology;
      case DomainCodes.se:
        return Icons.people;
      default:
        return Icons.fitness_center;
    }
  }

  String _getDomainName(String domain, bool isTelugu) {
    final names = domainNames[domain];
    if (names == null) return domain.toUpperCase();
    return isTelugu ? (names['te'] ?? names['en']!) : names['en']!;
  }
}

/// Show activity detail bottom sheet - callable from anywhere
void showActivityDetailSheet(BuildContext context, Map<String, dynamic> activity, bool isTelugu, {Map<String, dynamic>? child}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => ActivityDetailSheet(
        activity: activity,
        isTelugu: isTelugu,
        scrollController: scrollController,
        child: child,
      ),
    ),
  );
}

/// Activity detail bottom sheet
class ActivityDetailSheet extends StatefulWidget {
  final Map<String, dynamic> activity;
  final bool isTelugu;
  final ScrollController scrollController;
  final Map<String, dynamic>? child;

  const ActivityDetailSheet({
    super.key,
    required this.activity,
    required this.isTelugu,
    required this.scrollController,
    this.child,
  });

  @override
  State<ActivityDetailSheet> createState() => _ActivityDetailSheetState();
}

class _ActivityDetailSheetState extends State<ActivityDetailSheet> {
  bool _isSpeaking = false;

  Map<String, String>? get _guidance =>
      getActivityGuidance(widget.activity['activity_code'] as String? ?? '');

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  void _toggleTTS() {
    if (_isSpeaking) {
      TtsService.instance.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    final activityCode = widget.activity['activity_code'] as String? ?? '';
    final title = widget.isTelugu
        ? widget.activity['activity_title_te'] ?? widget.activity['activity_title']
        : widget.activity['activity_title'];
    final description = widget.isTelugu
        ? widget.activity['activity_description_te'] ?? widget.activity['activity_description']
        : widget.activity['activity_description'];

    String? steps;
    String? tips;
    if (_guidance != null) {
      steps = widget.isTelugu ? (_guidance!['steps_te'] ?? _guidance!['steps']) : _guidance!['steps'];
      tips = widget.isTelugu ? (_guidance!['tips_te'] ?? _guidance!['tips']) : _guidance!['tips'];
    }

    // Compose fallback text for device TTS (used when MP3 not available)
    final fallbackText = TtsService.composeActivityText(
      title: title,
      description: description,
      steps: steps,
      tips: tips,
      isTelugu: widget.isTelugu,
    );

    // Plays pre-recorded MP3 if available, falls back to device TTS
    TtsService.instance.speakActivity(
      activityCode: activityCode,
      language: widget.isTelugu ? 'te' : 'en',
      fallbackText: fallbackText,
      onStateChange: (speaking) {
        if (mounted) setState(() => _isSpeaking = speaking);
      },
    );
  }

  Widget _buildActivityImage(String domain, Color domainColor) {
    final activityCode = widget.activity['activity_code'] as String? ?? '';
    final imagePath = 'assets/images/activities/$activityCode.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 160,
          decoration: BoxDecoration(
            color: domainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              getDomainIcon(domain),
              size: 64,
              color: domainColor.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  void _showPrintShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print),
              title: Text(widget.isTelugu ? 'ప్రింట్ చేయండి' : 'Print'),
              onTap: () {
                Navigator.pop(ctx);
                ActivityPdfService.printActivitySheet(
                  activity: widget.activity,
                  child: widget.child,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(widget.isTelugu ? 'షేర్ చేయండి (PDF)' : 'Share as PDF'),
              onTap: () {
                Navigator.pop(ctx);
                ActivityPdfService.shareActivitySheet(
                  activity: widget.activity,
                  child: widget.child,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isTelugu
        ? widget.activity['activity_title_te'] ?? widget.activity['activity_title']
        : widget.activity['activity_title'];
    final description = widget.isTelugu
        ? widget.activity['activity_description_te'] ?? widget.activity['activity_description']
        : widget.activity['activity_description'];
    final materials = widget.isTelugu
        ? widget.activity['materials_needed_te'] ?? widget.activity['materials_needed']
        : widget.activity['materials_needed'];
    final domain = widget.activity['domain'] as String;
    final duration = widget.activity['duration_minutes'] as int;

    final domainColor = getDomainColor(domain);
    final domainName = getDomainDisplayName(domain, widget.isTelugu);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Domain badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: domainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getDomainIcon(domain),
                            size: 16,
                            color: domainColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            domainName,
                            style: TextStyle(
                              color: domainColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$duration ${widget.isTelugu ? 'నిమిషాలు' : 'min'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Action buttons: Listen + Print
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleTTS,
                        icon: Icon(
                          _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                          size: 20,
                        ),
                        label: Text(
                          widget.isTelugu
                              ? (_isSpeaking ? 'ఆపండి' : 'వినండి')
                              : (_isSpeaking ? 'Stop' : 'Listen'),
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSpeaking ? Colors.red.shade400 : domainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showPrintShareOptions,
                        icon: const Icon(Icons.print, size: 20),
                        label: Text(
                          widget.isTelugu ? 'ప్రింట్ / షేర్' : 'Print / Share',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: domainColor,
                          side: BorderSide(color: domainColor),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Activity image
                _buildActivityImage(domain, domainColor),
                const SizedBox(height: 24),

                // Description section
                Text(
                  widget.isTelugu ? 'వివరణ' : 'Description',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Materials section
                if (materials != null && materials.toString().isNotEmpty) ...[
                  Text(
                    widget.isTelugu ? 'అవసరమైన సామాగ్రి' : 'Materials Needed',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            materials,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Step-by-step instructions (from guidance map)
                if (_guidance != null && _guidance!['steps'] != null) ...[
                  Text(
                    widget.isTelugu ? 'దశల వారీ సూచనలు' : 'Step-by-Step Instructions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      widget.isTelugu
                          ? (_guidance!['steps_te'] ?? _guidance!['steps']!)
                          : _guidance!['steps']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Tips section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isTelugu ? 'చిట్కాలు' : 'Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _guidance != null && _guidance!['tips'] != null
                            ? (widget.isTelugu
                                ? (_guidance!['tips_te'] ?? _guidance!['tips']!)
                                : _guidance!['tips']!)
                            : (widget.isTelugu
                                ? 'ఈ కార్యకలాపాన్ని రోజువారీగా చేయండి. మీ బిడ్డ ఆసక్తిని కోల్పోతే విరామం తీసుకోండి. ప్రశంసలు మరియు ప్రోత్సాహాన్ని అందించండి.'
                                : 'Do this activity daily. Take breaks if your child loses interest. Provide praise and encouragement.'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber.shade900,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mark as done button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isTelugu ? 'గుర్తించబడింది!' : 'Marked as done!',
                          ),
                          backgroundColor: AppColors.riskLow,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      widget.isTelugu ? 'పూర్తయిందిగా గుర్తించు' : 'Mark as Done',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
