import 'package:flutter/material.dart';
import '../models/screening_tool.dart';
import '../config/api_config.dart';

/// Yes/No response widget
class YesNoResponse extends StatelessWidget {
  final bool isTelugu;
  final dynamic currentValue;
  final ValueChanged<dynamic> onChanged;
  /// When true, "No" = healthy (green) and "Yes" = concerning (red).
  /// Used for tools where questions ask about problems (RBSK Behavioral, ADHD).
  final bool reverseColors;

  const YesNoResponse({
    super.key,
    required this.isTelugu,
    required this.currentValue,
    required this.onChanged,
    this.reverseColors = false,
  });

  @override
  Widget build(BuildContext context) {
    final yesColor = reverseColors ? AppColors.riskHigh : AppColors.riskLow;
    final noColor = reverseColors ? AppColors.riskLow : AppColors.riskHigh;

    return Row(
      children: [
        Expanded(
          child: _ResponseButton(
            label: isTelugu ? 'అవును' : 'Yes',
            isSelected: currentValue == true,
            color: yesColor,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ResponseButton(
            label: isTelugu ? 'కాదు' : 'No',
            isSelected: currentValue == false,
            color: noColor,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

/// Multi-point scale response widget (3, 4, or 5 point)
class ScaleResponse extends StatelessWidget {
  final List<ResponseOption> options;
  final bool isTelugu;
  final dynamic currentValue;
  final ValueChanged<dynamic> onChanged;

  const ScaleResponse({
    super.key,
    required this.options,
    required this.isTelugu,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = currentValue == option.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(option.value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (option.color ?? AppColors.primary).withValues(alpha: 0.15)
                    : Colors.grey.shade50,
                border: Border.all(
                  color: isSelected
                      ? (option.color ?? AppColors.primary)
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (option.color ?? AppColors.primary)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? (option.color ?? AppColors.primary)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isTelugu ? option.labelTe : option.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (option.color ?? AppColors.primary)
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Numeric input response widget
class NumericInputResponse extends StatelessWidget {
  final String unit;
  final String hint;
  final bool isTelugu;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const NumericInputResponse({
    super.key,
    required this.unit,
    required this.hint,
    required this.isTelugu,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: unit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _ResponseButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ResponseButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
