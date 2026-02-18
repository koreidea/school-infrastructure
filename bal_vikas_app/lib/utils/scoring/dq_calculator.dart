class DQCalculator {
  /// Calculate DQ for a specific domain
  static double calculateDomainDQ({
    required int chronologicalAgeMonths,
    required List<Map<String, dynamic>> milestones,
    required Map<String, bool> responses,
  }) {
    // Find the highest age where child passes ALL milestones
    int developmentalAgeMonths = 0;
    
    for (int age = 2; age <= chronologicalAgeMonths; age++) {
      final ageGroupMilestones = milestones.where((m) => m['age_months'] == age).toList();
      
      if (ageGroupMilestones.isEmpty) continue;
      
      bool passedAll = true;
      for (var milestone in ageGroupMilestones) {
        final questionId = milestone['question_id'] as String?;
        if (questionId == null || responses[questionId] != true) {
          passedAll = false;
          break;
        }
      }
      
      if (passedAll) {
        developmentalAgeMonths = age;
      } else {
        break;
      }
    }
    
    if (chronologicalAgeMonths == 0) return 0.0;
    
    final dq = (developmentalAgeMonths / chronologicalAgeMonths) * 100;
    return double.parse(dq.toStringAsFixed(2));
  }
  
  /// Calculate Composite DQ
  static double calculateCompositeDQ(Map<String, double> domainDQs) {
    final values = [
      domainDQs['gm_dq'] ?? 0,
      domainDQs['fm_dq'] ?? 0,
      domainDQs['lc_dq'] ?? 0,
      domainDQs['cog_dq'] ?? 0,
      domainDQs['se_dq'] ?? 0,
    ];
    
    final validValues = values.where((v) => v > 0).toList();
    if (validValues.isEmpty) return 0.0;
    
    final composite = validValues.reduce((a, b) => a + b) / validValues.length;
    return double.parse(composite.toStringAsFixed(2));
  }
  
  /// Check if DQ indicates delay
  static bool isDelayed(double dq, {double threshold = 85.0}) {
    return dq < threshold;
  }
  
  /// Get delay category
  static String getDelayCategory(double dq) {
    if (dq >= 85) return "On Track";
    if (dq >= 70) return "Mild Delay";
    return "Significant Delay";
  }
}
