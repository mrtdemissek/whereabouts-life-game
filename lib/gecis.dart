import 'package:flutter/material.dart';

// Ekranlar arası yumuşak geçiş: belirme ve hafif yukarı süzülme
Route<T> yumusakGecis<T>(Widget sayfa) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondary) => sayfa,
    transitionsBuilder: (context, animation, secondary, child) {
      final egri = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: egri,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(egri),
          child: child,
        ),
      );
    },
  );
}