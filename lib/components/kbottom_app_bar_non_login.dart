// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
//
//
//
//
//
//
//
//
// class KnlBottomAppBar extends StatefulWidget {
//   const KnlBottomAppBar({super.key});
//
//   @override
//   _KnlBottomAppBarState createState() => _KnlBottomAppBarState();
// }
//
// class _KnlBottomAppBarState extends State<KnlBottomAppBar> {
//   int _currentIndex = 0;
//   final _navBarItems =[
//     SalomonBottomBarItem(
//       icon: const Icon(Ionicons.home_outline),
//       title: const Text("Home"),
//       selectedColor: Colors.deepPurple[400],
//     )
//     ,SalomonBottomBarItem(
//         icon: const Icon(Ionicons.storefront_sharp),
//         title: const Text("Room"),
//         selectedColor: Colors.pinkAccent[400]
//     )
//
//   ];
//   final _pages = [
//     // home page
//     HomePage(),
//     // profile page
//     // Room2(),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   backgroundColor: Colors.white,
//       //   elevation: 0,
//       //   systemOverlayStyle: SystemUiOverlayStyle(
//       //     statusBarBrightness: Brightness.light,
//       //   ),
//       //   leading: IconButton(
//       //       onPressed: () {
//       //         Get.back();
//       //       },
//       //       icon: Icon(Ionicons.chevron_back_outline)),
//       //   leadingWidth: 80,
//       // ),
//       body: _pages[_currentIndex],
//       bottomNavigationBar: SalomonBottomBar(
//         backgroundColor: Colors.white,
//         currentIndex: _currentIndex,
//         items: _navBarItems,
//         selectedItemColor: const Color(0xff6200ee),
//         unselectedItemColor: const Color(0xff757575),
//         onTap: (index){
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//
//       ),
//     );
//   }
// }
