import 'package:flutter/material.dart';

/// All screening tool types in administration order
enum ScreeningToolType {
  cdcMilestones,
  rbskTool,
  mchatAutism,
  isaaAutism,
  adhdScreening,
  rbskBehavioral,
  sdqBehavioral,
  parentChildInteraction,
  parentMentalHealth,
  homeStimulation,
  nutritionAssessment,
  rbskBirthDefects,
  rbskDiseases,
}

/// Response format types for different tools
enum ResponseFormat {
  yesNo,
  threePoint,
  fourPoint,
  fivePoint,
  numericInput,
  mixed, // For nutrition: measurements + yes/no dietary
}

/// Named response option for multi-point scales
class ResponseOption {
  final dynamic value;
  final String label;
  final String labelTe;
  final Color? color;

  const ResponseOption({
    required this.value,
    required this.label,
    required this.labelTe,
    this.color,
  });
}

/// Individual question in a screening tool
class ScreeningQuestion {
  final String id;
  final String question;
  final String questionTe;
  final String? domain;
  final String? domainName;
  final String? domainNameTe;
  final String? category;
  final String? categoryTe;
  final int? ageMonths;
  final bool isCritical;
  final bool isRedFlag;
  final bool isReverseScored;
  final List<ResponseOption>? responseOptions;
  final String? unit; // For numeric inputs (cm, kg, etc.)
  final ResponseFormat? overrideFormat; // Override tool's default format

  const ScreeningQuestion({
    required this.id,
    required this.question,
    required this.questionTe,
    this.domain,
    this.domainName,
    this.domainNameTe,
    this.category,
    this.categoryTe,
    this.ageMonths,
    this.isCritical = false,
    this.isRedFlag = false,
    this.isReverseScored = false,
    this.responseOptions,
    this.unit,
    this.overrideFormat,
  });
}

/// Configuration for a screening tool
class ScreeningToolConfig {
  final ScreeningToolType type;
  final String id;
  final String name;
  final String nameTe;
  final String description;
  final String descriptionTe;
  final int minAgeMonths;
  final int maxAgeMonths;
  final ResponseFormat responseFormat;
  final List<String> domains;
  final IconData icon;
  final Color color;
  final int order;
  final bool isAgeBracketFiltered;
  final List<ScreeningQuestion> questions;

  const ScreeningToolConfig({
    required this.type,
    required this.id,
    required this.name,
    required this.nameTe,
    required this.description,
    required this.descriptionTe,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.responseFormat,
    this.domains = const [],
    required this.icon,
    required this.color,
    required this.order,
    this.isAgeBracketFiltered = false,
    required this.questions,
  });

  /// Check if this tool is applicable for a given age
  bool isApplicableForAge(int ageMonths) {
    return ageMonths >= minAgeMonths && ageMonths <= maxAgeMonths;
  }
}

/// Status of a tool in the current screening session
enum ToolStatus { pending, inProgress, completed, skipped }
