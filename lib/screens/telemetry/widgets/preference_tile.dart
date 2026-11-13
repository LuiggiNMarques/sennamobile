import 'package:flutter/material.dart';

/// Reusable preference/settings tile with toggle or chevron.
class PreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;
  final bool isLink;
  final IconData? leadingIcon;

  const PreferenceTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
    this.isLink = false,
    this.leadingIcon,
  });

  static const _cardBg = Color(0xFF121830);
  static const _cyan = Color(0xFF00E5FF);
  static const _pink = Color(0xFFFF006E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? (isLink ? () {} : null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _cyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  leadingIcon,
                  color: _cyan,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Toggle or chevron
            if (isLink)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.3),
                size: 16,
              )
            else if (toggleValue != null)
              SizedBox(
                height: 28,
                child: Switch(
                  value: toggleValue!,
                  onChanged: onToggleChanged,
                  activeColor: _cyan,
                  activeTrackColor: _cyan.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
