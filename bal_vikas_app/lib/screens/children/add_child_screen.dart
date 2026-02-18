import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/children_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/audit_service.dart';
import '../consent/consent_capture_screen.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _anganwadiController = TextEditingController();
  
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _anganwadiController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ?? DateTime(now.year - 3, now.month, now.day);
    final firstDate = DateTime(now.year - 10);
    final lastDate = now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
      });
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dobStr = _selectedDateOfBirth!.toIso8601String().split('T')[0];
      final childName = _nameController.text.trim();

      // Get current user profile for AWC assignment
      final userProfile = await SupabaseService.getCurrentUserProfile();

      // Insert child via Supabase
      final row = await SupabaseService.client.from('children').insert({
        'child_unique_id': 'AP_ECD_${DateTime.now().millisecondsSinceEpoch}',
        'name': childName,
        'dob': dobStr,
        'gender': _selectedGender,
        'awc_id': userProfile?['awc_id'],
        'aww_id': userProfile?['id'],
      }).select().single();

      final childId = row['id'] as int;

      // Log audit event
      AuditService.log(
        action: 'create_child',
        entityType: 'child',
        entityId: childId,
        entityName: childName,
      );

      if (mounted) {
        // Refresh the children list
        ref.invalidate(childrenProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child registered successfully')),
        );

        // Navigate to consent capture screen
        final childData = {
          'child_id': childId,
          'name': childName,
          'date_of_birth': dobStr,
          'gender': _selectedGender,
        };

        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ConsentCaptureScreen(child: childData),
          ),
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Child'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Child Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Child Name *',
                  hintText: 'Enter child\'s full name',
                  prefixIcon: const Icon(Icons.child_care),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter child name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: _isLoading ? null : _selectDateOfBirth,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedDateOfBirth != null
                        ? _formatDate(_selectedDateOfBirth!)
                        : 'Select date of birth',
                    style: TextStyle(
                      color: _selectedDateOfBirth != null
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Gender *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(
                              Icons.boy,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text('Male'),
                          ],
                        ),
                        value: 'male',
                        groupValue: _selectedGender,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(
                              Icons.girl,
                              color: Colors.pink.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text('Female'),
                          ],
                        ),
                        value: 'female',
                        groupValue: _selectedGender,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Parent Name
              TextFormField(
                controller: _parentNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Parent Name *',
                  hintText: 'Enter parent\'s full name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter parent name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Anganwadi Center
              TextFormField(
                controller: _anganwadiController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Anganwadi Center *',
                  hintText: 'Enter anganwadi center name',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter anganwadi center';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChild,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
