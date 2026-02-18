import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_config_provider.dart';

/// A visually impressive questionnaire preview that renders questions inside a
/// simulated phone-frame mockup.  Designed as the "wow" factor for hackathon
/// demos -- animated transitions, gradient headers, progress rings, and a
/// language toggle for English/Telugu.
class QuestionnairePreviewScreen extends ConsumerStatefulWidget {
  final int toolId;

  const QuestionnairePreviewScreen({super.key, required this.toolId});

  @override
  ConsumerState<QuestionnairePreviewScreen> createState() =>
      _QuestionnairePreviewScreenState();
}

class _QuestionnairePreviewScreenState
    extends ConsumerState<QuestionnairePreviewScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isTelugu = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _primary = Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _goTo(int index, int total) {
    if (index < 0 || index >= total) return;
    _slideController.reset();
    setState(() => _currentIndex = index);
    _slideController.forward();
  }

  Color _resolveColor(Map<String, dynamic> tool) {
    final hex = tool['color_hex'] as String?;
    if (hex != null && hex.isNotEmpty) {
      try {
        final cleaned = hex.replaceFirst('#', '');
        return Color(int.parse('FF$cleaned', radix: 16));
      } catch (_) {}
    }
    return _primary;
  }

  IconData _resolveIcon(Map<String, dynamic> tool) {
    final name = (tool['name'] as String? ?? '').toUpperCase();
    if (name.contains('CDC')) return Icons.child_care;
    if (name.contains('RBSK')) return Icons.medical_services_outlined;
    if (name.contains('MCHAT')) return Icons.psychology_outlined;
    if (name.contains('ISAA')) return Icons.accessibility_new;
    if (name.contains('ADHD')) return Icons.flash_on;
    if (name.contains('SDQ')) return Icons.emoji_emotions_outlined;
    if (name.contains('PCI') || name.contains('PARENT-CHILD')) {
      return Icons.family_restroom;
    }
    if (name.contains('PHQ') || name.contains('MENTAL')) {
      return Icons.self_improvement;
    }
    if (name.contains('HOME')) return Icons.home_outlined;
    if (name.contains('NUT')) return Icons.restaurant_outlined;
    return Icons.quiz_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(adminToolDetailProvider(widget.toolId));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          'Questionnaire Preview',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text('Failed to load: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(adminToolDetailProvider(widget.toolId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tool) => _buildPreview(tool),
      ),
    );
  }

  Widget _buildPreview(Map<String, dynamic> tool) {
    final toolName = tool['name'] as String? ?? 'Tool';
    final toolNameTe = tool['name_te'] as String? ?? toolName;
    final questions = (tool['screening_questions'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final toolColor = _resolveColor(tool);
    final toolIcon = _resolveIcon(tool);

    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No questions to preview'),
          ],
        ),
      );
    }

    // Clamp index
    if (_currentIndex >= questions.length) _currentIndex = 0;
    final q = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            // Language toggle
            _buildLanguageToggle(toolColor),
            const SizedBox(height: 20),

            // ── Phone frame ──────────────────────────────────────────────
            Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 720),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: toolColor.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Phone notch bar
                        Container(
                          height: 30,
                          color: toolColor,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),

                        // Tool header
                        _buildToolHeader(
                          toolName,
                          toolNameTe,
                          toolIcon,
                          toolColor,
                          progress,
                          questions.length,
                        ),

                        // Question content
                        Flexible(
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _slideController,
                              child: _buildQuestionContent(
                                q,
                                toolColor,
                              ),
                            ),
                          ),
                        ),

                        // Navigation bar
                        _buildNavBar(toolColor, questions.length),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Question counter label
            Text(
              'Question ${_currentIndex + 1} of ${questions.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Language toggle ──────────────────────────────────────────────────

  Widget _buildLanguageToggle(Color toolColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: 'English',
            isActive: !_isTelugu,
            color: toolColor,
            onTap: () => setState(() => _isTelugu = false),
          ),
          _ToggleButton(
            label: 'Telugu',
            isActive: _isTelugu,
            color: toolColor,
            onTap: () => setState(() => _isTelugu = true),
          ),
        ],
      ),
    );
  }

  // ── Tool header inside phone ─────────────────────────────────────────

  Widget _buildToolHeader(
    String name,
    String nameTe,
    IconData icon,
    Color toolColor,
    double progress,
    int totalQuestions,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            toolColor,
            toolColor.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Animated icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isTelugu ? nameTe : name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_currentIndex + 1} / $totalQuestions questions',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular progress
              _buildProgressRing(progress, toolColor),
            ],
          ),
          const SizedBox(height: 14),
          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(double progress, Color color) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Question content ─────────────────────────────────────────────────

  Widget _buildQuestionContent(
    Map<String, dynamic> q,
    Color toolColor,
  ) {
    final responseOptions = (q['response_options'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final domain = q['domain'] as String? ?? '';
    final domainNameEn = q['domain_name_en'] as String? ?? domain;
    final domainNameTe = q['domain_name_te'] as String? ?? domainNameEn;
    final textEn = q['text_en'] as String? ?? '';
    final textTe = q['text_te'] as String? ?? textEn;
    final ageMonths = q['age_months'] as int?;
    final isCritical = q['is_critical'] as bool? ?? false;
    final isRedFlag = q['is_red_flag'] as bool? ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Domain badge
          if (domain.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: toolColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: toolColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: toolColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isTelugu ? domainNameTe : domainNameEn,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: toolColor,
                    ),
                  ),
                ],
              ),
            ),

          // Age badge
          if (ageMonths != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isTelugu ? '$ageMonths months' : '$ageMonths months',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Question text
          Text(
            _isTelugu ? textTe : textEn,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              height: 1.5,
              letterSpacing: -0.2,
            ),
          ),

          // Flags
          if (isCritical || isRedFlag) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (isCritical)
                  _FlagChip(
                    icon: Icons.warning_amber,
                    label: 'Critical',
                    color: Colors.orange,
                  ),
                if (isRedFlag)
                  _FlagChip(
                    icon: Icons.flag,
                    label: 'Red Flag',
                    color: Colors.red,
                  ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          // Response option chips (visual only)
          if (responseOptions.isNotEmpty)
            ...responseOptions.map((opt) {
              final labelEn = opt['label_en'] as String? ?? '';
              final labelTe = opt['label_te'] as String? ?? labelEn;
              final colorHex = opt['color_hex'] as String? ?? '';
              Color? chipColor;
              if (colorHex.isNotEmpty) {
                try {
                  final cleaned = colorHex.replaceFirst('#', '');
                  chipColor = Color(int.parse('FF$cleaned', radix: 16));
                } catch (_) {}
              }
              chipColor ??= toolColor;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: chipColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    _isTelugu ? labelTe : labelEn,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: chipColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            })
          else
            // Fallback: Yes/No buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _isTelugu ? 'Yes' : 'Yes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      _isTelugu ? 'No' : 'No',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Bottom nav bar inside phone ──────────────────────────────────────

  Widget _buildNavBar(Color toolColor, int total) {
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == total - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous
          Expanded(
            child: AnimatedOpacity(
              opacity: isFirst ? 0.4 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: OutlinedButton.icon(
                onPressed:
                    isFirst ? null : () => _goTo(_currentIndex - 1, total),
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                label: const Text('Prev'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Page indicator dots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                math.min(total, 7),
                (i) {
                  // For many questions, show a subset of dots centered on current
                  int dotIndex = i;
                  if (total > 7) {
                    final offset = (_currentIndex - 3)
                        .clamp(0, total - 7);
                    dotIndex = offset + i;
                  }
                  final isActive = dotIndex == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? toolColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ),
          ),

          // Next
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  isLast ? null : () => _goTo(_currentIndex + 1, total),
              icon: Text(
                isLast ? 'Done' : 'Next',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              label: Icon(
                isLast ? Icons.check : Icons.arrow_forward_ios,
                size: 14,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast
                    ? const Color(0xFF4CAF50)
                    : toolColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Language toggle button
// ═══════════════════════════════════════════════════════════════════════════

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Flag chip widget
// ═══════════════════════════════════════════════════════════════════════════

class _FlagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FlagChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
