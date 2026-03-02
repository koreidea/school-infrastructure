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
  final String electrificationStatus; // Electrified, Partially, None
  final bool rampAvailable;
  final String conditionRating; // Good, Needs Repair, Critical, Dilapidated
  final List<String>? photos;
  final String? notes;
  final bool synced;

  // Toilet Breakdown
  final int boysToilets;
  final int girlsToilets;
  final int functionalToilets;
  final bool handwashAvailable;

  // Classroom Quality
  final int functionalClassrooms;
  final String furnitureAdequacy; // Adequate, Partial, Inadequate

  // Boundary Wall
  final String boundaryWall; // Complete, Partial, None

  // Water Source
  final String waterSourceType; // Tap Water, Hand Pump, Bore Well, Tanker, None
  final bool waterPurifierAvailable;

  // Kitchen / Mid-Day Meal
  final bool mdmKitchenAvailable;
  final String mdmKitchenCondition; // Good, Needs Repair, Non-Functional

  // Library
  final bool libraryAvailable;

  // Computer / ICT Lab
  final bool computerLabAvailable;
  final int functionalComputers;

  // Safety Equipment
  final bool fireExtinguisherAvailable;
  final bool firstAidAvailable;

  // GPS Auto-Capture
  final double? inspectionLatitude;
  final double? inspectionLongitude;

  // Per-Infra Condition Ratings
  final String buildingCondition; // Good, Needs Repair, Critical, Dilapidated
  final String toiletCondition;
  final String electricalCondition;

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
    this.electrificationStatus = 'None',
    this.rampAvailable = false,
    this.conditionRating = 'Good',
    this.photos,
    this.notes,
    this.synced = false,
    // Toilet Breakdown
    this.boysToilets = 0,
    this.girlsToilets = 0,
    this.functionalToilets = 0,
    this.handwashAvailable = false,
    // Classroom Quality
    this.functionalClassrooms = 0,
    this.furnitureAdequacy = 'Adequate',
    // Boundary Wall
    this.boundaryWall = 'None',
    // Water Source
    this.waterSourceType = 'None',
    this.waterPurifierAvailable = false,
    // Kitchen / MDM
    this.mdmKitchenAvailable = false,
    this.mdmKitchenCondition = 'Non-Functional',
    // Library
    this.libraryAvailable = false,
    // Computer Lab
    this.computerLabAvailable = false,
    this.functionalComputers = 0,
    // Safety
    this.fireExtinguisherAvailable = false,
    this.firstAidAvailable = false,
    // GPS
    this.inspectionLatitude,
    this.inspectionLongitude,
    // Per-Infra Condition
    this.buildingCondition = 'Good',
    this.toiletCondition = 'Good',
    this.electricalCondition = 'Good',
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
          json['electrification_status'] as String? ?? 'None',
      rampAvailable: json['ramp_available'] as bool? ?? false,
      conditionRating: json['condition_rating'] as String? ?? 'Good',
      photos: (json['photos'] as List?)?.cast<String>(),
      notes: json['notes'] as String?,
      synced: json['synced'] as bool? ?? true,
      // Toilet Breakdown
      boysToilets: json['boys_toilets'] as int? ?? 0,
      girlsToilets: json['girls_toilets'] as int? ?? 0,
      functionalToilets: json['functional_toilets'] as int? ?? 0,
      handwashAvailable: json['handwash_available'] as bool? ?? false,
      // Classroom Quality
      functionalClassrooms: json['functional_classrooms'] as int? ?? 0,
      furnitureAdequacy: json['furniture_adequacy'] as String? ?? 'Adequate',
      // Boundary Wall
      boundaryWall: json['boundary_wall'] as String? ?? 'None',
      // Water Source
      waterSourceType: json['water_source_type'] as String? ?? 'None',
      waterPurifierAvailable:
          json['water_purifier_available'] as bool? ?? false,
      // Kitchen / MDM
      mdmKitchenAvailable: json['mdm_kitchen_available'] as bool? ?? false,
      mdmKitchenCondition:
          json['mdm_kitchen_condition'] as String? ?? 'Non-Functional',
      // Library
      libraryAvailable: json['library_available'] as bool? ?? false,
      // Computer Lab
      computerLabAvailable: json['computer_lab_available'] as bool? ?? false,
      functionalComputers: json['functional_computers'] as int? ?? 0,
      // Safety
      fireExtinguisherAvailable:
          json['fire_extinguisher_available'] as bool? ?? false,
      firstAidAvailable: json['first_aid_available'] as bool? ?? false,
      // GPS
      inspectionLatitude:
          (json['inspection_latitude'] as num?)?.toDouble(),
      inspectionLongitude:
          (json['inspection_longitude'] as num?)?.toDouble(),
      // Per-Infra Condition
      buildingCondition: json['building_condition'] as String? ?? 'Good',
      toiletCondition: json['toilet_condition'] as String? ?? 'Good',
      electricalCondition: json['electrical_condition'] as String? ?? 'Good',
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
        // Toilet Breakdown
        'boys_toilets': boysToilets,
        'girls_toilets': girlsToilets,
        'functional_toilets': functionalToilets,
        'handwash_available': handwashAvailable,
        // Classroom Quality
        'functional_classrooms': functionalClassrooms,
        'furniture_adequacy': furnitureAdequacy,
        // Boundary Wall
        'boundary_wall': boundaryWall,
        // Water Source
        'water_source_type': waterSourceType,
        'water_purifier_available': waterPurifierAvailable,
        // Kitchen / MDM
        'mdm_kitchen_available': mdmKitchenAvailable,
        'mdm_kitchen_condition': mdmKitchenCondition,
        // Library
        'library_available': libraryAvailable,
        // Computer Lab
        'computer_lab_available': computerLabAvailable,
        'functional_computers': functionalComputers,
        // Safety
        'fire_extinguisher_available': fireExtinguisherAvailable,
        'first_aid_available': firstAidAvailable,
        // GPS
        'inspection_latitude': inspectionLatitude,
        'inspection_longitude': inspectionLongitude,
        // Per-Infra Condition
        'building_condition': buildingCondition,
        'toilet_condition': toiletCondition,
        'electrical_condition': electricalCondition,
      };

  /// Original missing facilities count — used by priority scoring service.
  /// Kept unchanged to preserve scoring behavior.
  int get missingFacilitiesCount {
    int count = 0;
    if (!cwsnToiletAvailable) count++;
    if (!cwsnResourceRoomAvailable) count++;
    if (!drinkingWaterAvailable) count++;
    if (electrificationStatus == 'None') count++;
    if (!rampAvailable) count++;
    return count;
  }

  /// Extended missing facilities count — includes all new facility checks.
  /// Use for display/reporting, not for priority scoring.
  int get extendedMissingFacilitiesCount {
    int count = missingFacilitiesCount;
    if (!handwashAvailable) count++;
    if (!libraryAvailable) count++;
    if (!computerLabAvailable) count++;
    if (!fireExtinguisherAvailable) count++;
    if (!firstAidAvailable) count++;
    if (!mdmKitchenAvailable) count++;
    if (boundaryWall == 'None') count++;
    if (waterSourceType == 'None') count++;
    return count;
  }

  bool get isCritical => conditionRating == 'Critical';
  bool get needsRepair => conditionRating == 'Needs Repair';

  // Per-infra condition helpers
  bool get hasBuildingCritical =>
      buildingCondition == 'Critical' || buildingCondition == 'Dilapidated';
  bool get hasToiletCritical =>
      toiletCondition == 'Critical' || toiletCondition == 'Dilapidated';
  bool get hasElectricalCritical =>
      electricalCondition == 'Critical' || electricalCondition == 'Dilapidated';

  bool get hasGPS => inspectionLatitude != null && inspectionLongitude != null;
}
