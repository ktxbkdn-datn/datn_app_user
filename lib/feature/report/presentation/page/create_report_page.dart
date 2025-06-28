import 'dart:ui';
import 'package:datn_app/common/constant/colors.dart';
import 'package:datn_app/common/components/app_background.dart';
import 'package:datn_app/common/utils/responsive_utils.dart';
import 'package:datn_app/common/utils/responsive_widget_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../domain/entity/report_type_entity.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  int? selectedReportTypeId;
  List<ImageData> selectedMedia = [];
  bool isAddingMedia = false;
  bool _isSubmitting = false;
  bool _isProcessingFiles = false;
  double _uploadProgress = 0.0;
  List<ChewieController?> _chewieControllers = [];
  final ImagePicker _picker = ImagePicker();

  static const int maxFiles = 15;
  static const int maxImageSizeInBytes = 50 * 1024 * 1024; // 50MB
  static const int maxVideoSizeInBytes = 100 * 1024 * 1024; // 100MB
  final List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'avi'];

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(const GetReportTypesEvent());
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    for (var controller in _chewieControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMedia() async {
    if (_isProcessingFiles) return;

    if (isAddingMedia) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Chọn loại media"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Ảnh"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickMediaInternal(isVideo: false);
                  },
                ),
                ListTile(
                  title: const Text("Video"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickMediaInternal(isVideo: true);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      setState(() {
        isAddingMedia = true;
      });
    }
  }

  Future<void> _pickMediaInternal({required bool isVideo}) async {
    setState(() {
      _isProcessingFiles = true;
    });

    try {
      List<ImageData> newMediaData = [];
      if (isVideo) {
        final XFile? media = await _picker.pickVideo(source: ImageSource.gallery);
        if (media == null) {
          debugPrint("No video selected from gallery");
          return;
        }

        int fileSize = await media.length();
        if (!_isAllowedFile(media.name)) {
          Get.snackbar(
            'Lỗi',
            'File ${media.name} không được hỗ trợ (chỉ hỗ trợ jpg, jpeg, png, gif, mp4, avi)',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(8),
            borderRadius: 8,
          );
          return;
        }

        if (fileSize > maxVideoSizeInBytes) {
          Get.snackbar(
            'Lỗi',
            'File ${media.name} vượt quá giới hạn ${maxVideoSizeInBytes ~/ 1024 ~/ 1024} MB',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(8),
            borderRadius: 8,
          );
          return;
        }

        newMediaData.add(ImageData(
          file: kIsWeb ? null : File(media.path),
          xFile: media,
          mimeType: _getMimeTypeFromExtension(media.path),
          fileSize: fileSize,
        ));
      } else {
        final List<XFile> mediaList = await _picker.pickMultiImage();
        if (mediaList.isEmpty) {
          debugPrint("No images selected from gallery");
          return;
        }

        for (var media in mediaList) {
          if (!_isAllowedFile(media.name)) {
            Get.snackbar(
              'Lỗi',
              'File ${media.name} không được hỗ trợ (chỉ hỗ trợ jpg, jpeg, png, gif, mp4, avi)',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: EdgeInsets.all(8),
              borderRadius: 8,
            );
            continue;
          }

          int fileSize = await media.length();
          if (fileSize > maxImageSizeInBytes) {
            Get.snackbar(
              'Lỗi',
              'File ${media.name} vượt quá giới hạn ${maxImageSizeInBytes ~/ 1024 ~/ 1024} MB',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: EdgeInsets.all(8),
              borderRadius: 8,
            );
            continue;
          }

          newMediaData.add(ImageData(
            file: kIsWeb ? null : File(media.path),
            xFile: media,
            mimeType: _getMimeTypeFromExtension(media.path),
            fileSize: fileSize,
          ));
        }
      }

      final newChewieControllers = <ChewieController?>[];
      for (var mediaData in newMediaData) {
        if (isVideo && !kIsWeb && mediaData.mimeType != null && mediaData.mimeType!.startsWith('video/') && mediaData.file != null) {
          final videoController = VideoPlayerController.file(mediaData.file!);
          await videoController.initialize();
          final chewieController = ChewieController(
            videoPlayerController: videoController,
            autoPlay: false,
            looping: false,
            showControls: true,
            aspectRatio: videoController.value.aspectRatio,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.blue,
              handleColor: Colors.blueAccent,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey[300]!,
            ),
          );
          newChewieControllers.add(chewieController);
        } else {
          newChewieControllers.add(null);
        }
      }

      setState(() {
        if (selectedMedia.length + newMediaData.length > maxFiles) {
          Get.snackbar(
            'Lỗi',
            'Chỉ được tải lên tối đa 15 file mỗi lần',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(8),
            borderRadius: 8,
          );
          newMediaData = newMediaData.sublist(0, maxFiles - selectedMedia.length);
          newChewieControllers.clear();
          for (var i = 0; i < newMediaData.length; i++) {
            newChewieControllers.add(null);
          }
        }
        selectedMedia.addAll(newMediaData);
        for (var controller in _chewieControllers) {
          controller?.dispose();
        }
        _chewieControllers = newChewieControllers;
        isAddingMedia = false;
      });
    } catch (e) {
      debugPrint('Error picking files: $e');
      Get.snackbar(
        'Lỗi',
        'Lỗi khi chọn file: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      );
    } finally {
      setState(() {
        _isProcessingFiles = false;
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _chewieControllers[index]?.dispose();
      selectedMedia.removeAt(index);
      _chewieControllers.removeAt(index);
    });
  }

  void _submitReport() async {
    if (titleController.text.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập tiêu đề báo cáo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      );
      return;
    }
    if (contentController.text.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập nội dung báo cáo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      final List<File> images = [];
      final List<Uint8List> bytes = [];

      for (var media in selectedMedia) {
        if (kIsWeb) {
          if (media.xFile != null) {
            final fileBytes = await media.xFile!.readAsBytes();
            bytes.add(fileBytes);
          }
        } else {
          if (media.file != null) {
            images.add(media.file!);
          }
        }
      }

      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      context.read<ReportBloc>().add(CreateReportEvent(
        title: titleController.text,
        content: contentController.text,
        reportTypeId: selectedReportTypeId,
        images: images,
        bytes: bytes,
      ));
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _uploadProgress = 0.0;
      });
      Get.snackbar(
        'Lỗi',
        'Lỗi khi gửi báo cáo: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        mainButton: TextButton(
          onPressed: _submitReport,
          child: Text(
            'Thử lại',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: BlocListener<ReportBloc, ReportState>(
        listener: (context, state) async {
          if (state is ReportLoaded && state.selectedReport != null && _isSubmitting) {
            setState(() {
              _isSubmitting = false;
              _uploadProgress = 0.0;
            });
            Get.snackbar(
              'Thành công',
              'Gửi báo cáo thành công!',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              margin: const EdgeInsets.all(8),
              borderRadius: 8,
              duration: const Duration(seconds: 2),
            );
            await Future.delayed(const Duration(milliseconds: 1200));
            if (mounted) Navigator.pop(context, true);
          } else if (state is ReportError && _isSubmitting) {
            setState(() {
              _isSubmitting = false;
              _uploadProgress = 0.0;
            });
            Get.snackbar(
              'Lỗi',
              state.message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: const EdgeInsets.all(8),
              borderRadius: 8,
            );
          }
        },
        child: Stack(
          children: [
            // Glassmorphism background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xE6F0F4FF), Color(0xE6F3E8FF), Color(0xE6F8E1FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Glassy blurred circles for effect
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple.withOpacity(0.18), Colors.pink.withOpacity(0.12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Card
                        Card(
                          elevation: 10,
                          color: Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Tạo báo cáo mới",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Form Card
                        Card(
                          elevation: 10,
                          color: Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Report Type
                                const Text(
                                  "Loại báo cáo",
                                  style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                BlocBuilder<ReportBloc, ReportState>(
                                  builder: (context, state) {
                                    List<ReportTypeEntity> reportTypes = state is ReportLoaded ? state.reportTypes : [];
                                    return DropdownButtonFormField<int>(
                                      value: selectedReportTypeId,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedReportTypeId = value;
                                        });
                                      },
                                      items: reportTypes
                                          .map((type) => DropdownMenuItem(
                                                value: type.reportTypeId,
                                                child: Text(type.name),
                                              ))
                                          .toList(),
                                      hint: const Text('Chọn loại báo cáo'),
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.5),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveUtils.wp(context, 6), 
                                          vertical: ResponsiveUtils.hp(context, 2.2)
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(ResponsiveUtils.wp(context, 12.5)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 18),
                                // Title
                                  Text(
                                  "Tiêu đề báo cáo",
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.sp(context, 15), 
                                    color: Colors.black87, 
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: titleController,
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.5),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    hintText: 'Nhập tiêu đề báo cáo',
                                  ),
                                ),
                                const SizedBox(height: 18),
                                // Content
                                  Text(
                                  "Nội dung báo cáo",
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.sp(context, 15), 
                                    color: Colors.black87, 
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: contentController,
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.5),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    hintText: 'Nhập nội dung chi tiết báo cáo',
                                  ),
                                ),
                                const SizedBox(height: 18),
                                // Media Upload
                                const Text(
                                  "Media (Ảnh/Video)",
                                  style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                if (_isSubmitting)
                                  LinearProgressIndicator(
                                    value: _uploadProgress,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickMedia,
                                  child: Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      border: Border.all(color: Colors.blueGrey.withOpacity(0.18), width: 1.5),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blueGrey.withOpacity(0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _isProcessingFiles
                                          ? const CircularProgressIndicator()
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.upload_file, size: 36, color: Colors.blueGrey),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Nhấn để chọn file',
                                                  style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tối đa $maxFiles file, ảnh < ${maxImageSizeInBytes ~/ 1024 ~/ 1024} MB, video < ${maxVideoSizeInBytes ~/ 1024 ~/ 1024} MB',
                                                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (selectedMedia.isNotEmpty) ...[
                                  const Text(
                                    'File đã chọn:',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  ...selectedMedia.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    ImageData media = entry.value;
                                    return Card(
                                      color: Colors.white.withOpacity(0.7),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            if (media.mimeType != null && media.mimeType!.startsWith('video/'))
                                              (kIsWeb || _chewieControllers[index] == null)
                                                  ? const Icon(
                                                      Icons.videocam,
                                                      size: 50,
                                                      color: Colors.blueGrey,
                                                    )
                                                  : SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Chewie(
                                                        controller: _chewieControllers[index]!,
                                                      ),
                                                    )
                                            else
                                              FutureBuilder<Uint8List>(
                                                future: media.xFile!.readAsBytes(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Center(child: CircularProgressIndicator()),
                                                    );
                                                  }
                                                  if (snapshot.hasData) {
                                                    return ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.memory(
                                                        snapshot.data!,
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
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
                                                          return const Icon(
                                                            Icons.broken_image,
                                                            size: 50,
                                                            color: Colors.blueGrey,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }
                                                  return const Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.blueGrey,
                                                  );
                                                },
                                              ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    media.xFile!.name,
                                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    _formatFileSize(media.fileSize!),
                                                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                              onPressed: () => _removeMedia(index),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 16),
                                ],
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting || _isProcessingFiles ? null : () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.7),
                                          foregroundColor: Colors.black87,
                                          minimumSize: const Size(double.infinity, 48),
                                          shape: const StadiumBorder(),
                                          elevation: 0,
                                        ),
                                        child: const Text("Hủy", style: TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 48),
                                          shape: const StadiumBorder(),
                                          elevation: 0,
                                        ),
                                        onPressed: _isSubmitting || _isProcessingFiles ? null : _submitReport,
                                        child: _isSubmitting
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text("Đang gửi...", style: TextStyle(fontWeight: FontWeight.w600)),
                                                ],
                                              )
                                            : const Text("Gửi báo cáo", style: TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isAllowedFile(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'avi'].contains(extension);
  }

  String _getMimeTypeFromExtension(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
        return 'image/tiff';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'wmv':
        return 'video/x-ms-wmv';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      default:
        return 'application/octet-stream';
    }
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024 * 1024) {
      double sizeInKB = sizeInBytes / 1024;
      return '${sizeInKB.toStringAsFixed(1)} KB';
    } else {
      double sizeInMB = sizeInBytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }
}

class ImageData {
  final File? file;
  final XFile? xFile;
  final Uint8List? bytes;
  final String? mimeType;
  final int? fileSize;

  ImageData({
    this.file,
    this.xFile,
    this.bytes,
    this.mimeType,
    this.fileSize,
  });
}