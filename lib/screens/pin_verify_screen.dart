import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../widgets/pin_input_widget.dart';
import '../widgets/custom/custom_notification.dart';
import 'home_screen.dart';

class PinVerifyScreen extends StatefulWidget {
  const PinVerifyScreen({super.key});

  @override
  State<PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends State<PinVerifyScreen> {
  final PinService _pinService = PinService();
  final GlobalKey<PinInputWidgetState> _pinInputKey = GlobalKey();

  bool _isLoading = false;
  int _remainingAttempts = 3;
  bool _isLocked = false;
  int _lockMinutes = 0;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
    _loadRemainingAttempts();
  }

  Future<void> _checkLockStatus() async {
    final isLocked = await _pinService.isLocked();
    if (isLocked) {
      final minutes = await _pinService.getRemainingLockTime();
      setState(() {
        _isLocked = true;
        _lockMinutes = minutes;
      });
    }
  }

  Future<void> _loadRemainingAttempts() async {
    final attempts = await _pinService.getRemainingAttempts();
    setState(() {
      _remainingAttempts = attempts;
    });
  }

  void _onPinCompleted(String pin) async {
    if (_isLoading || _isLocked) return;

    setState(() => _isLoading = true);

    final isCorrect = await _pinService.verifyPin(pin);

    if (isCorrect && mounted) {
      CustomNotification.show(
        context,
        message: 'PIN benar',
        type: NotificationType.success,
      );

      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      setState(() => _isLoading = false);

      // Check if locked
      final isLocked = await _pinService.isLocked();
      if (isLocked) {
        final minutes = await _pinService.getRemainingLockTime();
        setState(() {
          _isLocked = true;
          _lockMinutes = minutes;
        });

        CustomNotification.show(
          context,
          message:
              'Terlalu banyak percobaan salah. Coba lagi dalam $minutes menit',
          type: NotificationType.error,
          duration: const Duration(seconds: 5),
        );
      } else {
        // Update remaining attempts
        await _loadRemainingAttempts();

        _pinInputKey.currentState?.shake();
        _pinInputKey.currentState?.clear();

        CustomNotification.show(
          context,
          message: 'PIN salah. Sisa percobaan: $_remainingAttempts',
          type: NotificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9BD5).withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: Color(0xFF5B9BD5),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Masukkan PIN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  _isLocked
                      ? 'Aplikasi terkunci. Coba lagi dalam $_lockMinutes menit'
                      : 'Masukkan PIN untuk membuka aplikasi',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isLocked ? Colors.red : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // PIN Input
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_isLocked)
                  Icon(
                    Icons.lock_clock,
                    size: 80,
                    color: Colors.red[300],
                  )
                else
                  PinInputWidget(
                    key: _pinInputKey,
                    onCompleted: _onPinCompleted,
                  ),

                const SizedBox(height: 20),

                // Remaining attempts
                if (!_isLocked && _remainingAttempts < 3)
                  Text(
                    'Sisa percobaan: $_remainingAttempts',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const Spacer(),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9BD5).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        color: Color(0xFF5B9BD5),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Data Anda dilindungi dengan enkripsi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
