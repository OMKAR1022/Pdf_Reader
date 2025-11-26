import 'package:flutter/material.dart';

/// Model for onboarding page data
class OnboardingPageModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
