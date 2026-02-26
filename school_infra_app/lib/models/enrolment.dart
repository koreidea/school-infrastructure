class EnrolmentRecord {
  final int id;
  final int schoolId;
  final String academicYear;
  final String grade;
  final int boys;
  final int girls;
  final int total;

  EnrolmentRecord({
    required this.id,
    required this.schoolId,
    required this.academicYear,
    required this.grade,
    required this.boys,
    required this.girls,
    required this.total,
  });

  factory EnrolmentRecord.fromJson(Map<String, dynamic> json) {
    return EnrolmentRecord(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      academicYear: json['academic_year'] as String,
      grade: json['grade'] as String,
      boys: json['boys'] as int? ?? 0,
      girls: json['girls'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'school_id': schoolId,
        'academic_year': academicYear,
        'grade': grade,
        'boys': boys,
        'girls': girls,
        'total': total,
      };
}

class EnrolmentSummary {
  final String academicYear;
  final int totalBoys;
  final int totalGirls;
  final int totalStudents;
  final Map<String, int> gradeWise;

  EnrolmentSummary({
    required this.academicYear,
    required this.totalBoys,
    required this.totalGirls,
    required this.totalStudents,
    required this.gradeWise,
  });

  double get genderRatio =>
      totalStudents > 0 ? totalGirls / totalStudents * 100 : 0;

  factory EnrolmentSummary.fromRecords(
      String year, List<EnrolmentRecord> records) {
    int boys = 0, girls = 0, total = 0;
    final gradeWise = <String, int>{};
    for (final r in records) {
      if (r.academicYear == year) {
        boys += r.boys;
        girls += r.girls;
        total += r.total;
        gradeWise[r.grade] = r.total;
      }
    }
    return EnrolmentSummary(
      academicYear: year,
      totalBoys: boys,
      totalGirls: girls,
      totalStudents: total,
      gradeWise: gradeWise,
    );
  }
}

class EnrolmentTrend {
  final int schoolId;
  final List<EnrolmentSummary> yearWise;
  final double growthRate; // percentage change year-over-year
  final String trend; // GROWING, DECLINING, STABLE

  EnrolmentTrend({
    required this.schoolId,
    required this.yearWise,
    required this.growthRate,
    required this.trend,
  });

  factory EnrolmentTrend.compute(
      int schoolId, List<EnrolmentRecord> records) {
    final years =
        records.map((r) => r.academicYear).toSet().toList()..sort();
    final summaries =
        years.map((y) => EnrolmentSummary.fromRecords(y, records)).toList();

    double growthRate = 0;
    String trend = 'STABLE';
    if (summaries.length >= 2) {
      final first = summaries.first.totalStudents;
      final last = summaries.last.totalStudents;
      if (first > 0) {
        growthRate = ((last - first) / first) * 100;
      }
      if (growthRate > 5) {
        trend = 'GROWING';
      } else if (growthRate < -5) {
        trend = 'DECLINING';
      }
    }

    return EnrolmentTrend(
      schoolId: schoolId,
      yearWise: summaries,
      growthRate: growthRate,
      trend: trend,
    );
  }
}

class EnrolmentForecast {
  final int id;
  final int schoolId;
  final String forecastYear;
  final String? grade;
  final int predictedTotal;
  final double confidence;
  final String? modelUsed;

  EnrolmentForecast({
    required this.id,
    required this.schoolId,
    required this.forecastYear,
    this.grade,
    required this.predictedTotal,
    required this.confidence,
    this.modelUsed,
  });

  factory EnrolmentForecast.fromJson(Map<String, dynamic> json) {
    return EnrolmentForecast(
      id: json['id'] as int? ?? 0,
      schoolId: json['school_id'] as int,
      forecastYear: json['forecast_year'] as String,
      grade: json['grade'] as String?,
      predictedTotal: json['predicted_total'] as int? ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      modelUsed: json['model_used'] as String?,
    );
  }
}
