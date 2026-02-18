import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/screening_tool.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../widgets/response_widgets.dart';

class ToolQuestionnaireScreen extends ConsumerStatefulWidget {
  final ScreeningToolConfig toolConfig;
  final int childAgeMonths;
  final void Function(Map<String, dynamic> responses) onComplete;

  const ToolQuestionnaireScreen({
    super.key,
    required this.toolConfig,
    required this.childAgeMonths,
    required this.onComplete,
  });

  @override
  ConsumerState<ToolQuestionnaireScreen> createState() => _ToolQuestionnaireScreenState();
}

class _ToolQuestionnaireScreenState extends ConsumerState<ToolQuestionnaireScreen> {
  int _currentIndex = 0;
  final Map<String, dynamic> _responses = {};
  final Map<String, TextEditingController> _numericControllers = {};
  late List<ScreeningQuestion> _questions;

  static const _cdcAgeBrackets = [2, 4, 6, 9, 12, 18, 24, 30, 36, 48, 60];

  @override
  void initState() {
    super.initState();
    _questions = _getFilteredQuestions();
    // Create controllers for numeric input questions
    for (final q in _questions) {
      final format = q.overrideFormat ?? widget.toolConfig.responseFormat;
      if (format == ResponseFormat.numericInput) {
        _numericControllers[q.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _numericControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<ScreeningQuestion> _getFilteredQuestions() {
    final questions = widget.toolConfig.questions;

    // For CDC milestones, filter to only 2 brackets: previous + current/next
    if (widget.toolConfig.isAgeBracketFiltered) {
      final brackets = _getCdcTwoBrackets(widget.childAgeMonths);
      return questions
          .where((q) => q.ageMonths != null && brackets.contains(q.ageMonths))
          .toList();
    }

    return questions;
  }

  /// Get the two CDC age brackets to test for a given child age.
  /// For a child exactly on a bracket (e.g. 30m): returns {24, 30}.
  /// For a child between brackets (e.g. 29m): returns {24, 30}.
  Set<int> _getCdcTwoBrackets(int ageMonths) {
    // Edge case: younger than first bracket
    if (ageMonths < _cdcAgeBrackets.first) {
      return {_cdcAgeBrackets.first};
    }

    // Find currentIdx: largest i where brackets[i] <= ageMonths
    int currentIdx = 0;
    for (int i = 0; i < _cdcAgeBrackets.length; i++) {
      if (_cdcAgeBrackets[i] <= ageMonths) {
        currentIdx = i;
      } else {
        break;
      }
    }

    if (_cdcAgeBrackets[currentIdx] == ageMonths) {
      // Exactly on a bracket: show previous bracket + this bracket
      if (currentIdx > 0) {
        return {_cdcAgeBrackets[currentIdx - 1], _cdcAgeBrackets[currentIdx]};
      }
      return {_cdcAgeBrackets[currentIdx]};
    } else {
      // Between brackets: show lower bracket + next bracket
      if (currentIdx < _cdcAgeBrackets.length - 1) {
        return {_cdcAgeBrackets[currentIdx], _cdcAgeBrackets[currentIdx + 1]};
      }
      return {_cdcAgeBrackets[currentIdx]};
    }
  }

  void _answerQuestion(String questionId, dynamic value) {
    setState(() {
      _responses[questionId] = value;
      // Auto-advance for non-numeric responses
      final question = _questions[_currentIndex];
      final format = question.overrideFormat ?? widget.toolConfig.responseFormat;
      if (format != ResponseFormat.numericInput) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _currentIndex < _questions.length - 1) {
            setState(() => _currentIndex++);
          }
        });
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _completeQuestionnaire() {
    // Check required questions (non-optional) are answered
    final unanswered = _questions.where((q) {
      if (q.question.contains('optional') || q.questionTe.contains('ఐచ్ఛికం')) {
        return false; // Skip optional questions
      }
      return !_responses.containsKey(q.id);
    }).toList();

    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all required questions (${unanswered.length} remaining)'),
          backgroundColor: Colors.orange,
        ),
      );
      // Jump to first unanswered
      final idx = _questions.indexOf(unanswered.first);
      if (idx >= 0) setState(() => _currentIndex = idx);
      return;
    }

    widget.onComplete(_responses);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isTelugu ? widget.toolConfig.nameTe : widget.toolConfig.name),
          backgroundColor: widget.toolConfig.color,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(isTelugu
              ? 'ఈ వయస్సుకు ప్రశ్నలు అందుబాటులో లేవు'
              : 'No questions available for this age'),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTelugu ? widget.toolConfig.nameTe : widget.toolConfig.name,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: widget.toolConfig.color,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(widget.toolConfig.color),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain badge
                  if (question.domainName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.toolConfig.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: widget.toolConfig.color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        isTelugu ? (question.domainNameTe ?? question.domainName!) : question.domainName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.toolConfig.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (question.domainName != null) const SizedBox(height: 16),

                  // Category (e.g., "Over the last 2 weeks" for PHQ-9)
                  if (question.category != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        isTelugu ? (question.categoryTe ?? question.category!) : question.category!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  // Age badge for CDC milestones
                  if (question.ageMonths != null && widget.toolConfig.isAgeBracketFiltered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        isTelugu ? '${question.ageMonths} నెలలు' : '${question.ageMonths} months',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                  // Question text
                  Text(
                    isTelugu ? question.questionTe : question.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),

                  // Red flag / critical indicator
                  if (question.isRedFlag)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            isTelugu ? 'ముఖ్యమైన అంశం' : 'Critical item',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Response widget
                  _buildResponseWidget(question, isTelugu),
                ],
              ),
            ),
          ),

          // Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(isTelugu ? 'వెనుకకు' : 'Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: _currentIndex == _questions.length - 1
                      ? ElevatedButton.icon(
                          onPressed: _completeQuestionnaire,
                          icon: const Icon(Icons.check),
                          label: Text(isTelugu ? 'పూర్తి చేయండి' : 'Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.riskLow,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _responses.containsKey(question.id) ? _nextQuestion : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(isTelugu ? 'తదుపరి' : 'Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.toolConfig.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

  /// Tools where "No" is the healthy answer (questions ask about problems/symptoms)
  static const _noIsHealthy = {
    ScreeningToolType.rbskBehavioral,
    ScreeningToolType.adhdScreening,
  };

  Widget _buildResponseWidget(ScreeningQuestion question, bool isTelugu) {
    final format = question.overrideFormat ?? widget.toolConfig.responseFormat;
    final currentValue = _responses[question.id];
    final reverseColors = _noIsHealthy.contains(widget.toolConfig.type);

    switch (format) {
      case ResponseFormat.yesNo:
        return YesNoResponse(
          isTelugu: isTelugu,
          currentValue: currentValue,
          onChanged: (value) => _answerQuestion(question.id, value),
          reverseColors: reverseColors,
        );

      case ResponseFormat.threePoint:
      case ResponseFormat.fourPoint:
      case ResponseFormat.fivePoint:
        final options = question.responseOptions ?? widget.toolConfig.questions.first.responseOptions ?? [];
        if (options.isEmpty) {
          return YesNoResponse(
            isTelugu: isTelugu,
            currentValue: currentValue,
            onChanged: (value) => _answerQuestion(question.id, value),
            reverseColors: reverseColors,
          );
        }
        return ScaleResponse(
          options: options,
          isTelugu: isTelugu,
          currentValue: currentValue,
          onChanged: (value) => _answerQuestion(question.id, value),
        );

      case ResponseFormat.numericInput:
        return NumericInputResponse(
          unit: question.unit ?? '',
          hint: isTelugu ? 'ఉదా: 85.5' : 'e.g., 85.5',
          isTelugu: isTelugu,
          controller: _numericControllers[question.id] ?? TextEditingController(),
          onChanged: (value) {
            final parsed = double.tryParse(value);
            setState(() {
              if (parsed != null) {
                _responses[question.id] = parsed;
              } else if (value.isEmpty) {
                _responses.remove(question.id);
              }
            });
          },
        );

      case ResponseFormat.mixed:
        // For mixed format, check the question's override format
        return _buildResponseWidget(
          ScreeningQuestion(
            id: question.id,
            question: question.question,
            questionTe: question.questionTe,
            domain: question.domain,
            unit: question.unit,
            overrideFormat: question.overrideFormat ?? ResponseFormat.yesNo,
          ),
          isTelugu,
        );
    }
  }
}
