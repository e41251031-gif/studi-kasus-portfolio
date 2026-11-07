import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State global sederhana: tema dan penanda data berubah (untuk refresh halaman).
class AppState {
  AppState._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Naik setiap kali data portofolio/profil berubah.
  static final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

  static void notifyDataChanged() => dataVersion.value++;

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('dark_mode') ?? false;
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setDarkMode(bool dark) async {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', dark);
  }
}

const Color kPrimary = Color(0xFF0D47A1);
const Color kAccent = Color(0xFF00897B);

const LinearGradient kHeaderGradient = LinearGradient(
  colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF00897B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

IconData categoryIcon(String category) {
  switch (category) {
    case 'Mobile App':
      return Icons.phone_android;
    case 'Web':
      return Icons.language;
    case 'UI/UX Design':
      return Icons.brush;
    case 'Data':
      return Icons.bar_chart;
    case 'IoT':
      return Icons.memory;
    default:
      return Icons.folder_special;
  }
}
