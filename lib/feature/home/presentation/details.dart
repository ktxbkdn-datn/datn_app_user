// import 'package:flutter/material.dart';
// import 'dart:ui'; // For BackdropFilter
// import 'homepage.dart';
//
// class ArticleDetailScreen extends StatelessWidget {
//   final Article article;
//
//   const ArticleDetailScreen({super.key, required this.article});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Glassmorphism Background
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.shade200, Colors.pink.shade200],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // AppBar-like Header
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.arrow_back, color: Colors.white),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         Expanded(
//                           child: Text(
//                             "Article Details",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Article Image
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         article.imageUrl,
//                         width: double.infinity,
//                         height: 250,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: double.infinity,
//                             height: 250,
//                             color: Colors.grey.shade300,
//                             child: Icon(Icons.image, color: Colors.grey),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   // Article Content
//                   Container(
//                     margin: const EdgeInsets.all(16.0),
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           article.title,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           article.date,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           article.description,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.black87,
//                             height: 1.5,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.black87,
//                             height: 1.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }