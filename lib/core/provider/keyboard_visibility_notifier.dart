import 'package:flutter/material.dart';

class KeyboardVisibilityNotifier extends ValueNotifier<bool>
    with WidgetsBindingObserver {
  KeyboardVisibilityNotifier() : super(false) {
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardVisibility();
  }

  void _checkKeyboardVisibility() {
    final mediaQuery = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = mediaQuery > 0;

    if (value != isKeyboardVisible) {
      value = isKeyboardVisible;
    }
  }

  @override
  void didChangeMetrics() {
    _checkKeyboardVisibility();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
