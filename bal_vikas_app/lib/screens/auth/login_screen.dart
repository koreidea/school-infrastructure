import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.sendOtp(_mobileController.text);

      setState(() {
        _otpSent = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your phone')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.verifyOtp(_mobileController.text, _otpController.text);
      
      // After successful OTP verification, check if user needs role selection
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Wait briefly for state to propagate
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Check if user needs role selection
        final needsRole = authNotifier.needsRoleSelection;
        print('[LoginScreen] needsRoleSelection: $needsRole');
        
        if (needsRole && mounted) {
          await _showRoleSelectionDialog();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Show role selection dialog for new users without a role
  Future<void> _showRoleSelectionDialog() async {
    final selectedRole = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _RoleSelectionDialog(),
    );

    if (selectedRole != null && mounted) {
      setState(() => _isLoading = true);
      
      try {
        final authNotifier = ref.read(authProvider.notifier);
        await authNotifier.updateUserRole(selectedRole);
        
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update role: $e')),
          );
        }
      }
    }
  }

  Widget _testChip(String role, String number) {
    return InkWell(
      onTap: () => setState(() => _mobileController.text = number),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          '$role: $number',
          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and Title
              Icon(
                Icons.child_care,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                AppConstants.appNameTe,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Early Childhood Development Screening',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Mobile Number Input
              if (!_otpSent) ...[
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter 10-digit mobile number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],

              // OTP Input
              if (_otpSent) ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: 'Enter 6-digit OTP',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text('Change Mobile Number'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify & Login',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              // Pilot mode hint
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Pilot Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_otpSent)
                      const Text(
                        'Enter OTP: 123456',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          _testChip('Senior Official', '8030000001'),
                          _testChip('DW', '8020000001'),
                          _testChip('CDPO', '8010000001'),
                          _testChip('Supervisor', '8000000001'),
                          _testChip('AWW', '7000000001'),
                          _testChip('ECD AWW', '7000000392'),
                          _testChip('Parent', '9000000001'),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Role selection dialog for new users
class _RoleSelectionDialog extends StatefulWidget {
  const _RoleSelectionDialog();

  @override
  State<_RoleSelectionDialog> createState() => _RoleSelectionDialogState();
}

class _RoleSelectionDialogState extends State<_RoleSelectionDialog> {
  String? _selectedRole;

  final List<Map<String, dynamic>> _roles = [
    {
      'code': AppConstants.roleParent,
      'name': 'Parent / Caregiver',
      'nameTe': 'తల్లిదండ్రులు / సంరక్షకులు',
      'icon': Icons.family_restroom,
      'description': 'Track your child\'s development progress',
      'descriptionTe': 'మీ బిడ్డ అభివృద్ధి పురోగతిని ట్రాక్ చేయండి',
    },
    {
      'code': AppConstants.roleAWW,
      'name': 'Anganwadi Worker',
      'nameTe': 'అంగన్వాడీ కార్యకర్త',
      'icon': Icons.school,
      'description': 'Manage center children and screenings',
      'descriptionTe': 'సెంటర్ పిల్లలను మరియు స్క్రీనింగ్‌లను నిర్వహించండి',
    },
    {
      'code': AppConstants.roleSupervisor,
      'name': 'Supervisor',
      'nameTe': 'పర్యవేక్షకులు',
      'icon': Icons.manage_accounts,
      'description': 'Oversee multiple centers and reports',
      'descriptionTe': 'అనేక కేంద్రాలు మరియు నివేదికలను పర్యవేక్షించండి',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Select Your Role',
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please select your role to continue',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ..._roles.map((role) => _buildRoleOption(role)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedRole != null
              ? () => Navigator.of(context).pop(_selectedRole)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildRoleOption(Map<String, dynamic> role) {
    final isSelected = _selectedRole == role['code'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? AppColors.primaryLight : null,
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role['code']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                role['icon'] as IconData,
                size: 32,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : AppColors.text,
                      ),
                    ),
                    Text(
                      role['nameTe'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected 
                            ? AppColors.primaryDark 
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected 
                            ? AppColors.primaryDark 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
