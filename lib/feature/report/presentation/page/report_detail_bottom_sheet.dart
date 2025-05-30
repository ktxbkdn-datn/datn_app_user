import 'package:datn_app/common/constant/api_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entity/report_entity.dart';
import '../../domain/entity/report_image_entity.dart';
import '../../domain/entity/report_type_entity.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import 'full_screen_image.dart';

class ReportDetailBottomSheet extends StatefulWidget {
  final ReportEntity report;
  final List<ReportTypeEntity> reportTypes;

  const ReportDetailBottomSheet({
    Key? key,
    required this.report,
    required this.reportTypes,
  }) : super(key: key);

  @override
  State<ReportDetailBottomSheet> createState() => _ReportDetailBottomSheetState();
}

class _ReportDetailBottomSheetState extends State<ReportDetailBottomSheet> {
  List<ReportImageEntity> reportImages = [];
  List<ChewieController?> chewieControllers = [];
  bool isLoading = true;
  String? errorMessage;
  final String baseUrl = getAPIbaseUrl();

  @override
  void initState() {
    super.initState();
    _fetchReportImages();
  }

  @override
  void dispose() {
    for (var controller in chewieControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void _fetchReportImages() {
    context.read<ReportBloc>().add(GetReportImagesEvent(widget.report.reportId));
  }

  String _buildMediaUrl(String filename) {
    return '$baseUrl/reportimage/$filename';
  }

  String _getReportTypeName(int? reportTypeId, List<ReportTypeEntity> reportTypes) {
    if (reportTypeId == null || reportTypes.isEmpty) return 'Không xác định';
    try {
      final reportType = reportTypes.firstWhere(
            (type) => type.reportTypeId == reportTypeId,
        orElse: () => ReportTypeEntity(reportTypeId: 0, name: 'Không xác định'),
      );
      return reportType.name ?? 'Không xác định';
    } catch (e) {
      debugPrint('Error in _getReportTypeName: $e');
      return 'Không xác định';
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 'Đang chờ xử lý';
      case 'RECEIVED':
        return 'Đã tiếp nhận';
      case 'IN_PROGRESS':
        return 'Đang xử lý';
      case 'RESOLVED':
        return 'Đã giải quyết';
      case 'CLOSED':
        return 'Đã đóng';
      default:
        return status;
    }
  }

  bool _isVideo(String url) {
    if (url.isEmpty) return false;
    final extension = url.toLowerCase().split('.').last;
    return ['mp4', 'avi'].contains(extension);
  }

  Future<ChewieController?> _getChewieController(String url, int reportId) async {
    if (!_isVideo(url)) return null;

    try {
      final videoController = VideoPlayerController.network(
        _buildMediaUrl(url),
      );
      await videoController.initialize();
      return ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        showControls: false,
        aspectRatio: videoController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey[300]!,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing video controller for $url: $e');
      return null;
    }
  }

  void _showFullScreenMedia(BuildContext context, List<String> fullMediaUrls, int initialIndex, int reportId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          mediaUrls: fullMediaUrls,
          initialIndex: initialIndex,
          reportId: reportId,
          getChewieController: _getChewieController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportBloc, ReportState>(
      listener: (context, state) async {
        if (state is ReportLoading) {
          setState(() {
            isLoading = true;
            errorMessage = null;
          });
        } else if (state is ReportError) {
          setState(() {
            isLoading = false;
            errorMessage = state.message;
          });
          Get.snackbar(
            'Lỗi',
            'Lỗi khi load hình ảnh: $errorMessage',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(8),
            borderRadius: 8,
          );
        } else if (state is ReportLoaded) {
          final images = state.reportImages[widget.report.reportId] ?? [];
          List<ChewieController?> controllers = [];
          for (var image in images) {
            if (image.fileType == 'video') {
              try {
                final videoController = VideoPlayerController.network(
                  _buildMediaUrl(image.imageUrl),
                );
                await videoController.initialize();
                final chewieController = ChewieController(
                  videoPlayerController: videoController,
                  autoPlay: false,
                  looping: false,
                  showControls: false,
                  aspectRatio: videoController.value.aspectRatio,
                  materialProgressColors: ChewieProgressColors(
                    playedColor: Colors.blue,
                    handleColor: Colors.blueAccent,
                    backgroundColor: Colors.grey,
                    bufferedColor: Colors.grey[300]!,
                  ),
                );
                controllers.add(chewieController);
              } catch (e) {
                debugPrint('Error initializing video: $e');
                controllers.add(null);
                Get.snackbar(
                  'Lỗi',
                  'Không thể load video',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  margin: EdgeInsets.all(8),
                  borderRadius: 8,
                );
              }
            } else {
              controllers.add(null);
            }
          }

          setState(() {
            reportImages = images;
            chewieControllers = controllers;
            isLoading = false;
            errorMessage = null;
          });
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Chi tiết báo cáo",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0), // Thêm margin cố định
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Loại báo cáo",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getReportTypeName(widget.report.reportTypeId, widget.reportTypes),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Tiêu đề báo cáo",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.report.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Nội dung báo cáo",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.report.description ?? 'Không có nội dung',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Trạng thái",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _translateStatus(widget.report.status),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Hình ảnh liên quan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (isLoading)
                                  const Center(child: CircularProgressIndicator())
                                else if (errorMessage != null)
                                  Text(
                                    "Lỗi: $errorMessage",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  )
                                else if (reportImages.isNotEmpty)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 16 / 9,
                                    ),
                                    itemCount: reportImages.length,
                                    itemBuilder: (context, index) {
                                      final image = reportImages[index];
                                      final mediaUrl = _buildMediaUrl(image.imageUrl);
                                      return GestureDetector(
                                        onTap: () {
                                          final fullMediaUrls = reportImages.map((img) => _buildMediaUrl(img.imageUrl)).toList();
                                          _showFullScreenMedia(context, fullMediaUrls, index, widget.report.reportId);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: image.fileType == 'video'
                                              ? (chewieControllers[index] == null)
                                                  ? const Icon(
                                                      Icons.videocam,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    )
                                                  : Stack(
                                                      children: [
                                                        Chewie(
                                                          controller: chewieControllers[index]!,
                                                        ),
                                                        Positioned(
                                                          bottom: 8,
                                                          left: 8,
                                                          right: 8,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                  chewieControllers[index]!.videoPlayerController.value.isPlaying
                                                                      ? Icons.pause
                                                                      : Icons.play_arrow,
                                                                  color: Colors.white,
                                                                  size: 30,
                                                                ),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    if (chewieControllers[index]!.videoPlayerController.value.isPlaying) {
                                                                      chewieControllers[index]!.pause();
                                                                    } else {
                                                                      chewieControllers[index]!.play();
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                              : CachedNetworkImage(
                                                  imageUrl: mediaUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => const Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                  errorWidget: (context, url, error) {
                                                    debugPrint('Failed to load image: $url, error: $error');
                                                    return const Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      color: Colors.grey[600],
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}