import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  final int reportId;
  final Future<ChewieController?> Function(String, int) getChewieController;

  const FullScreenMediaViewer({
    Key? key,
    required this.mediaUrls,
    required this.initialIndex,
    required this.reportId,
    required this.getChewieController,
  }) : super(key: key);

  @override
  _FullScreenMediaViewerState createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<ChewieController?> _chewieControllers = [];
  bool _isLoadingVideo = false;
  String? _videoError;
  static final _cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initializeChewieControllers();
  }

  Future<void> _initializeChewieControllers() async {
    setState(() {
      _isLoadingVideo = true;
      _videoError = null;
    });

    _chewieControllers = List.filled(widget.mediaUrls.length, null);
    for (int i = 0; i < widget.mediaUrls.length; i++) {
      try {
        final url = widget.mediaUrls[i];
        if (_isVideo(url)) {
          for (int attempt = 1; attempt <= 5; attempt++) {
            try {
              // Try streaming first
              final videoController = VideoPlayerController.networkUrl(Uri.parse(url));
              await videoController.initialize().timeout(
                const Duration(seconds: 20),
                onTimeout: () {
                  throw TimeoutException('Khởi tạo video thất bại: $url (Thử $attempt)');
                },
              );
              print('Video khởi tạo thành công qua mạng: $url');

              final chewieController = ChewieController(
                videoPlayerController: videoController,
                autoPlay: false,
                looping: false,
                allowFullScreen: false,
                errorBuilder: (context, errorMessage) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Không thể tải video: $errorMessage',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              );
              setState(() {
                _chewieControllers[i] = chewieController;
              });
              break; // Exit retry loop on success
            } catch (error) {
              print('Lỗi khi khởi tạo video qua mạng $url (Thử $attempt): $error');
              if (error.toString().contains('ClientException') && attempt < 5) {
                // Fallback to pre-fetched file
                try {
                  print('Chuyển sang chế độ tải trước: $url');
                  final fileInfo = await _cacheManager.downloadFile(url).timeout(
                    const Duration(seconds: 20),
                    onTimeout: () {
                      throw TimeoutException('Video tải về thất bại: $url (Thử $attempt)');
                    },
                  );

                  final videoController = VideoPlayerController.file(fileInfo.file);
                  await videoController.initialize().timeout(
                    const Duration(seconds: 10),
                    onTimeout: () {
                      throw TimeoutException('Khởi tạo video thất bại: $url (Thử $attempt)');
                    },
                  );
                  print('Video khởi tạo thành công từ file: $url');

                  final chewieController = ChewieController(
                    videoPlayerController: videoController,
                    autoPlay: false,
                    looping: false,
                    allowFullScreen: false,
                    errorBuilder: (context, errorMessage) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Không thể tải video: $errorMessage',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  setState(() {
                    _chewieControllers[i] = chewieController;
                  });
                  break; // Exit retry loop on success
                } catch (fallbackError) {
                  print('Lỗi khi khởi tạo video từ file $url (Thử $attempt): $fallbackError');
                }
              }
              if (attempt == 5) {
                setState(() {
                  _videoError = 'Không thể load video tại vị trí $i';
                });
              }
              await Future.delayed(const Duration(seconds: 1));
            }
          }
        }
      } catch (e) {
        debugPrint('Error initializing ChewieController for ${widget.mediaUrls[i]}: $e');
        setState(() {
          _videoError = 'Không thể load video tại vị trí $i';
        });
      }
    }

    setState(() {
      _isLoadingVideo = false;
    });
  }

  Future<void> _retryLoadVideo(int index) async {
    setState(() {
      _isLoadingVideo = true;
      _videoError = null;
    });

    try {
      final url = widget.mediaUrls[index];
      for (int attempt = 1; attempt <= 5; attempt++) {
        try {
          // Try streaming first
          final videoController = VideoPlayerController.networkUrl(Uri.parse(url));
          await videoController.initialize().timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw TimeoutException('Khởi tạo video thất bại: $url (Thử $attempt)');
            },
          );
          print('Video khởi tạo thành công qua mạng: $url');

          final chewieController = ChewieController(
            videoPlayerController: videoController,
            autoPlay: false,
            looping: false,
            allowFullScreen: false,
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Không thể tải video: $errorMessage',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          );
          setState(() {
            _chewieControllers[index] = chewieController;
          });
          break; // Exit retry loop on success
        } catch (error) {
          print('Lỗi khi khởi tạo video qua mạng $url (Thử $attempt): $error');
          if (error.toString().contains('ClientException') && attempt < 5) {
            // Fallback to pre-fetched file
            try {
              print('Chuyển sang chế độ tải trước: $url');
              final fileInfo = await _cacheManager.downloadFile(url).timeout(
                const Duration(seconds: 20),
                onTimeout: () {
                  throw TimeoutException('Video tải về thất bại: $url (Thử $attempt)');
                },
              );

              final videoController = VideoPlayerController.file(fileInfo.file);
              await videoController.initialize().timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException('Khởi tạo video thất bại: $url (Thử $attempt)');
                },
              );
              print('Video khởi tạo thành công từ file: $url');

              final chewieController = ChewieController(
                videoPlayerController: videoController,
                autoPlay: false,
                looping: false,
                allowFullScreen: false,
                errorBuilder: (context, errorMessage) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Không thể tải video: $errorMessage',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              );
              setState(() {
                _chewieControllers[index] = chewieController;
              });
              break; // Exit retry loop on success
            } catch (fallbackError) {
              print('Lỗi khi khởi tạo video từ file $url (Thử $attempt): $fallbackError');
            }
          }
          if (attempt == 5) {
            setState(() {
              _videoError = 'Không thể load video sau khi thử lại';
            });
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      debugPrint('Retry failed for ${widget.mediaUrls[index]}: $e');
      setState(() {
        _videoError = 'Không thể load video sau khi thử lại';
      });
    }

    setState(() {
      _isLoadingVideo = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _chewieControllers) {
      controller?.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  bool _isVideo(String url) {
    if (url.isEmpty) return false;
    final extension = url.toLowerCase().split('.').last;
    return ['mp4', 'avi'].contains(extension);
  }

  void _previousMedia() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pageController.jumpToPage(_currentIndex);
      });
    }
  }

  void _nextMedia() {
    if (_currentIndex < widget.mediaUrls.length - 1) {
      setState(() {
        _currentIndex++;
        _pageController.jumpToPage(_currentIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main media view with PageView for swipe navigation
            PageView.builder(
              controller: _pageController,
              itemCount: widget.mediaUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final isVideo = _isVideo(widget.mediaUrls[index]);
                if (isVideo) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _chewieControllers[index] != null
                            ? Chewie(controller: _chewieControllers[index]!)
                            : _isLoadingVideo
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.videocam_off, color: Colors.white, size: 50),
                                      const SizedBox(height: 16),
                                      Text(_videoError ?? 'Không thể load video', style: const TextStyle(color: Colors.white)),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => _retryLoadVideo(index),
                                        child: const Text('Thử lại'),
                                      ),
                                    ],
                                  ),
                      ),
                      if (!_isLoadingVideo && _chewieControllers[index] != null)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              final chewie = _chewieControllers[index]!;
                              final isPlaying = chewie.videoPlayerController.value.isPlaying;
                              if (isPlaying) {
                                chewie.videoPlayerController.pause();
                              } else {
                                chewie.videoPlayerController.play();
                              }
                              setState(() {});
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.18),
                              child: Center(
                                child: Icon(
                                  _chewieControllers[index]!.videoPlayerController.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 72,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: widget.mediaUrls[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        debugPrint('Error loading full-screen image: $url, error: $error');
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Get.snackbar(
                            'Lỗi',
                            'Không thể load ảnh',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(8),
                            borderRadius: 8,
                          );
                        });
                        return const Icon(Icons.error, color: Colors.white);
                      },
                    ),
                  );
                }
              },
            ),
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            // Counter (top left)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.mediaUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            // Navigation arrows
            if (widget.mediaUrls.length > 1) ...[
              Positioned(
                left: 16,
                top: MediaQuery.of(context).size.height / 2 - 32,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
                  onPressed: _currentIndex == 0 ? null : _previousMedia,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: MediaQuery.of(context).size.height / 2 - 32,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32),
                  onPressed: _currentIndex == widget.mediaUrls.length - 1 ? null : _nextMedia,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              // Indicators (bottom center)
              Positioned(
                bottom: _isVideo(widget.mediaUrls[_currentIndex]) ? 60 : 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.mediaUrls.length, (index) {
                    return GestureDetector(
                      onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentIndex == index ? 14.0 : 10.0,
                        height: _currentIndex == index ? 14.0 : 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}