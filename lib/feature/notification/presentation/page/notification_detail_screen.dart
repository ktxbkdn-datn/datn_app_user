import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:datn_app/feature/notification/presentation/widget/full_screen_media_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../../common/constant/api_constant.dart';
import '../../../../common/constant/colors.dart';
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

    return Scaffold(
      body: Stack(
        children: [
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            "Notification Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: BlocConsumer<NotificationBloc, NotificationState>(
                        listener: (context, state) {
                          if (state is NotificationError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${state.message}')),
                            );
                          } else if (state is NotificationMediaLoaded) {
                            setState(() {
                              mediaItems = state.media
                                  .map((media) => ({
                                        'media_url': media.mediaUrl,
                                        'file_type': media.fileType ?? 'image',
                                        'filename': media.mediaUrl.split('/').last,
                                      }))
                                  .toList();
                              print('Loaded media items: $mediaItems');
                              _buildMediaItems();
                            });
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (nonDocumentMediaItems.isNotEmpty) ...[
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 350,
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
                                          return Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                _showFullScreenMedia(context, index);
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  width: 350,
                                                  height: 350,
                                                  child: _isVideo(url)
                                                      ? FutureBuilder<ChewieController?>(
                                                          future: _getChewieController(url),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                                              return const Center(child: CircularProgressIndicator());
                                                            }
                                                            if (snapshot.hasError || !snapshot.hasData) {
                                                              return const Icon(Icons.videocam, size: 40, color: Colors.grey);
                                                            }
                                                            return ClipRect(
                                                              child: Chewie(controller: snapshot.data!),
                                                            );
                                                          },
                                                        )
                                                      : CachedNetworkImage(
                                                          imageUrl: url,
                                                          fit: BoxFit.cover,
                                                          httpHeaders: authToken != null
                                                              ? {'Authorization': 'Bearer $authToken'}
                                                              : {},
                                                          placeholder: (context, url) =>
                                                              const Center(child: CircularProgressIndicator()),
                                                          errorWidget: (context, url, error) {
                                                            return const Icon(Icons.error);
                                                          },
                                                        ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (kIsWeb && nonDocumentMediaItems.length > 1) ...[
                                      Positioned(
                                        left: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 30),
                                          onPressed: _scrollToPreviousMedia,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 30),
                                          onPressed: _scrollToNextMedia,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (documentMediaItems.isNotEmpty) ...[
                                const Text(
                                  'Documents',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: documentMediaItems.length,
                                    itemBuilder: (context, index) {
                                      final doc = documentMediaItems[index];
                                      print('Document item $index: $doc');
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            final docIndex = mediaItems.indexOf(doc);
                                            print('Opening document at index: $docIndex');
                                            _showFullScreenMedia(context, docIndex);
                                          },
                                          child: Container(
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  doc['media_url'].toLowerCase().endsWith('.pdf')
                                                      ? Icons.picture_as_pdf
                                                      : Icons.description,
                                                  size: 40,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  doc['filename'] as String,
                                                  style: TextStyle(fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formattedTimestamp,
                                style: const TextStyle(
                                  fontSize: 14 ,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.message,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
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
        ],
      ),
    );
  }
}