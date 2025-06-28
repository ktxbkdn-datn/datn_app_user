import 'dart:async';
import 'package:datn_app/common/constant/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/room_image_entity.dart';

class FullScreenMediaDialog extends StatefulWidget {
  final int roomId;
  final List<RoomImageEntity> images;
  final VoidCallback onFetchImages;

  const FullScreenMediaDialog({
    Key? key,
    required this.roomId,
    required this.images,
    required this.onFetchImages,
  }) : super(key: key);

  @override
  _FullScreenMediaDialogState createState() => _FullScreenMediaDialogState();
}

class _FullScreenMediaDialogState extends State<FullScreenMediaDialog> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<RoomImageEntity> _images = [];
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};
  static final _cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _images = widget.images;
    print('FullScreenMediaDialog init: roomId=${widget.roomId}, images=${_images.length}');
    if (_images.isEmpty) {
      widget.onFetchImages();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    print('FullScreenMediaDialog disposed');
    super.dispose();
  }

  String _buildImageUrl(String imagePath) {
    final baseUrl = getAPIbaseUrl().replaceAll(RegExp(r'\/+$'), '');
    return '$baseUrl/roomimage/$imagePath';
  }

  bool _isVideo(String url) {
    final extension = url.toLowerCase().split('.').last;
    return ['mp4', 'avi'].contains(extension);
  }

  Future<bool> _isUrlAccessible(String url) async {
    try {
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
      print('URL check for $url: Status ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('URL accessibility check failed for $url: $e');
      return false;
    }
  }

  Future<FileInfo> _preFetchVideo(String url) async {
    try {
      final fileInfo = await _cacheManager.downloadFile(url).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Failed to fetch video: $url');
        },
      );
      if (!fileInfo.file.existsSync()) {
        throw Exception('Failed to fetch video: $url');
      }
      print('Video fetched and cached: ${fileInfo.file.path}');
      return fileInfo;
    } catch (e) {
      print('Error fetching video: $e');
      rethrow;
    }
  }

  Future<ChewieController?> _getChewieController(String url) async {
    if (!_chewieControllers.containsKey(url)) {
      final fullUrl = _buildImageUrl(url);
      print('Đang khởi tạo video: $fullUrl');

      if (!await _isUrlAccessible(fullUrl)) {
        print('Video URL không thể truy cập: $fullUrl');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Lỗi',
            'Video không tồn tại hoặc không thể truy cập server',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        });
        return null;
      }

      for (int attempt = 1; attempt <= 5; attempt++) {
        try {
          // Try streaming first
          final videoController = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
          _videoControllers[url] = videoController;

          await videoController.initialize().timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw TimeoutException('Khởi tạo video thất bại: $fullUrl (Thử $attempt)');
            },
          );
          print('Video khởi tạo thành công qua mạng: $fullUrl');

          final chewieController = ChewieController(
            videoPlayerController: videoController,
            autoPlay: false,
            looping: false,
            allowFullScreen: false,
            errorBuilder: (context, errorMessage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.snackbar(
                  'Lỗi',
                  'Không thể phát video: $errorMessage',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              });
              return const SizedBox();
            },
          );
          _chewieControllers[url] = chewieController;
          return chewieController;
        } catch (error) {
          print('Lỗi khi khởi tạo video qua mạng $fullUrl (Thử $attempt): $error');
          _videoControllers.remove(url);

          if (error.toString().contains('ClientException') && attempt < 5) {
            // Fallback to pre-fetched file
            try {
              print('Chuyển sang chế độ tải trước: $fullUrl');
              final fileInfo = await _preFetchVideo(fullUrl).timeout(
                const Duration(seconds: 20),
                onTimeout: () {
                  throw TimeoutException('Video tải về thất bại: $fullUrl (Thử $attempt)');
                },
              );

              final videoController = VideoPlayerController.file(fileInfo.file);
              _videoControllers[url] = videoController;

              await videoController.initialize().timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException('Khởi tạo video thất bại: $fullUrl (Thử $attempt)');
                },
              );
              print('Video khởi tạo thành công từ file: $fullUrl');

              final chewieController = ChewieController(
                videoPlayerController: videoController,
                autoPlay: false,
                looping: false,
                allowFullScreen: false,
                errorBuilder: (context, errorMessage) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.snackbar(
                      'Lỗi',
                      'Không thể phát video: $errorMessage',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  });
                  return const SizedBox();
                },
              );
              _chewieControllers[url] = chewieController;
              return chewieController;
            } catch (fallbackError) {
              print('Lỗi khi khởi tạo video từ file $fullUrl (Thử $attempt): $fallbackError');
              _videoControllers.remove(url);
            }
          }

          if (attempt == 5) {
            String errorMessage;
            if (error is TimeoutException) {
              errorMessage = 'Hết thời gian tải video, kiểm tra kết nối mạng';
            } else if (error.toString().contains('ClientException')) {
              errorMessage = 'Kết nối server bị gián đoạn, thử lại sau';
            } else {
              errorMessage = 'Lỗi: $error';
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar(
                'Lỗi',
                'Không thể tải video: $errorMessage',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            });
            return null;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    return _chewieControllers[url];
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImages = _images.isNotEmpty;
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.95),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: SizedBox(
        width: 700,
        height: 500,
        child: hasImages
            ? Stack(
                children: [
                  // Close button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 24,
                      tooltip: 'Đóng',
                    ),
                  ),
                  // Main image/video
                  Center(
                    child: SizedBox(
                      height: 340,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final image = _images[index];
                          return AspectRatio(
                            aspectRatio: 4 / 3,
                            child: _isVideo(image.imageUrl)
                                ? FutureBuilder<ChewieController?>(
                                    future: _getChewieController(image.imageUrl),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError || !snapshot.hasData) {
                                        return const Center(child: Text('Không thể phát video', style: TextStyle(color: Colors.white)));
                                      }
                                      return Chewie(controller: snapshot.data!);
                                    },
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: _buildImageUrl(image.imageUrl),
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => const Center(child: Text('Không thể tải ảnh', style: TextStyle(color: Colors.white))),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Navigation arrows
                  if (_images.length > 1) ...[
                    Positioned(
                      left: 5,
                      top: null,
                      bottom: 220,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 36),
                        onPressed: _currentIndex > 0
                            ? () {
                                _pageController.animateToPage(_currentIndex - 1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            : null,
                        splashRadius: 24,
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: null,
                      bottom: 220,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white, size: 36),
                        onPressed: _currentIndex < _images.length - 1
                            ? () {
                                _pageController.animateToPage(_currentIndex + 1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            : null,
                        splashRadius: 24,
                      ),
                    ),
                  ],
                  // Thumbnail strip (dots)
                  if (_images.length > 1)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_images.length, (index) =>
                              GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                },
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _currentIndex ? Colors.white : Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Image counter
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${_images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 220,
                child: Center(
                  child: Text(
                    'Chưa có ảnh hoặc video cho phòng này',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
      ),
    );
  }
}