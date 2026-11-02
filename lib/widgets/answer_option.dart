import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCorrectness;
  final bool isCorrectAnswer;

  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.showCorrectness = false,
    this.isCorrectAnswer = false,
  });

  String get _optionLetter => String.fromCharCode(65 + index); // A, B, C, D

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppTheme.borderColor;
    Color backgroundColor = Colors.white;
    Color badgeColor = const Color(0xFFF1F5F9);
    Color badgeTextColor = AppTheme.textSecondary;
    Widget? trailingIcon;

    if (showCorrectness) {
      if (isCorrectAnswer) {
        borderColor = AppTheme.successColor;
        backgroundColor = AppTheme.successColor.withValues(alpha: 0.08);
        badgeColor = AppTheme.successColor;
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.check_circle,
          color: AppTheme.successColor,
          size: 22,
        );
      } else if (isSelected && !isCorrectAnswer) {
        borderColor = AppTheme.errorColor;
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.08);
        badgeColor = AppTheme.errorColor;
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.cancel,
          color: AppTheme.errorColor,
          size: 22,
        );
      }
    } else if (isSelected) {
      borderColor = AppTheme.primaryColor;
      backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.06);
      badgeColor = AppTheme.primaryColor;
      badgeTextColor = Colors.white;
      trailingIcon = const Icon(
        Icons.check_circle,
        color: AppTheme.primaryColor,
        size: 22,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: isSelected || (showCorrectness && isCorrectAnswer) ? 2.0 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _optionLetter,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
