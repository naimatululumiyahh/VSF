import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Volunteer Spot Finder';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // Text Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeHeading = 24.0;
  
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusCircle = 100.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  // Categories
  static const List<String> categories = [
    'Semua',
    'Pendidikan',
    'Lingkungan',
    'Kesehatan',
    'Sosial',
    'Anak-anak',
  ];
  
  // Provinces
  static const List<String> provinces = [
    'Semua',
    'DKI Jakarta',
    'Jawa Barat',
    'Jawa Tengah',
    'Jawa Timur',
    'Banten',
    'Yogyakarta',
    'Bali',
    'Sumatera Utara',
    'Sumatera Barat',
    'Sulawesi Selatan',
  ];
  
  // Availability Options
  static const List<String> availabilityOptions = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  
  // Timezones
  static const List<String> timezones = [
    'WIB',
    'WITA',
    'WIT',
    'London',
  ];
  
  // Currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'IDR', 'symbol': 'Rp', 'name': 'Indonesian Rupiah'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
  ];
  
  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Debounce Duration (for search)
  static const Duration debounceDuration = Duration(milliseconds: 500);
  
  // Image Placeholder
  static const String imagePlaceholder = 'https://via.placeholder.com/400x200?text=No+Image';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int nikLength = 16;
  static const int minNpwpLength = 10;
  static const int minMotivationLength = 20;
  static const int minFeedbackLength = 10;
  
  // Pagination
  static const int itemsPerPage = 10;
  static const int maxItemsLoad = 50;
}