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
      return reportType.name;
    } catch (e) {
      debugPrint('Error in _getReportTypeName: $e');
      return 'Không xác định';
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

  // --- Glassmorphism, modern, consistent with React/Next.js design ---
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
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                // Đổi sang nền trắng hoặc trắng mờ nhẹ, không blur
                color: Colors.white.withOpacity(0.92),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                // XÓA: backgroundBlendMode và mọi hiệu ứng blur
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with icon and title
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.description, color: Color(0xFF3B82F6), size: 26),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Chi tiết báo cáo",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              // Spacer(),
                              const SizedBox(width: 8),
                              // Status badge
                              _StatusBadge(status: widget.report.status, translate: _translateStatus),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Card container
                          Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: const EdgeInsets.all(22.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel(label: "Loại báo cáo"),
                                const SizedBox(height: 6),
                                Text(
                                  _getReportTypeName(widget.report.reportTypeId, widget.reportTypes),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _FieldLabel(label: "Tiêu đề báo cáo"),
                                const SizedBox(height: 6),
                                Text(
                                  widget.report.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _FieldLabel(label: "Nội dung báo cáo"),
                                const SizedBox(height: 6),
                                Text(
                                  widget.report.description ?? 'Không có nội dung',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _FieldLabel(label: "Trạng thái"),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _StatusBadge(status: widget.report.status, translate: _translateStatus),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _FieldLabel(label: "Hình ảnh liên quan"),
                                const SizedBox(height: 8),
                                if (isLoading)
                                  const Center(child: CircularProgressIndicator())
                                else if (errorMessage != null)
                                  Column(
                                    children: [
                                      Text(
                                        'Lỗi khi tải hình ảnh',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 50,
                                      )
                                    ],
                                  )
                                else if (reportImages.isNotEmpty)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1,
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
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.grey[100],
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: image.fileType == 'video'
                                                    ? (chewieControllers[index] == null)
                                                        ? const Center(
                                                            child: Icon(
                                                              Icons.videocam,
                                                              size: 48,
                                                              color: Colors.grey,
                                                            ),
                                                          )
                                                        : Chewie(
                                                            controller: chewieControllers[index]!,
                                                          )
                                                    : CachedNetworkImage(
                                                        imageUrl: mediaUrl,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => const Center(
                                                          child: CircularProgressIndicator(),
                                                        ),
                                                        errorWidget: (context, url, error) {
                                                          debugPrint('Failed to load image: $url, error: $error');
                                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                                            Get.snackbar(
                                                              'Lỗi',
                                                              'Ảnh không tồn tại hoặc có lỗi',
                                                              snackPosition: SnackPosition.TOP,
                                                              backgroundColor: Colors.red,
                                                              colorText: Colors.white,
                                                              margin: const EdgeInsets.all(8),
                                                              borderRadius: 8,
                                                            );
                                                          });
                                                          return const Icon(
                                                            Icons.broken_image,
                                                            size: 48,
                                                            color: Colors.grey,
                                                          );
                                                        },
                                                      ),
                                              ),
                                            ),
                                            // Overlay icon
                                            Positioned.fill(
                                              child: AnimatedOpacity(
                                                opacity: 0.0,
                                                duration: const Duration(milliseconds: 200),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.18),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      image.fileType == 'video' ? Icons.videocam : Icons.image,
                                                      color: Colors.white,
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
                                        SizedBox(width: 8),
                                        Text(
                                          'Không có hình ảnh đính kèm',
                                          style: TextStyle(color: Colors.grey, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                // Dates
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Tạo:  ' + (widget.report.createdAt != null ? _formatDate(widget.report.createdAt) : '-'),
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Cập nhật:  ' + (widget.report.updatedAt != null ? _formatDate(widget.report.updatedAt) : '-'),
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 18,
                    right: 18,
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

// Helper widgets for badge and field label
class _StatusBadge extends StatelessWidget {
  final String status;
  final String Function(String) translate;
  const _StatusBadge({required this.status, required this.translate});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    switch (status) {
      case 'PENDING':
        bg = const Color(0xFFFFF7D6);
        fg = const Color(0xFFB45309);
        icon = Icons.access_time_rounded;
        break;
      case 'RECEIVED':
        bg = const Color(0xFFD1E9FF);
        fg = const Color(0xFF2563EB);
        icon = Icons.mark_email_read_rounded;
        break;
      case 'IN_PROGRESS':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFEA580C);
        icon = Icons.play_circle_fill_rounded;
        break;
      case 'RESOLVED':
        bg = const Color(0xFFD1FADF);
        fg = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        break;
      case 'CLOSED':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        icon = Icons.info_outline_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 16),
          const SizedBox(width: 4),
          Text(
            translate(status),
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

String _translateStatus(String status) {
  switch (status) {
    case 'PENDING':
      return 'Chờ xử lý';
    case 'RECEIVED':
      return 'Đã tiếp nhận';
    case 'IN_PROGRESS':
      return 'Đang xử lý';
    case 'RESOLVED':
      return 'Đã xử lý';
    case 'CLOSED':
      return 'Đã đóng';
    default:
      return 'Không xác định';
  }
}

String _formatDate(String? dateStr) {
  if (dateStr == null) return '-';
  try {
    final date = DateTime.parse(dateStr);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '-';
  }
}