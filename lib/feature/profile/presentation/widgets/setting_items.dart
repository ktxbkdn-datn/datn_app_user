import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/utils/responsive_widget_extension.dart';

// Safe onTap helper to prevent multiple clicks
void safeOnTap(BuildContext context, VoidCallback callback) {
  try {
    if (context.mounted) {
      callback();
    }
  } catch (e) {
    debugPrint('Error in safeOnTap: $e');
  }
}

class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? value;
  final VoidCallback onTap;

  const SettingsCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.value,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => safeOnTap(context, onTap),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            margin: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.hp(context, 0.7), 
              horizontal: 0
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.80),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.wp(context, 4.5), 
                vertical: ResponsiveUtils.hp(context, 1.8)
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.wp(context, 2)),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: ResponsiveUtils.sp(context, 26)),
                  ),
                  SizedBox(width: ResponsiveUtils.wp(context, 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.sp(context, 16),
                            color: Color(0xFF222B45),
                          ),
                        ),
                        if (value != null && value!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: ResponsiveUtils.hp(context, 0.3)),
                            child: Text(
                              value!,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.sp(context, 13),
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFFB0B7C3), size: ResponsiveUtils.sp(context, 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


