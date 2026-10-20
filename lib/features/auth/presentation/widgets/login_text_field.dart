import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.fillColor,
    required this.borderColor,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Color fillColor;
  final Color borderColor;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          autofillHints: autofillHints,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
            suffixIcon: suffix,
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: _border(borderColor),
            enabledBorder: _border(borderColor),
            focusedBorder: _border(AppColors.primaryButton, 1.5),
            errorBorder: _border(AppColors.bahaya),
            focusedErrorBorder: _border(AppColors.bahaya, 1.5),
          ),
        ),
      ],
    );
  }
}
