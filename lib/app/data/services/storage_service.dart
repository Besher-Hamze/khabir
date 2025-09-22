import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  static StorageService get instance => Get.find<StorageService>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initStorage();
  }

  Future<void> _initStorage() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.keyToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(AppConstants.keyToken);
  }

  bool get hasToken => getToken() != null;

  // User management
  Future<void> saveUser(User user) async {
    await _prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
  }

  User? getUser() {
    final userString = _prefs.getString(AppConstants.keyUser);
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs.remove(AppConstants.keyUser);
  }

  bool get hasUser => getUser() != null;

  // Language management
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(AppConstants.keyLanguage, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.keyLanguage) ?? 'ar';
  }

  // Onboarding
  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(AppConstants.keyOnboarding, true);
  }

  bool get isOnboardingCompleted =>
      _prefs.getBool(AppConstants.keyOnboarding) ?? false;

  // Theme
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.keyTheme, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.keyTheme) ?? 'system';
  }

  // Addresses
  Future<void> saveAddresses(List<Map<String, dynamic>> addresses) async {
    await _prefs.setString(AppConstants.keyAddresses, jsonEncode(addresses));
  }

  List<Map<String, dynamic>> getAddresses() {
    final addressesString = _prefs.getString(AppConstants.keyAddresses);
    if (addressesString != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(addressesString));
    }
    return [];
  }

  // Location
  Future<void> saveLocation(double latitude, double longitude) async {
    await _prefs.setString(
      AppConstants.keyLocation,
      jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );
  }

  Map<String, double>? getLocation() {
    final locationString = _prefs.getString(AppConstants.keyLocation);
    if (locationString != null) {
      final location = jsonDecode(locationString);
      return {
        'latitude': location['latitude'].toDouble(),
        'longitude': location['longitude'].toDouble(),
      };
    }
    return null;
  }

  // Generic methods
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
