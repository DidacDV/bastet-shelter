import 'package:flutter/material.dart';

class AdoptionToggle extends StatefulWidget {
  final bool inAdoption;
  final Future<void> Function() onToggle;

  const AdoptionToggle({
    super.key,
    required this.inAdoption,
    required this.onToggle,
  });

  @override
  State<AdoptionToggle> createState() => AdoptionToggleState();
}

class AdoptionToggleState extends State<AdoptionToggle> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Switch(
            value: widget.inAdoption,
            onChanged: (_) async {
              setState(() => _loading = true);
              await widget.onToggle();
              if (mounted) setState(() => _loading = false);
            },
          );
  }
}
