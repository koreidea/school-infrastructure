import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/screening_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import 'results_screen.dart';

class MeasurementScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic> child;
  final Map<String, bool> responses;

  const MeasurementScreen({
    super.key,
    required this.session,
    required this.child,
    required this.responses,
  });

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _headCircumferenceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _headCircumferenceController.dispose();
    super.dispose();
  }

  Future<void> _completeScreening() async {
    setState(() => _isLoading = true);

    try {
      // Get the session ID from the passed session data
      final sessionId = widget.session['session_id'] ?? widget.session['id'];
      
      if (sessionId == null) {
        throw Exception('Session ID not found');
      }

      // Simulate API call to submit screening data
      await Future.delayed(const Duration(seconds: 2));

      // Save measurements to provider
      ref.read(screeningMeasurementsProvider.notifier).update({
        'height_cm': double.tryParse(_heightController.text),
        'weight_kg': double.tryParse(_weightController.text),
        'head_circumference_cm': _headCircumferenceController.text.isEmpty
            ? null
            : double.tryParse(_headCircumferenceController.text),
      });

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Navigate to results screen with the actual session ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(sessionId: sessionId as int),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'కొలతలు' : 'Measurements'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTelugu
                            ? 'దయచేసి ఖచ్చితమైన కొలతలను నమోదు చేయండి. ఈ కొలతలు వృద్ధి మరియు పోషణ స్థితిని అంచనా వేయడానికి ఉపయోగించబడతాయి.'
                            : 'Please enter accurate measurements. These will be used to assess growth and nutrition status.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Height
            Text(
              isTelugu ? 'ఎత్తు' : 'Height',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isTelugu ? 'ఎత్తు (సెం.మీ)' : 'Height (cm)',
                hintText: isTelugu ? 'ఉదా: 85.5' : 'e.g., 85.5',
                prefixIcon: const Icon(Icons.height),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'cm',
              ),
            ),
            const SizedBox(height: 24),

            // Weight
            Text(
              isTelugu ? 'బరువు' : 'Weight',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isTelugu ? 'బరువు (కిలోలు)' : 'Weight (kg)',
                hintText: isTelugu ? 'ఉదా: 12.3' : 'e.g., 12.3',
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 24),

            // Head Circumference
            Text(
              isTelugu ? 'తల చుట్టు కొలత' : 'Head Circumference',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _headCircumferenceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isTelugu
                    ? 'తల చుట్టు కొలత (సెం.మీ) - ఐచ్ఛికం'
                    : 'Head Circumference (cm) - Optional',
                hintText: isTelugu ? 'ఉదా: 47.5' : 'e.g., 47.5',
                prefixIcon: const Icon(Icons.face),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'cm',
              ),
            ),
            const SizedBox(height: 48),

            // Complete Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeScreening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.riskLow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isTelugu ? 'తనిఖీ పూర్తి చేయండి' : 'Complete Screening',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
