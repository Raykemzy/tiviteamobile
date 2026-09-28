import 'package:flutter/services.dart';

class ProfileItemModel {
  final String label;
  final String? icon;
  /// Renders the row in the danger colour (delete account, log out).
  final bool isDestructive;
  final VoidCallback onTap;

  ProfileItemModel({
    required this.label,
    this.icon,
    this.isDestructive = false,
    required this.onTap,
  });
}