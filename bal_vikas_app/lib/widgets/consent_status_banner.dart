import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/consent_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/consent/consent_capture_screen.dart';
import '../services/database_service.dart';

/// Displays consent status for a child — green if consented, orange if pending.
class ConsentStatusBanner extends ConsumerWidget {
  final int childRemoteId;
  final Map<String, dynamic>? child;

  const ConsentStatusBanner({
    super.key,
    required this.childRemoteId,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final consentState = ref.watch(consentProvider);
    final hasConsent = consentState.value?[childRemoteId] ?? false;

    if (hasConsent) {
      return _ConsentedBanner(
        childRemoteId: childRemoteId,
        isTelugu: isTelugu,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isTelugu
                  ? 'సంరక్షకుడి అనుమతి పెండింగ్‌లో ఉంది'
                  : 'Guardian consent pending',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (child != null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConsentCaptureScreen(child: child!),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: Colors.orange.shade800,
              ),
              child: Text(
                isTelugu ? 'నమోదు చేయండి' : 'Record now',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsentedBanner extends StatefulWidget {
  final int childRemoteId;
  final bool isTelugu;

  const _ConsentedBanner({
    required this.childRemoteId,
    required this.isTelugu,
  });

  @override
  State<_ConsentedBanner> createState() => _ConsentedBannerState();
}

class _ConsentedBannerState extends State<_ConsentedBanner> {
  String _dateText = '';

  @override
  void initState() {
    super.initState();
    _loadConsentDate();
  }

  Future<void> _loadConsentDate() async {
    try {
      final consent = await DatabaseService.db.dpdpDao
          .getActiveConsentForChild(widget.childRemoteId);
      if (consent != null && mounted) {
        setState(() {
          _dateText = DateFormat('dd/MM/yyyy').format(consent.consentTimestamp);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isTelugu
                  ? 'అనుమతి నమోదు చేయబడింది${_dateText.isNotEmpty ? ' — $_dateText' : ''}'
                  : 'Consent recorded${_dateText.isNotEmpty ? ' — $_dateText' : ''}',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
        ],
      ),
    );
  }
}
