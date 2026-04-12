import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/constants.dart';

/// Usage:
///   ShelterSearchBar(
///     onChanged: (q) => ref.read(animalFilterProvider.notifier).updateQuery(q),
///   )
class BastetSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final int debounceMs;

  const BastetSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Search…',
    this.debounceMs = 100,
  });

  @override
  State<BastetSearchBar> createState() => _BastetSearchBarState();
}

class _BastetSearchBarState extends State<BastetSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onChanged(value);
    });
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textHint,
          size: 20,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textHint,
                onPressed: _clear,
              )
            : null,
      ),
    );
  }
}
