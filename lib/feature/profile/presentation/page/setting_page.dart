import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';

import '../../../../common/constant/colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../welcome_page/welcome_page.dart';
import '../widgets/forward_button.dart';
import '../widgets/setting_switch.dart';
import '../widgets/setting_items.dart';
import '../../../contract/presentation/page/contract_page.dart';
import 'edit_profile.dart';
import 'change_password.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isDarkMode = false;
  bool _hasNetworkImageError = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Glassmorphism Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is LoggedOut) {
                  Get.to(() => const WelcomePage());
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final user = state is UserProfileLoaded ? state.user : null;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AuthBloc>().add(const GetUserProfileEvent());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cardBackground,
                            shadows: const [Shadow(color: AppColors.shadowColor, blurRadius: 4)],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.cardBackground,
                            shadows: const [Shadow(color: AppColors.shadowColor, blurRadius: 4)],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: user?.avatarUrl != null && !_hasNetworkImageError
                                    ? NetworkImage(user!.avatarUrl!)
                                    : null,
                                onBackgroundImageError: user?.avatarUrl != null && !_hasNetworkImageError
                                    ? (exception, stackTrace) {
                                        debugPrint("Failed to load avatar in SettingPage: $exception");
                                        if (mounted) {
                                          setState(() {
                                            _hasNetworkImageError = true;
                                          });
                                        }
                                      }
                                    : null,
                                child: _hasNetworkImageError || user?.avatarUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.textSecondary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullname ?? "Fullname",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ForwardButton(
                                onTap: () {
                                  Get.to(() => const EditProfileScreen());
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.cardBackground,
                            shadows: const [Shadow(color: AppColors.shadowColor, blurRadius: 4)],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSettingItem(
                          title: 'Change Password',
                          iconColor: AppColors.buttonPrimary,
                          icon: Ionicons.lock_closed,
                          onTap: () {
                            Get.to(() => const ChangePasswordScreen());
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildSettingItem(
                          title: 'View Contracts',
                          iconColor: Colors.teal,
                          icon: Ionicons.document_text,
                          onTap: () {
                            Get.to(() => const ContractPage());
                          },
                        ),
                        // const SizedBox(height: 20),
                        // _buildSettingItem(
                        //   title: 'Help',
                        //   iconColor: AppColors.buttonError,
                        //   icon: Ionicons.help,
                        //   onTap: () {},
                        // ),
                        const SizedBox(height: 20),
                        _buildSettingItem(
                          title: 'Logout',
                          iconColor: AppColors.textPrimary,
                          icon: Ionicons.log_out,
                          onTap: () {
                            context.read<AuthBloc>().add(const LogoutEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required Color iconColor,
    required IconData icon,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required Color iconColor,
    required IconData icon,
    required bool value,
    required Function(bool) onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
          Switch(
            value: value,
            onChanged: onTap,
            activeColor: AppColors.buttonPrimary,
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.textSecondary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}