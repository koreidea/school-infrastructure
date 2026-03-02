import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../config/api_config.dart';
import '../../models/infra_assessment.dart';
import '../../models/school.dart';
import '../../services/supabase_service.dart';
import '../../services/offline_cache_service.dart';
import '../../l10n/app_localizations.dart';

class InspectionScreen extends ConsumerStatefulWidget {
  final School school;
  const InspectionScreen({super.key, required this.school});

  @override
  ConsumerState<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends ConsumerState<InspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  final _imagePicker = ImagePicker();
  final List<File> _capturedPhotos = [];

  // === Existing fields ===
  int _existingClassrooms = 0;
  int _existingToilets = 0;
  bool _cwsnToiletAvailable = false;
  bool _cwsnResourceRoomAvailable = false;
  bool _drinkingWaterAvailable = false;
  String _electrificationStatus = 'None';
  bool _rampAvailable = false;
  String _conditionRating = 'Good';
  final _notesController = TextEditingController();

  // === New: Toilet Breakdown ===
  int _boysToilets = 0;
  int _girlsToilets = 0;
  int _functionalToilets = 0;
  bool _handwashAvailable = false;

  // === New: Classroom Quality ===
  int _functionalClassrooms = 0;
  String _furnitureAdequacy = 'Adequate';

  // === New: Boundary Wall ===
  String _boundaryWall = 'None';

  // === New: Water Source ===
  String _waterSourceType = 'None';
  bool _waterPurifierAvailable = false;

  // === New: Kitchen / MDM ===
  bool _mdmKitchenAvailable = false;
  String _mdmKitchenCondition = 'Non-Functional';

  // === New: Library ===
  bool _libraryAvailable = false;

  // === New: Computer Lab ===
  bool _computerLabAvailable = false;
  int _functionalComputers = 0;

  // === New: Safety ===
  bool _fireExtinguisherAvailable = false;
  bool _firstAidAvailable = false;

  // === New: GPS ===
  double? _inspectionLatitude;
  double? _inspectionLongitude;
  bool _gpsLoading = false;

  // === New: Per-Infra Condition ===
  String _buildingCondition = 'Good';
  String _toiletCondition = 'Good';
  String _electricalCondition = 'Good';

  @override
  void initState() {
    super.initState();
    // Auto-capture GPS on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureGPS());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── GPS Capture ──────────────────────────────────────────────────────
  Future<void> _captureGPS() async {
    setState(() => _gpsLoading = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('gps_not_available')),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (mounted) {
        setState(() {
          _inspectionLatitude = position.latitude;
          _inspectionLongitude = position.longitude;
        });
      }
    } catch (e) {
      debugPrint('GPS capture failed: $e');
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  // ── Photo Handling ───────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 960,
        imageQuality: 80,
      );
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${dir.path}/inspection_photos');
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }
      final fileName =
          'photo_${widget.school.id}_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedFile =
          await File(picked.path).copy('${photoDir.path}/$fileName');

