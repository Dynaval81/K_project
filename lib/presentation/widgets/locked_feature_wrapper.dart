import 'dart:ui';
import 'package:flutter/material.dart';

/// Универсальная обёртка для заблокированного функционала.
/// Показывает размытый [child] с замком поверх если [isLocked] == true.
///
/// Использование:
/// ```dart
/// LockedFeatureWrapper(
///   isLocked: !user.isSchoolVerified,
///   title: 'Schulchats gesperrt',
///   subtitle: 'Warte auf die Freigabe durch deinen Schuladministrator.',
///   child: MyFeatureScreen(),
/// )
/// ```
class LockedFeatureWrapper extends StatelessWidget {
  final bool isLocked;
  final Widget child;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const LockedFeatureWrapper({
    super.key,
    required this.isLocked,
    required this.child,
    this.title = 'Gesperrt',
    this.subtitle = 'Warte auf die Freigabe durch deinen Administrator.',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    return Stack(
      children: [
        // Заблюренный контент за замком
        IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: child,
          ),
        ),

        // Полупрозрачный белый оверлей
        Positioned.fill(
          child: Container(color: Colors.white.withOpacity(0.55)),
        ),

        // Замок + текст
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Иконка замка
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 34,
                    color: Color(0xFFE6B800),
                  ),
                ),
                const SizedBox(height: 20),

                // Заголовок
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),

                // Подзаголовок
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                    height: 1.5,
                  ),
                ),

                // Опциональная кнопка действия
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6B800),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
