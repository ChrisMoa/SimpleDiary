import 'package:flutter/material.dart';

import '../provider/keyboard_visibility_notifier.dart';

class KeyboardVisibilityListener extends StatefulWidget {
  final Widget Function(BuildContext context, bool isKeyboardVisible) builder;

  const KeyboardVisibilityListener({
    super.key,
    required this.builder,
  });

  @override
  // ignore: library_private_types_in_public_api
  _KeyboardVisibilityListenerState createState() =>
      _KeyboardVisibilityListenerState();
}

class _KeyboardVisibilityListenerState
    extends State<KeyboardVisibilityListener> {
  late final KeyboardVisibilityNotifier _keyboardVisibilityNotifier;

  @override
  void initState() {
    super.initState();
    _keyboardVisibilityNotifier = KeyboardVisibilityNotifier();
  }

  @override
  void dispose() {
    _keyboardVisibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _keyboardVisibilityNotifier,
      builder: (context, isKeyboardVisible, child) {
        return widget.builder(context, isKeyboardVisible);
      },
    );
  }
}
