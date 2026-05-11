import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.style,
    this.onFieldSubmitted,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: style,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: obscure ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction:
          textInputAction ??
          (onFieldSubmitted != null ? TextInputAction.done : null),
    );
  }
}
