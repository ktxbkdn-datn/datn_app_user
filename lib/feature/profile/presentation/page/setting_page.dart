import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart' as get_transitions;
import 'package:ionicons/ionicons.dart';

import '../../../../common/components/app_background.dart';
import '../../../../common/constant/colors.dart';
import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/utils/responsive_widget_extension.dart';
import '../../../../common/widgets/responsive_scaffold.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../welcome_page/welcome_page.dart';
import '../../../contract/presentation/page/contract_page.dart';
import '../widgets/setting_items.dart';
import '../widgets/edit_item.dart';
import 'edit_profile.dart';
import 'change_password.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void _refreshUserProfile() {
    if (mounted) {
      context.read<AuthBloc>().add(const GetUserProfileEvent());
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Stack(
        children: [
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is LoggedOut || state is TokenMissingError) {
                Get.offAll(
                  () => LoginPage(),
                  transition: get_transitions.Transition.fadeIn,
                  duration: const Duration(milliseconds: 400),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.wp(context, 6), 
                          vertical: ResponsiveUtils.hp(context, 2)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: ResponsiveUtils.wp(context, 6),
                              height: ResponsiveUtils.wp(context, 6),
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.blue),
                            ),
                            SizedBox(width: ResponsiveUtils.wp(context, 4)),
                            Text(
                              'Đang tải...', 
                              style: TextStyle(fontSize: ResponsiveUtils.sp(context, 16))
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              final user = state is UserProfileLoaded ? state.user : null;

              return RefreshIndicator(
                onRefresh: () async {
                  _refreshUserProfile();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.wp(context, 4), 
                    vertical: ResponsiveUtils.hp(context, 4)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Card(
                        color: Colors.white.withOpacity(0.7),
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.wp(context, 5), 
                            vertical: ResponsiveUtils.hp(context, 2)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cài đặt',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.sp(context, 24),
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh, color: Color(0xFF6366F1), size: ResponsiveUtils.sp(context, 24)),
                                onPressed: () {
                                  _refreshUserProfile();
                                },
                                tooltip: 'Làm mới',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.hp(context, 3)),
                      // Account Section
                      Text(
                        'Tài khoản',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.sp(context, 20),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.hp(context, 1.5)),
                      // Profile Card
                      ProfileCard(
                        avatarUrl: user?.avatarUrl,
                        fullname: user?.fullname,
                        email: user?.email,
                        onTap: () {
                          Get.to(
                            () => const EditProfileScreen(),
                            duration: const Duration(milliseconds: 300),
                          )?.then((_) {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (mounted) {
                                _refreshUserProfile();
                              }
                            });
                          });
                        },
                      ),
                      SizedBox(height: ResponsiveUtils.hp(context, 4)),
                      // Settings Section
                      Text(
                        'Cài đặt',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.sp(context, 20),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.hp(context, 1.5)),
                      // Settings Cards
                      Column(
                        children: [
                          SettingsCard(
                            title: 'Đổi mật khẩu',
                            icon: Ionicons.lock_closed,
                            iconColor: const Color(0xFF3b82f6),
                            onTap: () {
                              // Navigate to change password page with increased delay for animation
                              Get.to(
                                () => const ChangePasswordScreen(),
                                transition: get_transitions.Transition.cupertino,
                                duration: const Duration(milliseconds: 300),
                              )?.then((_) {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  if (mounted) {
                                    _refreshUserProfile();
                                  }
                                });
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          SettingsCard(
                            title: 'Xem hợp đồng',
                            icon: Ionicons.document_text,
                            iconColor: const Color(0xFF14b8a6),
                            onTap: () {
                              // Navigate to contract page with increased delay for animation
                              Get.to(
                                () => const ContractPage(),
                                transition: get_transitions.Transition.cupertino,
                                duration: const Duration(milliseconds: 300),
                              )?.then((_) {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  if (mounted) {
                                    _refreshUserProfile();
                                  }
                                });
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          SettingsCard(
                            title: 'Đăng xuất',
                            icon: Ionicons.log_out,
                            iconColor: const Color(0xFFef4444),
                            onTap: () {
                              // Always navigate to LoginPage on tap
                              context.read<AuthBloc>().add(const LogoutEvent());
                              Get.offAll(
                                () => LoginPage(),            
                                duration: const Duration(milliseconds: 400),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}