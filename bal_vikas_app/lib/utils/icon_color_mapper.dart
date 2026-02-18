import 'package:flutter/material.dart';

/// Map icon name strings (from DB) to Flutter IconData
IconData mapIconName(String? iconName) {
  switch (iconName) {
    case 'child_care':
      return Icons.child_care;
    case 'medical_services':
      return Icons.medical_services;
    case 'psychology':
      return Icons.psychology;
    case 'psychology_alt':
      return Icons.psychology_alt;
    case 'flash_on':
      return Icons.flash_on;
    case 'warning_amber':
      return Icons.warning_amber;
    case 'balance':
      return Icons.balance;
    case 'family_restroom':
      return Icons.family_restroom;
    case 'favorite_border':
      return Icons.favorite_border;
    case 'home':
      return Icons.home;
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_run':
      return Icons.directions_run;
    case 'back_hand':
      return Icons.back_hand;
    case 'record_voice_over':
      return Icons.record_voice_over;
    case 'people':
      return Icons.people;
    case 'fitness_center':
      return Icons.fitness_center;
    default:
      return Icons.quiz;
  }
}

/// Map hex color string (e.g. '#2196F3') to Flutter Color
Color mapColorHex(String? colorHex) {
  if (colorHex == null || colorHex.isEmpty) return const Color(0xFF2196F3);
  try {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  } catch (_) {
    return const Color(0xFF2196F3);
  }
}
