import 'package:flutter/material.dart';

import '../../data/services/connectivity_service.dart';

/// Displays an amber banner at the top of the screen when the device is offline.
/// Listens to [ConnectivityService.isOnlineNotifier] and animates in/out.
class OfflineBannerWidget extends StatelessWidget {
  const OfflineBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService().isOnlineNotifier,
      builder: (context, isOnline, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isOnline
              ? const SizedBox.shrink(key: ValueKey('online'))
              : Container(
                  key: const ValueKey('offline'),
                  width: double.infinity,
                  color: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'No internet connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
