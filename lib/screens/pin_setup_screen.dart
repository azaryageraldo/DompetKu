import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../widgets/pin_input_widget.dart';
import '../widgets/custom/custom_notification.dart';
import 'home_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final PinService _pinService = PinService();
  final GlobalKey<PinInputWidgetState> _pinInputKey = GlobalKey();

  String? _firstPin;
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onPinCompleted(String pin) async {
    if (_isLoading) return;

    if (!_isConfirming) {
      // First PIN entry
      setState(() {
        _firstPin = pin;
        _isConfirming = true;
      });

      // Clear input for confirmation
      Future.delayed(const Duration(milliseconds: 300), () {
        _pinInputKey.currentState?.clear();
      });
    } else {
      // Confirmation PIN entry
      if (pin == _firstPin) {
        // PIN match, save it
        setState(() => _isLoading = true);

        final success = await _pinService.savePin(pin);

        if (success && mounted) {
          CustomNotification.show(
            context,
            message: 'PIN berhasil dibuat',
            type: NotificationType.success,
          );

          // Navigate to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (mounted) {
          setState(() => _isLoading = false);
          CustomNotification.show(
            context,
            message: 'Gagal menyimpan PIN',
            type: NotificationType.error,
          );
        }
      } else {
        // PIN tidak match
        _pinInputKey.currentState?.shake();
        _pinInputKey.currentState?.clear();

        CustomNotification.show(
          context,
          message: 'PIN tidak cocok, coba lagi',
          type: NotificationType.error,
        );

        setState(() {
          _firstPin = null;
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Buat PIN'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

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
              Text(
                _isConfirming ? 'Konfirmasi PIN' : 'Buat PIN Baru',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                _isConfirming
                    ? 'Masukkan PIN sekali lagi'
                    : 'Buat PIN 6 digit untuk keamanan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // PIN Input
              if (_isLoading)
                const CircularProgressIndicator()
              else
                PinInputWidget(
                  key: _pinInputKey,
                  onCompleted: _onPinCompleted,
                ),

              const SizedBox(height: 40),

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
                      Icons.info_outline,
                      color: Color(0xFF5B9BD5),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PIN akan digunakan untuk mengamankan aplikasi Anda',
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
    );
  }
}
