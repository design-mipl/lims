import 'package:flutter/material.dart';

/// Opacity pulse matching the listing engine skeleton (0.35 ↔ 0.65, 900ms).
class TemplatePulse extends StatefulWidget {
  const TemplatePulse({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TemplatePulse> createState() => _TemplatePulseState();
}

class _TemplatePulseState extends State<TemplatePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
