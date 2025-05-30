// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart' hide Notification;
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'dart:ui'; // For BackdropFilter
//
// import '../../../feature/notification/presentation/bloc/notification_bloc.dart';
// import '../../../feature/notification/presentation/page/notification_detail_screen.dart';
// import '../../notification/domain/entity/notification_entity.dart';
// import '../../notification/presentation/bloc/notification_event.dart';
// import '../../notification/presentation/bloc/notification_state.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
//   bool _isInitialLoad = true;
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<NotificationBloc>().add(const FetchUserNotificationsEvent(page: 1, limit: 50));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
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
//             child: Center(
//               child: BlocConsumer<NotificationBloc, NotificationState>(
//                 listener: (context, state) {
//                   if (state is NotificationError) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error: ${state.message}')),
//                     );
//                   }
//                 },
//                 builder: (context, state) {
//                   if (state is NotificationLoading && _isInitialLoad) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   // Get screen width and height for responsive design
//                   final screenWidth = MediaQuery.of(context).size.width;
//                   final screenHeight = MediaQuery.of(context).size.height;
//
//                   // Define maximum width for content (to prevent stretching on web)
//                   const maxContentWidth = 600.0;
//                   final contentWidth = screenWidth > maxContentWidth ? maxContentWidth : screenWidth;
//
//                   // Adjust padding based on platform
//                   final horizontalPadding = screenWidth > maxContentWidth ? 16.0 : 16.0;
//
//                   // Adjust media height based on screen width to maintain aspect ratio
//                   final mediaHeight = screenWidth > maxContentWidth ? contentWidth * 0.5 : screenHeight * 0.3;
//
//                   List<Notification> notifications = [];
//                   if (state is UserNotificationsLoaded) {
//                     notifications = state.notifications;
//                     _isInitialLoad = false;
//                   }
//
//                   if (notifications.isEmpty) {
//                     return const Center(child: Text('No notifications found'));
//                   }
//
//                   return ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: maxContentWidth),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header
//                         Padding(
//                           padding: EdgeInsets.all(horizontalPadding),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Home Feed",
//                                 style: TextStyle(
//                                   fontSize: kIsWeb ? 20 : 32,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.refresh, color: Colors.white, size: 36),
//                                 onPressed: () {
//                                   context.read<NotificationBloc>().add(const FetchUserNotificationsEvent(page: 1, limit: 50));
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Feed List
//                         Expanded(
//                           child: ListView.builder(
//                             padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
//                             itemCount: notifications.length,
//                             itemBuilder: (context, index) {
//                               final notification = notifications[index];
//                               final mediaUrls = notification.media?.map((media) => media.mediaUrl).toList() ?? [];
//                               return GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => NotificationDetailScreen(
//                                         title: notification.title,
//                                         message: notification.message,
//                                         mediaUrls: mediaUrls,
//                                         timestamp: notification.createdAt ?? '',
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   margin: const EdgeInsets.only(bottom: 16.0),
//                                   padding: const EdgeInsets.all(16.0),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: const [
//                                       BoxShadow(
//                                         color: Colors.black12,
//                                         blurRadius: 10,
//                                         offset: Offset(0, 5),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // Media
//                                       if (mediaUrls.isNotEmpty)
//                                         SizedBox(
//                                           height: mediaHeight,
//                                           child: Stack(
//                                             children: [
//                                               PageView.builder(
//                                                 itemCount: mediaUrls.length,
//                                                 itemBuilder: (context, pageIndex) {
//                                                   final url = mediaUrls[pageIndex];
//                                                   return ClipRRect(
//                                                     borderRadius: BorderRadius.circular(8),
//                                                     child: Image.network(
//                                                       url,
//                                                       width: double.infinity,
//                                                       height: mediaHeight,
//                                                       fit: BoxFit.cover,
//                                                       errorBuilder: (context, error, stackTrace) {
//                                                         return Container(
//                                                           width: double.infinity,
//                                                           height: mediaHeight,
//                                                           color: Colors.grey.shade300,
//                                                           child: const Icon(Icons.image, color: Colors.grey),
//                                                         );
//                                                       },
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                               if (mediaUrls.length > 1)
//                                                 Positioned(
//                                                   bottom: 10,
//                                                   left: 0,
//                                                   right: 0,
//                                                   child: Row(
//                                                     mainAxisAlignment: MainAxisAlignment.center,
//                                                     children: List.generate(
//                                                       mediaUrls.length,
//                                                           (dotIndex) => Container(
//                                                         margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                                                         width: 8,
//                                                         height: 8,
//                                                         decoration: BoxDecoration(
//                                                           shape: BoxShape.circle,
//                                                           color: Colors.white.withOpacity(0.5),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         notification.title,
//                                         style: const TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         notification.createdAt ?? 'Unknown',
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         notification.message,
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.black87,
//                                           height: 1.5,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }