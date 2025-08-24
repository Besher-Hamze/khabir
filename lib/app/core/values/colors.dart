import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE53E3E);
  static const Color primaryLight = Color(0xFFFF6B6B);
  static const Color primaryDark = Color(0xFFCC2E2E);
  
  static const Color secondary = Color(0xFF2D3748);
  static const Color secondaryLight = Color(0xFF4A5568);
  static const Color secondaryDark = Color(0xFF1A202C);
  
  static const Color accent = Color(0xFF38B2AC);
  static const Color accentLight = Color(0xFF4FD1C7);
  static const Color accentDark = Color(0xFF2C7A7B);
  
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF3182CE);
  
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Colors.grey;
  static const Color divider = Color(0xFFEDF2F7);
  
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);
  
  static const Color onlineStatus = Color(0xFF48BB78);
  static const Color offlineStatus = Color(0xFF9CA3AF);
  
  static const Color ratingStars = Color(0xFFFBBF24);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF7FAFC), Color(0xFFEDF2F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
