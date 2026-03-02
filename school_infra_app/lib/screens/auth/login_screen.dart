import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

enum _LoginPhase { enterPhone, enterOtp }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _LoginPhase _phase = _LoginPhase.enterPhone;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _selectedRole; // Role selected via quick-tap card

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _isEmail => _phoneController.text.contains('@');

  void _handleSendOtp() {
    final input = _phoneController.text.trim();
    if (input.isEmpty) return;

    // Validate: either 10-digit phone or email with @
    if (!_isEmail && input.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('invalid_phone')),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() {
      _phase = _LoginPhase.enterOtp;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('demo_otp_hint')),
        backgroundColor: AppColors.accent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('enter_otp')),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final phoneOrEmail = _phoneController.text.trim();
    final role = await ref.read(currentUserProvider.notifier).loginWithOtp(phoneOrEmail, otp);

    if (role == null && mounted) {
      // Unknown user — show role selection dialog
      setState(() => _isLoading = false);
      _showRoleSelectionDialog(phoneOrEmail);
    }
    // If role matched, currentUserProvider will auto-navigate to dashboard
  }

  void _showRoleSelectionDialog(String phoneOrEmail) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('select_your_role')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: demoUsers.map((u) => ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(u.icon, color: AppColors.primary, size: 22),
            ),
            title: Text(u.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(ctx);
              ref.read(currentUserProvider.notifier).loginWithRole(phoneOrEmail, u.role);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _quickLogin(DemoUser user) {
    setState(() {
      _phoneController.text = user.email;
      _selectedRole = user.role;
      _phase = _LoginPhase.enterPhone; // Show Send OTP button
      _otpController.clear();
    });
    // Scroll up so the login card is visible
  }

  void _resetToPhonePhase() {
    setState(() {
      _phase = _LoginPhase.enterPhone;
      _otpController.clear();
      _selectedRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTelugu = ref.watch(localeProvider).languageCode == 'te';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Language toggle
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
                      icon: const Icon(Icons.translate, color: Colors.white70, size: 18),
                      label: Text(
                        isTelugu ? 'English' : 'తెలుగు',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // App branding
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school, size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.appTagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Department of School Education, Andhra Pradesh',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // ========== LOGIN CARD ==========
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.translate('login_title'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Phone / Email input
                          TextField(
                            controller: _phoneController,
                            enabled: _phase == _LoginPhase.enterPhone,
                            keyboardType: _isEmail
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            inputFormatters: _isEmail
                                ? null
                                : [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9@a-zA-Z._\-]'),
                                    ),
                                  ],
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                _isEmail ? Icons.email : Icons.phone,
                                color: AppColors.primary,
                              ),
                              labelText: l10n.translate('phone_or_email_hint'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),

                          const SizedBox(height: 16),

                          // Phase 1: Send OTP button
                          if (_phase == _LoginPhase.enterPhone)
                            SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _phoneController.text.trim().isNotEmpty
                                    ? _handleSendOtp
                                    : null,
                                icon: const Icon(Icons.sms, size: 20),
                                label: Text(
                                  l10n.translate('send_otp'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                          // Phase 2: OTP input + Verify button
                          if (_phase == _LoginPhase.enterOtp) ...[
                            // OTP sent confirmation
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.statusApproved.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.statusApproved, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${l10n.translate('otp_sent_to')} ${_phoneController.text}',
                                      style: const TextStyle(fontSize: 13, color: AppColors.statusApproved),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _resetToPhonePhase,
                                    child: Text(
                                      l10n.translate('change_number'),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // OTP input
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              autofocus: true,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                                labelText: l10n.translate('enter_otp'),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),

                            // Verify & Login button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : (_otpController.text.isNotEmpty ? _handleVerifyOtp : null),
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.verified_user, size: 20),
                                label: Text(
                                  _isLoading
                                      ? l10n.translate('logging_in')
                                      : l10n.translate('verify_login'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusApproved,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ========== QUICK DEMO LOGIN ==========
                  Text(
                    l10n.translate('quick_demo_login'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.translate('tap_to_login_instantly'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...demoUsers.map((user) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _quickLogin(user),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(user.icon, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${user.phone}  |  ${user.email}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
