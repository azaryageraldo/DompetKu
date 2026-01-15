import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinService {
  static const String _pinKey = 'user_pin';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _attemptCountKey = 'pin_attempt_count';
  static const String _lockTimeKey = 'pin_lock_time';

  static const int maxAttempts = 3;
  static const int lockDurationMinutes = 5;

  // Hash PIN dengan SHA256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Simpan PIN
  Future<bool> savePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hashedPin = _hashPin(pin);
      await prefs.setString(_pinKey, hashedPin);
      await prefs.setBool(_pinEnabledKey, true);
      await prefs.setInt(_attemptCountKey, 0);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cek apakah PIN sudah diset
  Future<bool> hasPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pin = prefs.getString(_pinKey);
      final enabled = prefs.getBool(_pinEnabledKey) ?? false;
      return pin != null && enabled;
    } catch (e) {
      return false;
    }
  }

  // Verifikasi PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cek apakah sedang di-lock
      if (await isLocked()) {
        return false;
      }

      final savedPin = prefs.getString(_pinKey);
      if (savedPin == null) return false;

      final hashedPin = _hashPin(pin);
      final isCorrect = hashedPin == savedPin;

      if (isCorrect) {
        // Reset attempt count jika benar
        await prefs.setInt(_attemptCountKey, 0);
        return true;
      } else {
        // Increment attempt count jika salah
        final attempts = prefs.getInt(_attemptCountKey) ?? 0;
        await prefs.setInt(_attemptCountKey, attempts + 1);

        // Lock jika sudah max attempts
        if (attempts + 1 >= maxAttempts) {
          await _lockApp();
        }

        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Dapatkan jumlah percobaan yang tersisa
  Future<int> getRemainingAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = prefs.getInt(_attemptCountKey) ?? 0;
      return maxAttempts - attempts;
    } catch (e) {
      return maxAttempts;
    }
  }

  // Lock aplikasi
  Future<void> _lockApp() async {
    final prefs = await SharedPreferences.getInstance();
    final lockTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lockTimeKey, lockTime);
  }

  // Cek apakah aplikasi sedang di-lock
  Future<bool> isLocked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockTime = prefs.getInt(_lockTimeKey);

      if (lockTime == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - lockTime;
      final diffMinutes = diff / (1000 * 60);

      if (diffMinutes >= lockDurationMinutes) {
        // Unlock jika sudah lewat durasi lock
        await prefs.remove(_lockTimeKey);
        await prefs.setInt(_attemptCountKey, 0);
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Dapatkan waktu tersisa lock (dalam menit)
  Future<int> getRemainingLockTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockTime = prefs.getInt(_lockTimeKey);

      if (lockTime == null) return 0;

      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - lockTime;
      final diffMinutes = diff / (1000 * 60);
      final remaining = lockDurationMinutes - diffMinutes.ceil();

      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }

  // Hapus PIN
  Future<bool> deletePin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinKey);
      await prefs.remove(_pinEnabledKey);
      await prefs.remove(_attemptCountKey);
      await prefs.remove(_lockTimeKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle PIN on/off
  Future<bool> togglePin(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pinEnabledKey, enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cek apakah PIN enabled
  Future<bool> isPinEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pinEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }
}
