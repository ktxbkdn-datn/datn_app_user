import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/utils/responsive_widget_extension.dart';
import '../widgets/setting_items.dart' show safeOnTap;

class EditItem extends StatelessWidget {
  final Widget widget;
  final String title;
  final Function() onPressed;
  final bool changeIcon, canEdit;

  const EditItem({
    super.key,
    required this.widget,
    required this.title,
    required this.onPressed,
    this.changeIcon = true,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.sp(context, 18), 
                color: Colors.grey
              ),
            )),
        SizedBox(width: ResponsiveUtils.wp(context, 10)),
        Expanded(
          flex: 4,
          child: widget,
        ),
        canEdit
            ? Expanded(
          child: IconButton(
            onPressed: () {
              onPressed();
            },
            icon: Icon(
              changeIcon ? Ionicons.checkmark : Ionicons.pencil,
              size: ResponsiveUtils.sp(context, 22),
            ),
          ),
        )
            : SizedBox(width: ResponsiveUtils.wp(context, 7.5)),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String? avatarUrl;
  final String? fullname;
  final String? email;
  final VoidCallback onTap;

  const ProfileCard({
    Key? key,
    required this.avatarUrl,
    required this.fullname,
    required this.email,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => safeOnTap(context, onTap),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            margin: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.hp(context, 1), 
              horizontal: 0
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.80),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.wp(context, 5), 
                vertical: ResponsiveUtils.hp(context, 2.2)
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: ResponsiveUtils.wp(context, 16),
                    height: ResponsiveUtils.wp(context, 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: ResponsiveUtils.wp(context, 8),
                      backgroundColor: Colors.transparent,
                      /* Comment lại phần tải NetworkImage để tránh lỗi 404
                      backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                          ? NetworkImage(avatarUrl!)
                          : null,
                      */
                      // Luôn hiển thị icon người mặc định
                      child: Icon(Icons.person, size: ResponsiveUtils.sp(context, 36), color: Colors.white),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.wp(context, 4.5)),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullname ?? "Fullname",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: ResponsiveUtils.sp(context, 20),
                            color: Color(0xFF222B45),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.hp(context, 0.5)),
                        Text(
                          email ?? "",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.sp(context, 15),
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  Icon(Icons.chevron_right, color: Color(0xFFB0B7C3), size: ResponsiveUtils.sp(context, 28)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
