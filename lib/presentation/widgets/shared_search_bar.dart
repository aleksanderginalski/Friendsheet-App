import 'package:flutter/material.dart';

// Reusable search bar used across Activities, Meetings, and Friends screens.
// When [controller] is provided, a clear button appears while text is non-empty.
// Padding (16, 12, 16, 4) is included so callers do not need to wrap in Padding.
class SharedSearchBar extends StatelessWidget {
  const SharedSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Search...',
    this.controller,
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final fillColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget? suffixIcon;
    if (controller != null) {
      suffixIcon = ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller!,
        builder: (_, value, __) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller!.clear();
              onChanged('');
            },
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: fillColor,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
