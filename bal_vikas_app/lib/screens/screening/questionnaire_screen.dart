import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/screening_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import 'measurement_screen.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic> child;

  const QuestionnaireScreen({
    super.key,
    required this.session,
    required this.child,
  });

  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  int _currentDomainIndex = 0;
  int _currentQuestionIndex = 0;
  final Map<String, bool> _responses = {};
  bool _showEnvironmentQuestions = false;
  int _currentEnvironmentQuestionIndex = 0;
  bool _allQuestionsCompleted = false;

  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(questionnaireProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return questionnaireAsync.when(
      data: (questionnaire) {
        if (questionnaire == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Questionnaire')),
            body: const Center(child: Text('Failed to load questionnaire')),
          );
        }

        // Check if all questions completed first
        if (_allQuestionsCompleted) {
          return _buildCompletionScreen(isTelugu);
        }
        
        // Check if we should show environment questions
        if (_showEnvironmentQuestions) {
          return _buildEnvironmentQuestionScreen(isTelugu);
        }

        final domains = questionnaire['questionnaire_data']['domains'] as List;
        final currentDomain = domains[_currentDomainIndex];
        final questions = currentDomain['milestones'] as List;

        // Filter questions by age - only current bracket + previous bracket
        final ageMonths = _getChildAgeMonths();
        final ageAppropriateQuestions = _getAgeAppropriateQuestions(questions, ageMonths);

        if (ageAppropriateQuestions.isEmpty ||
            _currentQuestionIndex >= ageAppropriateQuestions.length) {
          // Move to next domain or show environment questions
          if (_currentDomainIndex < domains.length - 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentDomainIndex++;
                _currentQuestionIndex = 0;
              });
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (!_showEnvironmentQuestions) {
            // All CDC domains completed, now show environment questions
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _showEnvironmentQuestions = true;
                _currentEnvironmentQuestionIndex = 0;
              });
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }

        final currentQ = ageAppropriateQuestions[_currentQuestionIndex];
        final totalQuestions = ageAppropriateQuestions.length;
        final progress = (_currentQuestionIndex + 1) / totalQuestions;

        return Scaffold(
          appBar: AppBar(
            title: Text(isTelugu
                ? currentDomain['name_te'] ?? currentDomain['name']
                : currentDomain['name']),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress
                LinearProgressIndicator(
                  value: (_currentDomainIndex + progress) / domains.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isTelugu ? 'డొమైన్' : 'Domain'} ${_currentDomainIndex + 1} ${isTelugu ? 'ఆఫ్' : 'of'} ${domains.length} • ${isTelugu ? 'ప్రశ్న' : 'Question'} ${_currentQuestionIndex + 1} ${isTelugu ? 'ఆఫ్' : 'of'} $totalQuestions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),

                // Domain Badge
                Chip(
                  label: Text(
                    isTelugu
                        ? currentDomain['name_te'] ?? currentDomain['name']
                        : currentDomain['name'],
                  ),
                  backgroundColor: _getDomainColor(currentDomain['code']),
                ),
                const SizedBox(height: 24),

                // Question
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTelugu
                                ? currentQ['question_te'] ?? currentQ['question']
                                : currentQ['question'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${isTelugu ? 'వయస్సు' : 'Age'}: ${currentQ['age']} ${isTelugu ? 'నెలలు' : 'months'}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _answer(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade100,
                                    foregroundColor: Colors.green.shade800,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  icon: const Icon(Icons.check_circle, size: 32),
                                  label: Text(
                                    isTelugu ? 'అవును' : 'Yes',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _answer(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade100,
                                    foregroundColor: Colors.red.shade800,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  icon: const Icon(Icons.cancel, size: 32),
                                  label: Text(
                                    isTelugu ? 'కాదు' : 'No',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  /// Calculate child's current age in months from date_of_birth, with fallback to age_months field
  int _getChildAgeMonths() {
    // Prefer calculating from date_of_birth for accuracy
    final dob = widget.child['date_of_birth'];
    if (dob != null && dob is String && dob.isNotEmpty) {
      try {
        final dobDate = DateTime.parse(dob);
        final now = DateTime.now();
        int months = (now.year - dobDate.year) * 12 + (now.month - dobDate.month);
        if (now.day < dobDate.day) months--;
        return months < 0 ? 0 : months;
      } catch (_) {}
    }
    // Fallback to the age_months field
    return widget.child['age_months'] as int? ?? 24;
  }

  /// CDC standard age brackets in months
  static const List<int> _cdcAgeBrackets = [2, 4, 6, 9, 12, 18, 24, 30, 36, 48, 60];

  /// Returns milestones for two age brackets closest to the child's age.
  /// - If age matches a bracket exactly (e.g., 48m): show previous + current (36m + 48m)
  /// - If age is between brackets (e.g., 42m): show lower + upper (36m + 48m)
  List<Map<String, dynamic>> _getAgeAppropriateQuestions(List milestones, int childAgeMonths) {
    int lowerBracket = _cdcAgeBrackets.first;
    int upperBracket = _cdcAgeBrackets.last;

    // Find the two brackets that surround the child's age
    for (int i = 0; i < _cdcAgeBrackets.length; i++) {
      if (_cdcAgeBrackets[i] == childAgeMonths) {
        // Exact match: use previous bracket + this bracket
        upperBracket = _cdcAgeBrackets[i];
        lowerBracket = i > 0 ? _cdcAgeBrackets[i - 1] : upperBracket;
        break;
      } else if (_cdcAgeBrackets[i] > childAgeMonths) {
        // Age is between brackets: use the bracket below + bracket above
        upperBracket = _cdcAgeBrackets[i];
        lowerBracket = i > 0 ? _cdcAgeBrackets[i - 1] : upperBracket;
        break;
      }
    }

    // Filter milestones to only these two brackets
    return milestones
        .where((q) {
          final age = q['age'] as int;
          return age == lowerBracket || age == upperBracket;
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Color _getDomainColor(String code) {
    switch (code) {
      case 'gm':
        return Colors.blue.shade100;
      case 'fm':
        return Colors.green.shade100;
      case 'lc':
        return Colors.orange.shade100;
      case 'cog':
        return Colors.purple.shade100;
      case 'se':
        return Colors.pink.shade100;
      case 'ec':
        return const Color(0xFFB2DFDB);
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _buildEnvironmentQuestionScreen(bool isTelugu) {
    final envQuestions = ref.watch(environmentQuestionsProvider);
    final currentQ = envQuestions[_currentEnvironmentQuestionIndex];
    final totalQuestions = envQuestions.length;
    final progress = (_currentEnvironmentQuestionIndex + 1) / totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'పర్యావరణం & శుశ్రూష' : 'Environment & Caregiving'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
            const SizedBox(height: 8),
            Text(
              '${isTelugu ? 'ప్రశ్న' : 'Question'} ${_currentEnvironmentQuestionIndex + 1} ${isTelugu ? 'ఆఫ్' : 'of'} $totalQuestions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            // Category Badge
            Chip(
              label: Text(
                isTelugu
                    ? currentQ['category_te'] ?? currentQ['category']
                    : currentQ['category'],
              ),
              backgroundColor: _getDomainColor('ec'),
            ),
            const SizedBox(height: 24),

            // Question
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu
                            ? currentQ['question_te'] ?? currentQ['question']
                            : currentQ['question'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.home, color: const Color(0xFF00796B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isTelugu
                                    ? 'ఈ ప్రశ్న బిడ్డ యొక్క ఇంటి పరిసరాలు మరియు శుశ్రూష గురించి'
                                    : 'This question is about the child\'s home environment and caregiving',
                                style: TextStyle(
                                  color: const Color(0xFF00796B),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _answerEnvironment(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade100,
                                foregroundColor: Colors.green.shade800,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                              ),
                              icon: const Icon(Icons.check_circle, size: 32),
                              label: Text(
                                isTelugu ? 'అవును' : 'Yes',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _answerEnvironment(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                foregroundColor: Colors.red.shade800,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                              ),
                              icon: const Icon(Icons.cancel, size: 32),
                              label: Text(
                                isTelugu ? 'కాదు' : 'No',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _answer(bool value) {
    final questionnaireAsync = ref.read(questionnaireProvider);
    questionnaireAsync.whenData((questionnaire) {
      if (questionnaire == null) return;

      final domains = questionnaire['questionnaire_data']['domains'] as List;
      final currentDomain = domains[_currentDomainIndex];
      final questions = currentDomain['milestones'] as List;
      final ageMonths = _getChildAgeMonths();
      final ageAppropriateQuestions = _getAgeAppropriateQuestions(questions, ageMonths);

      final currentQ = ageAppropriateQuestions[_currentQuestionIndex];
      _responses[currentQ['id']] = value;

      // Save response to provider first
      ref.read(screeningResponsesProvider.notifier).update({
        ...ref.read(screeningResponsesProvider),
        currentQ['id']: value,
      });

      // Check if this is the last question of the last domain
      final isLastQuestion = _currentQuestionIndex >= ageAppropriateQuestions.length - 1;
      final isLastDomain = _currentDomainIndex >= domains.length - 1;

      if (isLastQuestion && isLastDomain) {
        // All CDC questions completed - move to environment questions
        setState(() {
          _currentQuestionIndex++; // Move past last question to trigger the completion condition
        });
        return;
      }

      setState(() {
        if (_currentQuestionIndex < ageAppropriateQuestions.length - 1) {
          _currentQuestionIndex++;
        } else {
          // Move to next domain
          if (_currentDomainIndex < domains.length - 1) {
            _currentDomainIndex++;
            _currentQuestionIndex = 0;
          }
        }
      });
    });
  }

  void _answerEnvironment(bool value) {
    final envQuestions = ref.read(environmentQuestionsProvider);
    final currentQ = envQuestions[_currentEnvironmentQuestionIndex];
    _responses[currentQ['id']] = value;

    // Save response to provider
    ref.read(screeningResponsesProvider.notifier).update({
      ...ref.read(screeningResponsesProvider),
      currentQ['id']: value,
    });

    if (_currentEnvironmentQuestionIndex >= envQuestions.length - 1) {
      // All environment questions completed - navigate to results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MeasurementScreen(
            session: widget.session,
            child: widget.child,
            responses: _responses,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentEnvironmentQuestionIndex++;
    });
  }

  Widget _buildCompletionScreen(bool isTelugu) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'తనిఖీ పూర్తయింది' : 'Screening Complete'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: AppColors.riskLow,
            ),
            const SizedBox(height: 24),
            Text(
              isTelugu
                  ? 'ప్రశ్నావళి పూర్తయింది!'
                  : 'Questionnaire Completed!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isTelugu
                  ? 'ఫలితాలను చూడటానికి కొనసాగండి'
                  : 'Continue to see results',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeasurementScreen(
                      session: widget.session,
                      child: widget.child,
                      responses: _responses,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isTelugu ? 'కొనసాగండి' : 'Continue',
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
