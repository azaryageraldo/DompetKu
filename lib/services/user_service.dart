import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _nameKey = 'user_name';
  static const String _imagePathKey = 'user_image_path';

  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_nameKey);
  }

  Future<void> saveProfile(String name, String? imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    if (imagePath != null) {
      await prefs.setString(_imagePathKey, imagePath);
    } else {
      await prefs.remove(_imagePathKey);
    }
  }

  Future<Map<String, String?>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    final imagePath = prefs.getString(_imagePathKey);
    return {
      'name': name,
      'image_path': imagePath,
    };
  }
}
