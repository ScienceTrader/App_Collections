import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_collection_app/core/utils/logger.dart';

class ThemeController extends GetxController {
  final selectedTheme = ThemeMode.system.obs;
  final _storage = GetStorage();
  static const String _themeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  void changeTheme(ThemeMode mode) {
    selectedTheme.value = mode;
    Get.changeThemeMode(mode);
    _saveThemePreference(mode);
  }

  void _saveThemePreference(ThemeMode mode) {
    try {
      _storage.write(_themeKey, mode.index);
    } catch (e) {
      Logger.error('Erro ao salvar preferência de tema: $e', error: e);
    }
  }

  void _loadThemePreference() {
    try {
      final themeIndex = _storage.read(_themeKey);
      
      if (themeIndex != null) {
        final savedTheme = ThemeMode.values[themeIndex];
        selectedTheme.value = savedTheme;
        Get.changeThemeMode(savedTheme);
      } else {
        selectedTheme.value = ThemeMode.system;
        Get.changeThemeMode(ThemeMode.system);
      }
    } catch (e) {
      Logger.error('Erro ao carregar preferência de tema: $e', error: e);
      selectedTheme.value = ThemeMode.system;
    }
  }
}