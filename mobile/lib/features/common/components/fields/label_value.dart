import 'package:flutter/material.dart';

class LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final double? spacing;

  const LabelValue({
    super.key,
    required this.label,
    required this.value,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(width: spacing ?? 2),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
