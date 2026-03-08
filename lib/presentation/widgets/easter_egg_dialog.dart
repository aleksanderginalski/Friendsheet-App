import 'package:flutter/material.dart';

/// Dialog shown when the hidden easter egg is triggered.
/// Tapping anywhere on the dialog dismisses it.
///
/// [imageWidget] overrides the default Image.asset for testing purposes.
class EasterEggDialog extends StatelessWidget {
  const EasterEggDialog({super.key, this.imageWidget});

  /// Optional override for the icon image. Defaults to the easter egg asset.
  final Widget? imageWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget ??
                  Image.asset(
                    'assets/images/easter_egg_icon.png',
                    height: 120,
                  ),
              const SizedBox(height: 16),
              const Text(
                'Special thanks to Agatka who came up with the name for this app 💚',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
