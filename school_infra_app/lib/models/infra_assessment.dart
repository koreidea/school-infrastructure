class InfraAssessment {
  final int? id;
  final int schoolId;
  final String? assessedBy;
  final DateTime assessmentDate;
  final int existingClassrooms;
  final int existingToilets;
  final bool cwsnToiletAvailable;
  final bool cwsnResourceRoomAvailable;
  final bool drinkingWaterAvailable;
  final String electrificationStatus; // FULL, PARTIAL, NONE
  final bool rampAvailable;
  final String conditionRating; // GOOD, NEEDS_REPAIR, CRITICAL
  final List<String>? photos;
  final String? notes;
  final bool synced;

  InfraAssessment({
    this.id,
    required this.schoolId,
    this.assessedBy,
    required this.assessmentDate,
    this.existingClassrooms = 0,
    this.existingToilets = 0,
    this.cwsnToiletAvailable = false,
    this.cwsnResourceRoomAvailable = false,
    this.drinkingWaterAvailable = false,
    this.electrificationStatus = 'NONE',
    this.rampAvailable = false,
    this.conditionRating = 'GOOD',
    this.photos,
    this.notes,
    this.synced = false,
  });

  factory InfraAssessment.fromJson(Map<String, dynamic> json) {
    return InfraAssessment(
      id: json['id'] as int?,
      schoolId: json['school_id'] as int,
      assessedBy: json['assessed_by']?.toString(),
      assessmentDate: DateTime.tryParse(
              json['assessment_date']?.toString() ?? '') ??
          DateTime.now(),
      existingClassrooms: json['existing_classrooms'] as int? ?? 0,
      existingToilets: json['existing_toilets'] as int? ?? 0,
      cwsnToiletAvailable: json['cwsn_toilet_available'] as bool? ?? false,
      cwsnResourceRoomAvailable:
          json['cwsn_resource_room_available'] as bool? ?? false,
      drinkingWaterAvailable:
          json['drinking_water_available'] as bool? ?? false,
      electrificationStatus:
          json['electrification_status'] as String? ?? 'NONE',
      rampAvailable: json['ramp_available'] as bool? ?? false,
      conditionRating: json['condition_rating'] as String? ?? 'GOOD',
      photos: (json['photos'] as List?)?.cast<String>(),
      notes: json['notes'] as String?,
      synced: json['synced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'school_id': schoolId,
        'assessed_by': assessedBy,
        'assessment_date': assessmentDate.toIso8601String().split('T')[0],
        'existing_classrooms': existingClassrooms,
        'existing_toilets': existingToilets,
        'cwsn_toilet_available': cwsnToiletAvailable,
        'cwsn_resource_room_available': cwsnResourceRoomAvailable,
        'drinking_water_available': drinkingWaterAvailable,
        'electrification_status': electrificationStatus,
        'ramp_available': rampAvailable,
        'condition_rating': conditionRating,
        'photos': photos,
        'notes': notes,
      };

  int get missingFacilitiesCount {
    int count = 0;
    if (!cwsnToiletAvailable) count++;
    if (!cwsnResourceRoomAvailable) count++;
    if (!drinkingWaterAvailable) count++;
    if (electrificationStatus == 'NONE') count++;
    if (!rampAvailable) count++;
    return count;
  }

  bool get isCritical => conditionRating == 'CRITICAL';
  bool get needsRepair => conditionRating == 'NEEDS_REPAIR';
}
