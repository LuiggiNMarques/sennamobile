import 'package:flutter/material.dart';

/// Reusable BLE device list item card.
class DeviceCard extends StatelessWidget {
  final String deviceName;
  final String? macAddress;
  final String? info;
  final String? statusText;
  final Color statusColor;
  final String? deviceType;
  final VoidCallback? onTap;
  final bool isConnected;

  const DeviceCard({
    super.key,
    required this.deviceName,
    this.macAddress,
    this.info,
    this.statusText,
    this.statusColor = const Color(0xFF00FF85),
    this.deviceType,
    this.onTap,
    this.isConnected = false,
  });

  static const _cardBg = Color(0xFF121830);
  static const _cyan = Color(0xFF00E5FF);
  static const _green = Color(0xFF00FF85);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? _green.withValues(alpha: 0.3)
                : _cyan.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: isConnected
              ? [
                  BoxShadow(
                    color: _green.withValues(alpha: 0.06),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

            // Device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deviceName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (statusText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.4),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            statusText!,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (macAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      macAddress!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontFamily: 'monospace',
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],

                  if (info != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      info!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  if (deviceType != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _cyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _cyan.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        deviceType!,
                        style: TextStyle(
                          color: _cyan.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
