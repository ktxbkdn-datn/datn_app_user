import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? avatarUrl;
  final String defaultImagePath;
  final ValueChanged<List<ImageData>> onMediaSelected;
  final ValueChanged<bool> onUploadingChanged;
  final int maxFiles;
  final int maxFileSizeInBytes;
  final bool allowVideo;

  const ImagePickerWidget({
    super.key,
    this.avatarUrl,
    required this.defaultImagePath,
    required this.onMediaSelected,
    required this.onUploadingChanged,
    this.maxFiles = 10,
    this.maxFileSizeInBytes = 50 * 1024 * 1024, // 50MB
    this.allowVideo = true,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<ImageData> _selectedMedia = [];
  List<ChewieController?> _chewieControllers = [];
  bool isDragging = false;
  bool _isProcessingFiles = false;

  @override
  void dispose() {
    for (var controller in _chewieControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMedia() async {
    if (_isProcessingFiles) return;

    if (widget.maxFiles == 1 || !widget.allowVideo) {
      await _pickMediaInternal(isVideo: false);
    } else {
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
    }
  }

  Future<void> _pickMediaInternal({required bool isVideo}) async {
    final ImagePicker picker = ImagePicker();
    List<ImageData> selectedMediaData = [];

    setState(() {
      _isProcessingFiles = true;
    });
    widget.onUploadingChanged(true);

    try {
      if (isVideo) {
        if (!widget.allowVideo) {
          debugPrint("Video selection is disabled");
          return;
        }
        final XFile? media = await picker.pickVideo(source: ImageSource.gallery);
        if (media == null) {
          debugPrint("No video selected from gallery");
          return;
        }

        int fileSize = await media.length();
        debugPrint("Video picked:");
        debugPrint("Path: ${media.path}");
        debugPrint("File size: $fileSize bytes");

        if (fileSize > widget.maxFileSizeInBytes) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File vượt quá giới hạn kích thước (${widget.maxFileSizeInBytes ~/ (1024 * 1024)}MB)"),
            ),
          );
          return;
        }

        final mimeType = _getMimeTypeFromExtension(media.path);
        if (!_isValidMediaMimeType(mimeType, isVideo: true)) {
          debugPrint("Invalid MIME type: $mimeType");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Only video files are supported (MP4, MOV, WMV, AVI, MKV)",
              ),
            ),
          );
          return;
        }

        selectedMediaData.add(ImageData(
          file: kIsWeb ? null : File(media.path),
          xFile: media,
          mimeType: mimeType,
          fileSize: fileSize,
        ));
      } else {
        if (widget.maxFiles == 1) {
          final XFile? media = await picker.pickImage(source: ImageSource.gallery);
          if (media == null) {
            debugPrint("No image selected from gallery");
            return;
          }

          int fileSize = await media.length();
          debugPrint("Image picked:");
          debugPrint("Path: ${media.path}");
          debugPrint("File size: $fileSize bytes");

          if (fileSize > widget.maxFileSizeInBytes) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("File vượt quá giới hạn kích thước (${widget.maxFileSizeInBytes ~/ (1024 * 1024)}MB)"),
              ),
            );
            return;
          }

          final mimeType = _getMimeTypeFromExtension(media.path);
          if (!_isValidMediaMimeType(mimeType, isVideo: false)) {
            debugPrint("Invalid MIME type: $mimeType");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Only image files are supported (PNG, JPG, GIF, WEBP, BMP, TIFF, HEIC, HEIF)",
                ),
              ),
            );
            return;
          }

          selectedMediaData.add(ImageData(
            file: kIsWeb ? null : File(media.path),
            xFile: media,
            mimeType: mimeType,
            fileSize: fileSize,
          ));
        } else {
          final List<XFile> mediaList = await picker.pickMultiImage();
          if (mediaList.isEmpty) {
            debugPrint("No images selected from gallery");
            return;
          }

          for (var media in mediaList) {
            int fileSize = await media.length();
            debugPrint("Image picked:");
            debugPrint("Path: ${media.path}");
            debugPrint("File size: $fileSize bytes");

            if (fileSize > widget.maxFileSizeInBytes) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("File vượt quá giới hạn kích thước (${widget.maxFileSizeInBytes ~/ (1024 * 1024)}MB)"),
                ),
              );
              continue;
            }

            final mimeType = _getMimeTypeFromExtension(media.path);
            if (!_isValidMediaMimeType(mimeType, isVideo: false)) {
              debugPrint("Invalid MIME type: $mimeType");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Only image files are supported (PNG, JPG, GIF, WEBP, BMP, TIFF, HEIC, HEIF)",
                  ),
                ),
              );
              continue;
            }

            selectedMediaData.add(ImageData(
              file: kIsWeb ? null : File(media.path),
              xFile: media,
              mimeType: mimeType,
              fileSize: fileSize,
            ));
          }
        }
      }

      final newChewieControllers = <ChewieController?>[];
      for (var mediaData in selectedMediaData) {
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
        if (_selectedMedia.length + selectedMediaData.length > widget.maxFiles) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chỉ được tải lên tối đa ${widget.maxFiles} file mỗi lần')),
          );
          selectedMediaData = selectedMediaData.sublist(0, widget.maxFiles - _selectedMedia.length);
          newChewieControllers.clear();
          for (var i = 0; i < selectedMediaData.length; i++) {
            newChewieControllers.add(null);
          }
        }
        _selectedMedia.addAll(selectedMediaData);
        for (var controller in _chewieControllers) {
          controller?.dispose();
        }
        _chewieControllers = newChewieControllers;
      });

      widget.onMediaSelected(_selectedMedia);
    } catch (e) {
      debugPrint('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn file: $e')),
      );
    } finally {
      setState(() {
        _isProcessingFiles = false;
      });
      widget.onUploadingChanged(false);
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _chewieControllers[index]?.dispose();
      _selectedMedia.removeAt(index);
      _chewieControllers.removeAt(index);
    });
    widget.onMediaSelected(_selectedMedia);
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

  bool _isValidMediaMimeType(String mimeType, {required bool isVideo}) {
    if (isVideo) {
      const validVideoMimeTypes = [
        'video/mp4',
        'video/quicktime',
        'video/x-ms-wmv',
        'video/x-msvideo',
        'video/x-matroska',
      ];
      return validVideoMimeTypes.contains(mimeType.toLowerCase());
    } else {
      const validImageMimeTypes = [
        'image/png',
        'image/jpeg',
        'image/gif',
        'image/webp',
        'image/bmp',
        'image/tiff',
        'image/heic',
        'image/heif',
      ];
      return validImageMimeTypes.contains(mimeType.toLowerCase());
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn chỉ có thể tải lên tối đa 15 file mỗi lần (jpg, jpeg, png, gif, mp4, mov, avi). Kích thước tối đa: 50 MB.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMedia,
          child: DragTarget<Uint8List>(
            onWillAccept: (data) {
              setState(() {
                isDragging = true;
              });
              return true;
            },
            onAccept: (data) {
              final fileSize = data.length;
              if (fileSize > widget.maxFileSizeInBytes) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("File vượt quá giới hạn kích thước (${widget.maxFileSizeInBytes ~/ (1024 * 1024)}MB)"),
                  ),
                );
                return;
              }

              final imageData = ImageData(
                bytes: data,
                mimeType: 'image/jpeg',
                fileSize: fileSize,
              );

              setState(() {
                isDragging = false;
                if (_selectedMedia.length + 1 > widget.maxFiles) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chỉ được tải lên tối đa ${widget.maxFiles} file mỗi lần')),
                  );
                  return;
                }
                _selectedMedia.add(imageData);
                _chewieControllers.add(null);
              });
              debugPrint("Media dropped on Web:");
              debugPrint("Bytes length: $fileSize bytes");

              widget.onMediaSelected(_selectedMedia);
            },
            onLeave: (data) {
              setState(() {
                isDragging = false;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDragging ? Colors.grey[300] : Colors.grey[100],
                  border: Border.all(
                    color: isDragging ? Colors.blue : Colors.grey,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isProcessingFiles
                      ? const CircularProgressIndicator()
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file,
                        size: 32,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kIsWeb
                            ? "Kéo & Thả hoặc Nhấn để Tải Media"
                            : "Nhấn để Tải Media",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tối đa ${widget.maxFiles} file, < ${widget.maxFileSizeInBytes ~/ (1024 * 1024)} MB',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedMedia.isNotEmpty) ...[
          const Text(
            'File đã chọn:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._selectedMedia.asMap().entries.map((entry) {
            int index = entry.key;
            ImageData media = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (media.mimeType != null && media.mimeType!.startsWith('video/'))
                    (kIsWeb || _chewieControllers[index] == null)
                        ? const Icon(
                      Icons.videocam,
                      size: 50,
                      color: Colors.grey,
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
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media.xFile!.name,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatFileSize(media.fileSize!),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
      ],
    );
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