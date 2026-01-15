import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final int pinLength;
  final bool obscureText;

  const PinInputWidget({
    super.key,
    required this.onCompleted,
    this.pinLength = 6,
    this.obscureText = true,
  });

  @override
  State<PinInputWidget> createState() => PinInputWidgetState();
}

class PinInputWidgetState extends State<PinInputWidget>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers and focus nodes
    for (int i = 0; i < widget.pinLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    // Shake animation for error
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      // Move to next field
      if (index < widget.pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit, unfocus and trigger completion
        _focusNodes[index].unfocus();
        _checkCompletion();
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace if current is empty
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _checkCompletion() {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length == widget.pinLength) {
      widget.onCompleted(pin);
    }
  }

  void shake() {
    _shakeController.forward(from: 0);
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.pinLength, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildPinBox(index),
          );
        }),
      ),
    );
  }

  Widget _buildPinBox(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: widget.obscureText,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasValue
                  ? const Color(0xFF5B9BD5).withAlpha(128)
                  : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF5B9BD5),
              width: 2,
            ),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _onChanged(value, index),
      ),
    );
  }
}
