import 'dart:async';
import 'dart:io';
import 'package:datn_app/common/constant/api_constant.dart';
import 'package:datn_app/feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  bool _isLoading = false;
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
      _isLoading = true;
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
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          BlocListener<RoomBloc, RoomState>(
            listener: (context, state) {
              print('BlocListener state: $state');
              if (state is RoomImagesLoaded && state.roomId == widget.roomId) {
                setState(() {
                  _isLoading = false;
                  _images = state.images;
                });
                if (_images.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.snackbar(
                      'Thông báo',
                      'Chưa cập nhật ảnh hoặc video cho phòng này',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                    Navigator.of(context).pop();
                  });
                }
                print('Images loaded: ${state.images.map((i) => i.imageUrl).toList()}');
              } else if (state is RoomError) {
                setState(() {
                  _isLoading = false;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.snackbar(
                    'Lỗi',
                    'Không thể tải media: ${state.message}',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                  Navigator.of(context).pop();
                });
                print('Error: ${state.message}');
              }
            },
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _images.isEmpty
                    ? const SizedBox()
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final image = _images[index];
                          if (_isVideo(image.imageUrl)) {
                            return FutureBuilder<ChewieController?>(
                              future: _getChewieController(image.imageUrl),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  print('Video load error: ${snapshot.error}');
                                  return const SizedBox();
                                }
                                return Chewie(controller: snapshot.data!);
                              },
                            );
                          } else {
                            final imageUrl = _buildImageUrl(image.imageUrl);
                            print('Loading image: $imageUrl');
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) {
                                print('Error loading image: $error, URL: $imageUrl');
                                String errorMessage = 'Lỗi không xác định';
                                if (error.toString().contains('404')) {
                                  errorMessage = 'Ảnh không tồn tại trên server';
                                } else if (error.toString().contains('HttpException')) {
                                  errorMessage = 'Kết nối server bị gián đoạn';
                                }
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  Get.snackbar(
                                    'Lỗi',
                                    'Không thể tải ảnh: $errorMessage',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                });
                                return const SizedBox();
                              },
                            );
                          }
                        },
                      ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_images.length > 1 && !_isLoading) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            if (_currentIndex < _images.length - 1)
              Positioned(
                right: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            Positioned(
              bottom: _isVideo(_images[_currentIndex].imageUrl) ? 60 : 20, // Adjust for video
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _images.length,
                  effect: const WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: Colors.blue,
                    spacing: 8,
                    dotColor: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}