      setState(() {
        _capturedPhotos.add(savedFile);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(l10n.fromGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _uploadPhotos() async {
    final uploadedUrls = <String>[];
    for (final photo in _capturedPhotos) {
      try {
        final fileName =
            'school_${widget.school.id}/${DateTime.now().millisecondsSinceEpoch}_${p.basename(photo.path)}';
        final bytes = await photo.readAsBytes();
        await SupabaseService.client.storage
            .from('inspection-photos')
            .uploadBinary(fileName, bytes);
        final url = SupabaseService.client.storage
            .from('inspection-photos')
            .getPublicUrl(fileName);
        uploadedUrls.add(url);
      } catch (e) {
        debugPrint('Photo upload failed: $e');
        uploadedUrls.add(photo.path);
      }
    }
    return uploadedUrls;
  }

  /// Returns true if every field is still at its initial default value,
  /// meaning the inspector hasn't actually filled in any data.
  bool get _isFormUnchanged {
    // Check if ANY field was changed from its default
    if (_existingClassrooms != 0) return false;
    if (_existingToilets != 0) return false;
    if (_cwsnToiletAvailable) return false;
    if (_cwsnResourceRoomAvailable) return false;
    if (_drinkingWaterAvailable) return false;
    if (_electrificationStatus != 'None') return false;
    if (_rampAvailable) return false;
    // Don't check _conditionRating — 'Good' is a valid intentional choice
    if (_boysToilets != 0) return false;
    if (_girlsToilets != 0) return false;
    if (_functionalToilets != 0) return false;
    if (_handwashAvailable) return false;
    if (_functionalClassrooms != 0) return false;
    if (_furnitureAdequacy != 'Adequate') return false;
    if (_boundaryWall != 'None') return false;
    if (_waterSourceType != 'None') return false;
    if (_waterPurifierAvailable) return false;
    if (_mdmKitchenAvailable) return false;
    if (_mdmKitchenCondition != 'Non-Functional') return false;
    if (_libraryAvailable) return false;
    if (_computerLabAvailable) return false;
    if (_functionalComputers != 0) return false;
    if (_fireExtinguisherAvailable) return false;
    if (_firstAidAvailable) return false;
    if (_capturedPhotos.isNotEmpty) return false;
    if (_notesController.text.trim().isNotEmpty) return false;
    // All fields at defaults — form was not filled
    return true;
  }

  // ── Submit ───────────────────────────────────────────────────────────
  Future<void> _submitAssessment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Check if the form was actually filled in
    if (_isFormUnchanged) {
      if (mounted) {
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
            title: const Text('No Data Entered'),
            content: const Text(
              'You haven\'t filled in any inspection data. '
              'Please record the actual infrastructure status of this school before submitting.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard & Go Back'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Continue Editing'),
              ),
            ],
          ),
        );
        if (discard == true && mounted) {
          Navigator.pop(context);
        }
      }
      return;
    }

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context);

    try {
      // Best-effort GPS capture if not already done
      if (_inspectionLatitude == null) {
        await _captureGPS();
      }

      // Upload photos
      final photoUrls = _capturedPhotos.isNotEmpty
          ? await _uploadPhotos()
          : <String>[];

      final assessment = InfraAssessment(
        id: 0,
        schoolId: widget.school.id,
        assessedBy: 'Field Inspector',
        assessmentDate: DateTime.now(),
        // Existing fields
        existingClassrooms: _existingClassrooms,
        existingToilets: _existingToilets,
        cwsnToiletAvailable: _cwsnToiletAvailable,
        cwsnResourceRoomAvailable: _cwsnResourceRoomAvailable,
        drinkingWaterAvailable: _drinkingWaterAvailable,
        electrificationStatus: _electrificationStatus,
        rampAvailable: _rampAvailable,
        conditionRating: _conditionRating,
        photos: photoUrls,
        notes: _notesController.text,
        synced: false,
        // New fields
        boysToilets: _boysToilets,
        girlsToilets: _girlsToilets,
        functionalToilets: _functionalToilets,
        handwashAvailable: _handwashAvailable,
        functionalClassrooms: _functionalClassrooms,
        furnitureAdequacy: _furnitureAdequacy,
        boundaryWall: _boundaryWall,
        waterSourceType: _waterSourceType,
        waterPurifierAvailable: _waterPurifierAvailable,
        mdmKitchenAvailable: _mdmKitchenAvailable,
        mdmKitchenCondition: _mdmKitchenCondition,
        libraryAvailable: _libraryAvailable,
        computerLabAvailable: _computerLabAvailable,
        functionalComputers: _functionalComputers,
        fireExtinguisherAvailable: _fireExtinguisherAvailable,
        firstAidAvailable: _firstAidAvailable,
        inspectionLatitude: _inspectionLatitude,
        inspectionLongitude: _inspectionLongitude,
        buildingCondition: _buildingCondition,
        toiletCondition: _toiletCondition,
        electricalCondition: _electricalCondition,
      );

      try {
        await SupabaseService.saveAssessment(assessment);
      } catch (_) {
        await OfflineCacheService.queueAssessment(assessment);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('assessment_submitted')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate("error")}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final conditionOptions = ['Good', 'Needs Repair', 'Critical', 'Dilapidated'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(l10n.translate('infrastructure_assessment'),
            style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── School Info Header ────────────────────────────────
            Card(
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.school.schoolName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(
                            '${l10n.translate("udise_code")}: ${widget.school.udiseCode}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── 1. Classrooms & Building ──────────────────────────
            _SectionHeader(l10n.translate('classroom_quality')),
            const SizedBox(height: 12),
            _NumberField(
              label: l10n.translate('num_classrooms'),
              icon: Icons.meeting_room,
              value: _existingClassrooms,
              onChanged: (v) => _existingClassrooms = v,
            ),
            const SizedBox(height: 12),
            _NumberField(
              label: l10n.translate('functional_classrooms'),
              icon: Icons.check_circle_outline,
              value: _functionalClassrooms,
              onChanged: (v) => _functionalClassrooms = v,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('furniture_adequacy'),
              icon: Icons.chair,
              value: _furnitureAdequacy,
              options: const ['Adequate', 'Partial', 'Inadequate'],
              onChanged: (v) =>
                  setState(() => _furnitureAdequacy = v ?? 'Adequate'),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('building_condition'),
              icon: Icons.domain,
              value: _buildingCondition,
              options: conditionOptions,
              onChanged: (v) =>
                  setState(() => _buildingCondition = v ?? 'Good'),
            ),
            const SizedBox(height: 20),

            // ─── 2. Toilets & Sanitation ───────────────────────────
            _SectionHeader(l10n.translate('toilet_breakdown')),
            const SizedBox(height: 12),
            _NumberField(
              label: l10n.translate('num_toilets'),
              icon: Icons.wc,
              value: _existingToilets,
              onChanged: (v) => _existingToilets = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: l10n.translate('boys_toilets'),
                    icon: Icons.boy,
                    value: _boysToilets,
                    onChanged: (v) => _boysToilets = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: l10n.translate('girls_toilets'),
                    icon: Icons.girl,
                    value: _girlsToilets,
                    onChanged: (v) => _girlsToilets = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NumberField(
              label: l10n.translate('functional_toilets'),
              icon: Icons.check_circle_outline,
              value: _functionalToilets,
              onChanged: (v) => _functionalToilets = v,
            ),
            const SizedBox(height: 4),
            _SwitchField(
              label: l10n.translate('handwash_available'),
              icon: Icons.wash,
              value: _handwashAvailable,
              onChanged: (v) => setState(() => _handwashAvailable = v),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('toilet_condition'),
              icon: Icons.plumbing,
              value: _toiletCondition,
              options: conditionOptions,
              onChanged: (v) =>
                  setState(() => _toiletCondition = v ?? 'Good'),
            ),
            const SizedBox(height: 20),

            // ─── 3. CWSN Facilities ────────────────────────────────
            _SectionHeader(l10n.translate('cwsn_facilities')),
            const SizedBox(height: 12),
            _SwitchField(
              label: l10n.translate('cwsn_resource_room_available'),
              icon: Icons.accessible,
              value: _cwsnResourceRoomAvailable,
              onChanged: (v) =>
                  setState(() => _cwsnResourceRoomAvailable = v),
            ),
            _SwitchField(
              label: l10n.translate('cwsn_toilet_available'),
              icon: Icons.accessible_forward,
              value: _cwsnToiletAvailable,
              onChanged: (v) => setState(() => _cwsnToiletAvailable = v),
            ),
            _SwitchField(
              label: l10n.translate('ramp_available'),
              icon: Icons.stairs,
              value: _rampAvailable,
              onChanged: (v) => setState(() => _rampAvailable = v),
            ),
            const SizedBox(height: 20),

            // ─── 4. Water Supply ───────────────────────────────────
            _SectionHeader(l10n.translate('water_source_section')),
            const SizedBox(height: 12),
            _SwitchField(
              label: l10n.translate('drinking_water_available'),
              icon: Icons.water_drop,
              value: _drinkingWaterAvailable,
              onChanged: (v) =>
                  setState(() => _drinkingWaterAvailable = v),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('water_source_type'),
              icon: Icons.water,
              value: _waterSourceType,
              options: const [
                'Tap Water',
                'Hand Pump',
                'Bore Well',
                'Tanker',
                'None'
              ],
              onChanged: (v) =>
                  setState(() => _waterSourceType = v ?? 'None'),
            ),
            const SizedBox(height: 4),
            _SwitchField(
              label: l10n.translate('water_purifier_available'),
              icon: Icons.filter_alt,
              value: _waterPurifierAvailable,
              onChanged: (v) =>
                  setState(() => _waterPurifierAvailable = v),
            ),
            const SizedBox(height: 20),

            // ─── 5. Electrification ────────────────────────────────
            _SectionHeader(l10n.translate('electrification_status')),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('electrification_status'),
              icon: Icons.electrical_services,
              value: _electrificationStatus,
              options: const ['Electrified', 'Partially', 'None'],
              onChanged: (v) =>
                  setState(() => _electrificationStatus = v ?? 'None'),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('electrical_condition'),
              icon: Icons.electric_bolt,
              value: _electricalCondition,
              options: conditionOptions,
              onChanged: (v) =>
                  setState(() => _electricalCondition = v ?? 'Good'),
            ),
            const SizedBox(height: 20),

            // ─── 6. Boundary & Security ────────────────────────────
            _SectionHeader(l10n.translate('boundary_wall_section')),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('boundary_wall'),
              icon: Icons.fence,
              value: _boundaryWall,
              options: const ['Complete', 'Partial', 'None'],
              onChanged: (v) =>
                  setState(() => _boundaryWall = v ?? 'None'),
            ),
            const SizedBox(height: 20),

            // ─── 7. Mid-Day Meal Kitchen ───────────────────────────
            _SectionHeader(l10n.translate('mdm_kitchen_section')),
            const SizedBox(height: 12),
            _SwitchField(
              label: l10n.translate('mdm_kitchen_available'),
              icon: Icons.restaurant,
              value: _mdmKitchenAvailable,
              onChanged: (v) =>
                  setState(() => _mdmKitchenAvailable = v),
            ),
            if (_mdmKitchenAvailable) ...[
              const SizedBox(height: 12),
              _DropdownField(
                label: l10n.translate('mdm_kitchen_condition'),
                icon: Icons.restaurant_menu,
                value: _mdmKitchenCondition,
                options: const ['Good', 'Needs Repair', 'Non-Functional'],
                onChanged: (v) => setState(
                    () => _mdmKitchenCondition = v ?? 'Non-Functional'),
              ),
            ],
            const SizedBox(height: 20),

            // ─── 8. Library ────────────────────────────────────────
            _SectionHeader(l10n.translate('library_section')),
            const SizedBox(height: 12),
            _SwitchField(
              label: l10n.translate('library_available'),
              icon: Icons.local_library,
              value: _libraryAvailable,
              onChanged: (v) => setState(() => _libraryAvailable = v),
            ),
            const SizedBox(height: 20),

            // ─── 9. Computer / ICT Lab ─────────────────────────────
            _SectionHeader(l10n.translate('computer_lab_section')),
            const SizedBox(height: 12),
            _SwitchField(
              label: l10n.translate('computer_lab_available'),
              icon: Icons.computer,
              value: _computerLabAvailable,
              onChanged: (v) =>
                  setState(() => _computerLabAvailable = v),
            ),
            if (_computerLabAvailable) ...[
              const SizedBox(height: 12),
              _NumberField(
                label: l10n.translate('functional_computers'),
                icon: Icons.desktop_windows,
                value: _functionalComputers,
                onChanged: (v) => _functionalComputers = v,
              ),
            ],
            const SizedBox(height: 20),

            // ─── 10. Safety Equipment ──────────────────────────────
            _SectionHeader(l10n.translate('safety_section')),
            const SizedBox(height: 12),
            _SwitchField(
              label: l10n.translate('fire_extinguisher_available'),
              icon: Icons.fire_extinguisher,
              value: _fireExtinguisherAvailable,
              onChanged: (v) =>
                  setState(() => _fireExtinguisherAvailable = v),
            ),
            _SwitchField(
              label: l10n.translate('first_aid_available'),
              icon: Icons.medical_services,
              value: _firstAidAvailable,
              onChanged: (v) => setState(() => _firstAidAvailable = v),
            ),
            const SizedBox(height: 20),

            // ─── 11. GPS Location ──────────────────────────────────
            _SectionHeader(l10n.translate('gps_section')),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _inspectionLatitude != null
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _inspectionLatitude != null
                              ? Colors.green
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inspectionLatitude != null
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.translate('gps_captured'),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${_inspectionLatitude!.toStringAsFixed(6)}, ${_inspectionLongitude!.toStringAsFixed(6)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  l10n.translate('gps_not_available'),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _gpsLoading ? null : _captureGPS,
                          icon: _gpsLoading
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Icon(
                                  _inspectionLatitude != null
                                      ? Icons.refresh
                                      : Icons.my_location,
                                  size: 16,
                                ),
                          label: Text(
                            l10n.translate('capture_gps'),
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('gps_auto_note'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── 12. Overall Condition & Notes ─────────────────────
            _SectionHeader(l10n.translate('overall_condition')),
            const SizedBox(height: 12),
            _DropdownField(
              label: l10n.translate('condition_rating'),
              icon: Icons.star_rate,
              value: _conditionRating,
              options: conditionOptions,
              onChanged: (v) =>
                  setState(() => _conditionRating = v ?? 'Good'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.translate('notes_observations'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // ─── 13. Photo Evidence ────────────────────────────────
            _SectionHeader(l10n.addPhotos),
            const SizedBox(height: 12),
            if (_capturedPhotos.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _capturedPhotos.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _capturedPhotos[i],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _capturedPhotos.removeAt(i);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _showPhotoOptions,
              icon: const Icon(Icons.add_a_photo),
              label: Text(_capturedPhotos.isEmpty
                  ? l10n.addPhotos
                  : '${l10n.addPhotos} (${_capturedPhotos.length})'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 30),

            // ─── Submit Button ─────────────────────────────────────
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAssessment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.submitAssessment,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable form widgets
// ═══════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600));
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
    );
  }
}

class _SwitchField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        secondary: Icon(icon, color: AppColors.primary),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        isDense: true,
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
