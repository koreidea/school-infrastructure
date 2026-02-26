import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Form fields
  int _existingClassrooms = 0;
  int _existingToilets = 0;
  bool _cwsnToiletAvailable = false;
  bool _cwsnResourceRoomAvailable = false;
  bool _drinkingWaterAvailable = false;
  String _electrificationStatus = 'None';
  bool _rampAvailable = false;
  String _conditionRating = 'Good';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 960,
        imageQuality: 80,
      );
      if (picked == null) return;

      // Save to app documents for offline access
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${dir.path}/inspection_photos');
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }
      final fileName =
          'photo_${widget.school.id}_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedFile = await File(picked.path).copy('${photoDir.path}/$fileName');

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
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
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

  /// Upload photos to Supabase Storage and return public URLs
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
        // If storage upload fails, fall back to local path
        debugPrint('Photo upload failed: $e');
        uploadedUrls.add(photo.path);
      }
    }
    return uploadedUrls;
  }

  Future<void> _submitAssessment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context);

    try {
      // Upload photos to Supabase Storage (falls back to local paths)
      final photoUrls = _capturedPhotos.isNotEmpty
          ? await _uploadPhotos()
          : <String>[];

      final assessment = InfraAssessment(
        id: 0,
        schoolId: widget.school.id,
        assessedBy: 'Field Inspector',
        assessmentDate: DateTime.now(),
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
      );

      try {
        await SupabaseService.saveAssessment(assessment);
      } catch (_) {
        // Save offline if network fails
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
          SnackBar(content: Text('${l10n.translate("error")}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            // School info header
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${l10n.translate("udise_code")}: ${widget.school.udiseCode}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section: Existing Infrastructure
            _SectionHeader(l10n.translate('existing_infrastructure')),
            const SizedBox(height: 12),

            _NumberField(
              label: l10n.translate('num_classrooms'),
              icon: Icons.meeting_room,
              value: _existingClassrooms,
              onChanged: (v) => _existingClassrooms = v,
            ),
            const SizedBox(height: 12),
            _NumberField(
              label: l10n.translate('num_toilets'),
              icon: Icons.wc,
              value: _existingToilets,
              onChanged: (v) => _existingToilets = v,
            ),
            const SizedBox(height: 20),

            // Section: CWSN Facilities
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

            // Section: Basic Amenities
            _SectionHeader(l10n.translate('basic_amenities')),
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
              label: l10n.translate('electrification_status'),
              icon: Icons.electrical_services,
              value: _electrificationStatus,
              options: ['Electrified', 'Partially', 'None'],
              onChanged: (v) =>
                  setState(() => _electrificationStatus = v ?? 'None'),
            ),
            const SizedBox(height: 20),

            // Section: Overall Condition
            _SectionHeader(l10n.translate('overall_condition')),
            const SizedBox(height: 12),

            _DropdownField(
              label: l10n.translate('condition_rating'),
              icon: Icons.star_rate,
              value: _conditionRating,
              options: ['Good', 'Needs Repair', 'Critical', 'Dilapidated'],
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

            // Section: Photo Evidence
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

            // Submit button
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
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
