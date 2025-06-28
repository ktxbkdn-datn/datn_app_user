import 'dart:async';
import 'dart:ui';
import 'package:chewie/chewie.dart';
import 'package:datn_app/feature/notification/presentation/widget/full_screen_media_widget.dart';
import 'package:datn_app/common/components/app_background.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../../common/constant/api_constant.dart';
import '../../../../common/constant/colors.dart';
import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/utils/responsive_widget_extension.dart';
import '../../../../common/widgets/responsive_scaffold.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationDetailScreen extends StatefulWidget {
  final String title;
  final String message;
  final String timestamp;
  final int notificationId;
  final int? recipientId;

  const NotificationDetailScreen({
    super.key,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.notificationId,
    this.recipientId,
  });

  @override
  _NotificationDetailScreenState createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  List<Map<String, dynamic>> mediaItems = [];
  List<Map<String, dynamic>> nonDocumentMediaItems = [];
  List<Map<String, dynamic>> documentMediaItems = [];
  String? authToken;
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};
  final PageController _mediaPageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    context.read<NotificationBloc>().add(FetchNotificationMediaEvent(
      notificationId: widget.notificationId,
      fileType: null,
    ));
    context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(notificationId: widget.notificationId));
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('auth_token');
    });
  }

  @override
  void dispose() {
    _chewieControllers.values.forEach((controller) => controller?.dispose());
    _chewieControllers.clear();
    _videoControllers.values.forEach((controller) => controller?.dispose());
    _videoControllers.clear();
    _mediaPageController.dispose();
    super.dispose();
  }

  bool _isVideo(String url) {
    if (url.isEmpty) return false;
    final extension = url.toLowerCase().split('.').last;
    return ['mp4', 'avi'].contains(extension);
  }

  String _buildMediaUrl(String mediaPath) {
    return '${getAPIbaseUrl()}/notification_media/$mediaPath';
  }

  void _buildMediaItems() {
    nonDocumentMediaItems = mediaItems.where((item) => item['file_type'] != 'document').toList();
    documentMediaItems = mediaItems.where((item) => item['file_type'] == 'document').toList();
    print('Non-document media items: $nonDocumentMediaItems');
    print('Document media items: $documentMediaItems');
  }

  Future<ChewieController?> _getChewieController(String url) async {
    if (!_chewieControllers.containsKey(url)) {
      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: authToken != null ? {'Authorization': 'Bearer $authToken'} : {},
      );
      _videoControllers[url] = videoController;

      try {
        await videoController.initialize().timeout(Duration(seconds: 60), onTimeout: () {
          throw TimeoutException('Video initialization timeout: $url');
        });

        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          showControlsOnInitialize: true,
          allowPlaybackSpeedChanging: false,
          placeholder: const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load video: $errorMessage',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
        _chewieControllers[url] = chewieController;
      } catch (error, stackTrace) {
        videoController.dispose();
        _videoControllers.remove(url);
        return null;
      }
    }
    return _chewieControllers[url];
  }

  void _showFullScreenMedia(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => FullScreenMediaDialog(
        mediaItems: mediaItems,
        initialIndex: initialIndex,
        chewieControllers: _chewieControllers,
        videoControllers: _videoControllers,
        baseUrl: getAPIbaseUrl(),
      ),
    );
  }

  void _scrollToPreviousMedia() {
    if (_currentPageIndex > 0) {
      _mediaPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToNextMedia() {
    if (_currentPageIndex < nonDocumentMediaItems.length - 1) {
      _mediaPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
      return formatter.format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTimestamp = _formatTimestamp(widget.timestamp);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Glassmorphism background elements
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0F2FE), // blue-50
                      Color(0xFFE0E7FF), // indigo-50
                      Color(0xFFF3E8FF), // purple-50
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.18), Colors.purple.withOpacity(0.12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.withOpacity(0.18), Colors.pink.withOpacity(0.12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUtils.wp(context, 4)),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ResponsiveUtils.isTablet(context) ? 700 : 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          color: Colors.white.withOpacity(0.7),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.wp(context, 4),
                              vertical: ResponsiveUtils.hp(context, 1.8)
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back, 
                                    color: Colors.black87, 
                                    size: ResponsiveUtils.sp(context, 22)
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                SizedBox(width: ResponsiveUtils.wp(context, 3)),
                                Text(
                                  "Chi tiết thông báo",
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.sp(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.hp(context, 2.5)),
                        // Content Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          color: Colors.white.withOpacity(0.8),
                          child: Padding(
                            padding: EdgeInsets.all(ResponsiveUtils.wp(context, 6)),
                            child: BlocConsumer<NotificationBloc, NotificationState>(
                              listener: (context, state) {
                                if (state is NotificationError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lỗi: ${state.message}')),
                                  );
                                } else if (state is NotificationMediaLoaded) {
                                  setState(() {
                                    mediaItems = state.media
                                        .map((media) => {
                                              'media_url': media.mediaUrl,
                                              'file_type': media.fileType,
                                              'filename': media.mediaUrl.split('/').last,
                                            })
                                        .toList();
                                    _buildMediaItems();
                                  });
                                }
                              },
                              builder: (context, state) {
                                final isLoading = state is NotificationLoading;
                                return isLoading
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.hp(context, 5)),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Media Gallery
                                          if (nonDocumentMediaItems.isNotEmpty) ...[
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 24),
                                              child: Stack(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 16 / 9,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: PageView.builder(
                                                        controller: _mediaPageController,
                                                        itemCount: nonDocumentMediaItems.length,
                                                        onPageChanged: (index) {
                                                          setState(() {
                                                            _currentPageIndex = index;
                                                          });
                                                        },
                                                        itemBuilder: (context, index) {
                                                          final media = nonDocumentMediaItems[index];
                                                          final url = _buildMediaUrl(media['media_url'] as String);
                                                          return GestureDetector(
                                                            onTap: () => _showFullScreenMedia(context, index),
                                                            child: media['file_type'] == 'video'
                                                                ? Container(
                                                                    color: Colors.grey[200],
                                                                    child: Center(
                                                                      child: Icon(Icons.videocam, size: 60, color: Colors.grey[500]),
                                                                    ),
                                                                  )
                                                                : CachedNetworkImage(
                                                                    imageUrl: url,
                                                                    fit: BoxFit.cover,
                                                                    httpHeaders: authToken != null
                                                                        ? {'Authorization': 'Bearer $authToken'}
                                                                        : {},
                                                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                                                  ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  if (nonDocumentMediaItems.length > 1) ...[
                                                    Positioned(
                                                      left: 8,
                                                      top: 0,
                                                      bottom: 0,
                                                      child: IconButton(
                                                        icon: const Icon(Icons.chevron_left, color: Colors.black54, size: 32),
                                                        onPressed: _scrollToPreviousMedia,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 8,
                                                      top: 0,
                                                      bottom: 0,
                                                      child: IconButton(
                                                        icon: const Icon(Icons.chevron_right, color: Colors.black54, size: 32),
                                                        onPressed: _scrollToNextMedia,
                                                      ),
                                                    ),
                                                  ],
                                                  if (nonDocumentMediaItems.length > 1)
                                                    Positioned(
                                                      bottom: 12,
                                                      left: 0,
                                                      right: 0,
                                                      child: Center(
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.3),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Text(
                                                            '${_currentPageIndex + 1} / ${nonDocumentMediaItems.length}',
                                                            style: const TextStyle(color: Colors.white, fontSize: 13),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          // Document Media
                                          if (documentMediaItems.isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: Text(
                                                'Tài liệu',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 110,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: documentMediaItems.length,
                                                itemBuilder: (context, index) {
                                                  final doc = documentMediaItems[index];
                                                  return GestureDetector(
                                                    onTap: () => _showFullScreenMedia(context, nonDocumentMediaItems.length + index),
                                                    child: Container(
                                                      width: 80,
                                                      margin: const EdgeInsets.only(right: 12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: Colors.grey[300]!),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            doc['filename'].toString().toLowerCase().endsWith('.pdf')
                                                                ? Icons.picture_as_pdf
                                                                : Icons.insert_drive_file,
                                                            size: 32,
                                                            color: doc['filename'].toString().toLowerCase().endsWith('.pdf')
                                                                ? Colors.red
                                                                : Colors.blue,
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                            child: Text(
                                                              doc['filename'],
                                                              style: const TextStyle(fontSize: 11, color: Colors.black87),
                                                              textAlign: TextAlign.center,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                          // Notification Content
                                          Padding(
                                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                                            child: Text(
                                              widget.title,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(
                                                formattedTimestamp,
                                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            widget.message,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87,
                                              height: 1.6,
                                            ),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}