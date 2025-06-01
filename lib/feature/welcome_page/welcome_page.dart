import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/custom_materialbutton.dart';
import '../../feature/auth/presentation/pages/login_page.dart';
import '../room/presentations/pages/view_room.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: Image.asset(
                  "assets/logo/image002.jpg",
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Column(
                children: <Widget>[
                  Text(
                    "Chào mừng bạn đến với",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ký túc xá Bách Khoa",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Chọn một trong hai lựa chọn bên dưới để tiếp tục",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: <Widget>[
                  MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () {
                      Get.to(() => const LoginPage());
                    },
                    height: 60,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "Đã có tài khoản",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 3,),
                    child: KtxButton(
                      onTap: () {
                        Get.to(() => const ViewRoom(showBackButton: true)); // Pass showBackButton: true
                      },
                      buttonColor: Colors.yellowAccent.shade100,
                      nameButton: 'Chưa có tài khoản',
                      textColor: Colors.black,
                      borderSideColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}