// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:image_picker/image_picker.dart';
// import 'dart:ui';
// import 'package:mime/mime.dart';

// import '../../../../common/constant/colors.dart';
// import '../../../auth/presentation/bloc/auth_bloc.dart';
// import '../../../auth/presentation/bloc/auth_event.dart';
// import '../../../auth/presentation/bloc/auth_state.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   String gender = "man";
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController birthdateController = TextEditingController();
//   TextEditingController cccdController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   List<ImageData> selectedAvatar = [];
//   bool isEditingAvatar = false;
//   bool isFetching = false;
//   bool _isProcessingFiles = false;
//   final ImagePicker _picker = ImagePicker();
//   bool _hasNetworkImageError = false;

//   // ValueNotifier để quản lý thông báo lỗi
//   final ValueNotifier<String?> phoneError = ValueNotifier<String?>(null);
//   final ValueNotifier<String?> cccdError = ValueNotifier<String?>(null);

//   // FocusNode để kiểm tra khi field mất focus
//   FocusNode phoneFocusNode = FocusNode();
//   FocusNode cccdFocusNode = FocusNode();

//   static const int maxFiles = 1;
//   static const int maxImageSizeInBytes = 50 * 1024 * 1024; // 50MB
//   final List<String> _allowedExtensions = [
//     'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff', 'heic', 'heif'
//   ];
//   final List<String> _allowedMimeTypes = [
//     'image/png', 'image/jpeg', 'image/gif', 'image/webp', 'image/bmp',
//     'image/tiff', 'image/heic', 'image/heif'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     final state = BlocProvider.of<AuthBloc>(context, listen: false).state;
//     if (state is UserProfileLoaded) {
//       phoneController.text = state.user.phone ?? "";
//       birthdateController.text = state.user.dateOfBirth ?? "";
//       cccdController.text = state.user.cccd ?? "";
//       nameController.text = state.user.fullname ?? "";
//       emailController.text = state.user.email ?? "";
//     }

//     // Thêm listener cho FocusNode
//     phoneFocusNode.addListener(() {
//       if (!phoneFocusNode.hasFocus) {
//         _validatePhone(phoneController.text);
//       }
//     });
//     cccdFocusNode.addListener(() {
//       if (!cccdFocusNode.hasFocus) {
//         _validateCccd(cccdController.text);
//       }
//     });

//     // Kiểm tra ban đầu
//     _validatePhone(phoneController.text);
//     _validateCccd(cccdController.text);
//   }

//   @override
//   void dispose() {
//     phoneController.dispose();
//     birthdateController.dispose();
//     cccdController.dispose();
//     nameController.dispose();
//     emailController.dispose();
//     phoneFocusNode.dispose();
//     cccdFocusNode.dispose();
//     phoneError.dispose();
//     cccdError.dispose();
//     super.dispose();
//   }

//   // Hàm kiểm tra Số điện thoại
//   void _validatePhone(String value) {
//     if (value.isEmpty) {
//       phoneError.value = "Số điện thoại không được để trống";
//     } else if (value.length < 10 || value.length > 12 || !RegExp(r'^\d+$').hasMatch(value)) {
//       phoneError.value = "Số điện thoại phải từ 10 đến 12 chữ số";
//     } else {
//       phoneError.value = null;
//     }
//   }

//   // Hàm kiểm tra CCCD
//   void _validateCccd(String value) {
//     if (value.isEmpty) {
//       cccdError.value = "CCCD không được để trống";
//     } else if (value.length != 12 || !RegExp(r'^\d{12}$').hasMatch(value)) {
//       cccdError.value = "CCCD phải đúng 12 chữ số";
//     } else {
//       cccdError.value = null;
//     }
//   }

//   // Kiểm tra xem có lỗi nào không
//   bool get _hasErrors {
//     return phoneError.value != null || cccdError.value != null;
//   }

//   // Kiểm tra tệp PNG hợp lệ bằng magic number
//   Future<bool> _isValidPng(String filePath) async {
//     try {
//       final file = File(filePath);
//       final bytes = await file.readAsBytes();
//       // Magic number của PNG: 89 50 4E 47 0D 0A 1A 0A (hex)
//       const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
//       if (bytes.length < pngSignature.length) return false;
//       for (int i = 0; i < pngSignature.length; i++) {
//         if (bytes[i] != pngSignature[i]) return false;
//       }
//       return true;
//     } catch (e) {
//       debugPrint('Error checking PNG validity: $e');
//       return false;
//     }
//   }

//   Future<void> _pickAvatar() async {
//     if (_isProcessingFiles) return;

//     if (mounted) {
//       setState(() {
//         _isProcessingFiles = true;
//       });
//     }

//     try {
//       final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
//       if (media == null) {
//         debugPrint("No image selected from gallery");
//         return;
//       }

//       int fileSize = await media.length();
//       if (fileSize > maxImageSizeInBytes) {
//         Get.snackbar(
//           'Error',
//           'File ${media.name} vượt quá giới hạn ${maxImageSizeInBytes ~/ 1024 ~/ 1024} MB',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }

//       if (!_isAllowedFile(media.name)) {
//         Get.snackbar(
//           'Error',
//           'File ${media.name} không được hỗ trợ (chỉ hỗ trợ jpg, jpeg, png, gif, webp, bmp, tiff, heic, heif)',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }

//       String? mimeType;
//       if (kIsWeb) {
//         mimeType = media.mimeType ?? _getMimeTypeFromExtension(media.name);
//         debugPrint('Web: Determined mimeType for ${media.name}: $mimeType');
//       } else {
//         mimeType = lookupMimeType(media.path) ?? _getMimeTypeFromExtension(media.path);
//         debugPrint('Mobile: Determined mimeType for ${media.path}: $mimeType');
//       }

//       if (mimeType == null || !_allowedMimeTypes.contains(mimeType)) {
//         Get.snackbar(
//           'Error',
//           'File ${media.name} không phải ảnh hợp lệ (chỉ hỗ trợ PNG, JPG, GIF, WEBP, BMP, TIFF, HEIC, HEIF). MIME type: $mimeType',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }

//       final newAvatar = ImageData(
//         file: kIsWeb ? null : File(media.path),
//         xFile: media,
//         mimeType: mimeType,
//         fileSize: fileSize,
//         filename: media.name,
//       );

//       if (mounted) {
//         setState(() {
//           selectedAvatar = [newAvatar];
//           isEditingAvatar = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error picking avatar: $e');
//       Get.snackbar(
//         'Error',
//         'Lỗi khi chọn file: $e',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: Duration(seconds: 3),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessingFiles = false;
//         });
//       }
//     }
//   }

//   Future<void> _pickBirthdate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );

//     if (pickedDate != null && mounted) {
//       String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
//       setState(() {
//         birthdateController.text = formattedDate;
//       });
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (_hasErrors) return;

//     if (birthdateController.text.isEmpty) {
//       _showCustomDialog(
//         isSuccess: false,
//         title: "Error",
//         message: "Ngày sinh không được để trống",
//       );
//       return;
//     }
//     try {
//       final selectedDate = DateFormat('yyyy-MM-dd').parse(birthdateController.text);
//       final today = DateTime.now();
//       if (selectedDate.isAfter(today)) {
//         _showCustomDialog(
//           isSuccess: false,
//           title: "Error",
//           message: "Ngày sinh không được là ngày trong tương lai",
//         );
//         return;
//       }
//     } catch (e) {
//       _showCustomDialog(
//         isSuccess: false,
//         title: "Error",
//         message: "Ngày sinh không hợp lệ",
//       );
//       return;
//     }

//     if (phoneController.text.isEmpty) {
//       _showCustomDialog(
//         isSuccess: false,
//         title: "Error",
//         message: "Số điện thoại không được để trống",
//       );
//       return;
//     }

//     if (cccdController.text.isEmpty) {
//       _showCustomDialog(
//         isSuccess: false,
//         title: "Error",
//         message: "CCCD không được để trống",
//       );
//       return;
//     }

//     if (nameController.text.isEmpty) {
//       _showCustomDialog(
//         isSuccess: false,
//         title: "Error",
//         message: "Họ và tên không được để trống",
//       );
//       return;
//     }

//     if (emailController.text.isEmpty) {
//       _showCustomDialog(
//         isSuccess: false,
//         title: "Error",
//         message: "Email không được để trống",
//       );
//       return;
//     }

//     if (selectedAvatar.isNotEmpty) {
//       final avatarData = selectedAvatar.first;
//       final filePath = kIsWeb ? null : avatarData.file?.path;
//       final fileBytes = kIsWeb ? (avatarData.xFile != null ? await avatarData.xFile!.readAsBytes() : null) : null;
//       final mimeType = avatarData.mimeType;
//       final filename = avatarData.filename;

//       // Kiểm tra tệp PNG trên mobile
//       if (!kIsWeb && filePath != null) {
//         debugPrint('Checking PNG validity for: $filePath');
//         final isValidPng = await _isValidPng(filePath);
//         debugPrint('Is valid PNG: $isValidPng');
//         if (!isValidPng) {
//           Get.snackbar(
//             'Error',
//             'Tệp PNG không hợp lệ. Vui lòng chọn tệp khác.',
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             duration: Duration(seconds: 3),
//           );
//           return;
//         }
//       }

//       debugPrint('Sending UpdateAvatarEvent: filePath=$filePath, mimeType=$mimeType, fileBytesLength=${fileBytes?.length}, filename=$filename');
//       context.read<AuthBloc>().add(UpdateAvatarEvent(
//         filePath: filePath,
//         fileBytes: fileBytes,
//         mimeType: mimeType,
//         filename: filename,
//       ));
//     }

//     context.read<AuthBloc>().add(UpdateUserProfileEvent(
//       phone: phoneController.text,
//       dateOfBirth: birthdateController.text,
//       cccd: cccdController.text,
//       fullname: nameController.text.trim(),
//       email: emailController.text,
//     ));
//   }

//   void _showCustomDialog({
//     required bool isSuccess,
//     required String title,
//     required String message,
//     bool showLoading = false,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: !showLoading,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         backgroundColor: Colors.white,
//         contentPadding: const EdgeInsets.all(20),
//         content: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 offset: Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               showLoading
//                   ? const CircularProgressIndicator()
//                   : Icon(
//                       isSuccess ? Icons.check_circle : Icons.error,
//                       color: isSuccess ? Colors.green : Colors.red,
//                       size: 50,
//                     ),
//               const SizedBox(height: 20),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: isSuccess ? Colors.green : Colors.red,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.black87,
//                 ),
//               ),
//               if (!showLoading) ...[
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (message.contains("kết nối") || message.contains("server")) ...[
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _saveChanges();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                         ),
//                         child: const Text(
//                           "Thử lại",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                     ],
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         if (isSuccess) {
//                           Get.back();
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isSuccess ? Colors.green : Colors.red,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                       ),
//                       child: const Text(
//                         "OK",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     ).then((_) {
//       if (!showLoading && !message.contains("kết nối") && !message.contains("server")) {
//         Future.delayed(const Duration(seconds: 5), () {
//           if (Navigator.of(context).canPop()) {
//             Navigator.of(context).pop();
//             if (isSuccess) {
//               Get.back();
//             }
//           }
//         });
//       }
//     });
//   }

//   bool _isAllowedFile(String filename) {
//     final extension = filename.split('.').last.toLowerCase();
//     return _allowedExtensions.contains(extension);
//   }

//   String _getMimeTypeFromExtension(String path) {
//     final extension = path.split('.').last.toLowerCase();
//     switch (extension) {
//       case 'png':
//         return 'image/png';
//       case 'jpg':
//       case 'jpeg':
//         return 'image/jpeg';
//       case 'gif':
//         return 'image/gif';
//       case 'webp':
//         return 'image/webp';
//       case 'bmp':
//         return 'image/bmp';
//       case 'tiff':
//         return 'image/tiff';
//       case 'heic':
//         return 'image/heic';
//       case 'heif':
//         return 'image/heif';
//       default:
//         return 'application/octet-stream';
//     }
//   }

//   String _formatFileSize(int sizeInBytes) {
//     if (sizeInBytes < 1024 * 1024) {
//       double sizeInKB = sizeInBytes / 1024;
//       return '${sizeInKB.toStringAsFixed(1)} KB';
//     } else {
//       double sizeInMB = sizeInBytes / (1024 * 1024);
//       return '${sizeInMB.toStringAsFixed(1)} MB';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthError) {
//           _showCustomDialog(
//             isSuccess: false,
//             title: "Lỗi",
//             message: state.message,
//           );
//         }
//         if (state is AvatarUpdated || state is UserProfileUpdated) {
//           final user = state is AvatarUpdated
//               ? (state as AvatarUpdated).user
//               : (state as UserProfileUpdated).user;
//           debugPrint('Profile updated: avatar_url=${user.avatarUrl}');
//           if (mounted) {
//             setState(() {
//               isFetching = true;
//               selectedAvatar = [];
//             });
//           }
//           if (state is AvatarUpdated && user.avatarUrl == null) {
//             _showCustomDialog(
//               isSuccess: false,
//               title: "Cảnh báo",
//               message: "Không thể cập nhật ảnh đại diện. Vui lòng thử lại.",
//             );
//           } else {
//             _showCustomDialog(
//               isSuccess: true,
//               title: "Thành công",
//               message: "Hồ sơ đã được cập nhật thành công. Đang tải dữ liệu mới...",
//               showLoading: true,
//             );
//             Future.delayed(const Duration(seconds: 1), () {
//               context.read<AuthBloc>().add(const GetUserProfileEvent());
//             });
//           }
//         }
//         if (state is UserProfileLoaded && isFetching) {
//           debugPrint('UserProfile loaded: avatar_url=${state.user.avatarUrl}');
//           if (mounted) {
//             setState(() {
//               isFetching = false;
//             });
//           }
//           Navigator.of(context).pop();
//           Get.back();
//         }
//       },
//       builder: (context, state) {
//         if (state is AuthLoading) {
//           return const Center(child: CircularProgressIndicator.adaptive());
//         }

//         final user = state is UserProfileLoaded ? state.user : null;

//         Widget avatarWidget;
//         if (selectedAvatar.isNotEmpty) {
//           final avatarData = selectedAvatar.first;
//           avatarWidget = FutureBuilder<Uint8List>(
//             future: avatarData.xFile!.readAsBytes(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const CircularProgressIndicator();
//               }
//               if (snapshot.hasData) {
//                 return CircleAvatar(
//                   radius: 50,
//                   backgroundImage: MemoryImage(snapshot.data!),
//                 );
//               }
//               return CircleAvatar(
//                 radius: 50,
//                 backgroundImage: user?.avatarUrl != null && !_hasNetworkImageError
//                     ? NetworkImage(user!.avatarUrl!)
//                     : null,
//                 onBackgroundImageError: user?.avatarUrl != null && !_hasNetworkImageError
//                     ? (exception, stackTrace) {
//                         debugPrint("Failed to load avatar: $exception");
//                         if (mounted) {
//                           setState(() {
//                             _hasNetworkImageError = true;
//                           });
//                         }
//                       }
//                     : null,
//                 child: _hasNetworkImageError || user?.avatarUrl == null
//                     ? const Icon(
//                         Icons.person,
//                         size: 50,
//                         color: Colors.grey,
//                       )
//                     : null,
//               );
//             },
//           );
//         } else {
//           avatarWidget = CircleAvatar(
//             radius: 50,
//             backgroundImage: user?.avatarUrl != null && !_hasNetworkImageError
//                 ? NetworkImage(user!.avatarUrl!)
//                 : null,
//             onBackgroundImageError: user?.avatarUrl != null && !_hasNetworkImageError
//                 ? (exception, stackTrace) {
//                     debugPrint("Failed to load avatar: $exception");
//                     if (mounted) {
//                       setState(() {
//                         _hasNetworkImageError = true;
//                       });
//                     }
//                   }
//                 : null,
//             child: _hasNetworkImageError || user?.avatarUrl == null
//                 ? const Icon(
//                     Icons.person,
//                     size: 50,
//                     color: Colors.grey,
//                   )
//                 : null,
//           );
//         }

//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//               SafeArea(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 10,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.arrow_back, color: Colors.black87),
//                               onPressed: () => Get.back(),
//                             ),
//                             const Expanded(
//                               child: Text(
//                                 "Chỉnh sửa hồ sơ",
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(16.0),
//                         margin: const EdgeInsets.symmetric(vertical: 16.0),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Colors.grey.withOpacity(0.3),
//                             width: 1.5,
//                           ),
//                         ),
//                         child: Stack(
//                           alignment: Alignment.bottomRight,
//                           children: [
//                             avatarWidget,
//                             InkWell(
//                               onTap: () {
//                                 if (mounted) {
//                                   setState(() {
//                                     isEditingAvatar = true;
//                                   });
//                                 }
//                                 _pickAvatar();
//                               },
//                               child: const CircleAvatar(
//                                 radius: 13,
//                                 backgroundColor: Color(0xFF00BF6D),
//                                 child: Icon(
//                                   Icons.add,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (isEditingAvatar) ...[
//                         const SizedBox(height: 8),
//                         Container(
//                           height: 120,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey, style: BorderStyle.solid, width: 1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Center(
//                             child: _isProcessingFiles
//                                 ? const CircularProgressIndicator()
//                                 : Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Icon(Icons.upload_file, size: 32, color: Colors.grey),
//                                       const SizedBox(height: 8),
//                                       const Text(
//                                         'Nhấn để chọn file',
//                                         style: TextStyle(color: Colors.grey),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Tối đa $maxFiles file, ảnh < ${maxImageSizeInBytes ~/ 1024 ~/ 1024} MB',
//                                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                       ],
//                       if (selectedAvatar.isNotEmpty) ...[
//                         const Text(
//                           'File đã chọn:',
//                           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         ...selectedAvatar.asMap().entries.map((entry) {
//                           int index = entry.key;
//                           ImageData media = entry.value;
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[100],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               children: [
//                                 FutureBuilder<Uint8List>(
//                                   future: media.xFile!.readAsBytes(),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState == ConnectionState.waiting) {
//                                       return const SizedBox(
//                                         width: 50,
//                                         height: 50,
//                                         child: Center(child: CircularProgressIndicator()),
//                                       );
//                                     }
//                                     if (snapshot.hasData) {
//                                       return ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: Image.memory(
//                                           snapshot.data!,
//                                           width: 50,
//                                           height: 50,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) => const Icon(
//                                             Icons.broken_image,
//                                             size: 50,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                     return const Icon(
//                                       Icons.broken_image,
//                                       size: 50,
//                                       color: Colors.grey,
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         media.xFile!.name,
//                                         style: const TextStyle(fontSize: 14),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       Text(
//                                         _formatFileSize(media.fileSize!),
//                                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.close, size: 20, color: Colors.red),
//                                   onPressed: () {
//                                     if (mounted) {
//                                       setState(() {
//                                         selectedAvatar = [];
//                                       });
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                         const SizedBox(height: 16),
//                       ],
//                       Divider(color: Colors.grey.withOpacity(0.3)),
//                       Form(
//                         child: Column(
//                           children: [
//                             _buildUserInfoEditField(
//                               text: "Họ và tên",
//                               child: TextFormField(
//                                 controller: nameController,
//                                 style: const TextStyle(color: Colors.black87),
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.grey.withOpacity(0.1),
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16.0 * 1.5, vertical: 16.0),
//                                   border: const OutlineInputBorder(
//                                     borderSide: BorderSide.none,
//                                     borderRadius: BorderRadius.all(Radius.circular(50)),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             _buildUserInfoEditField(
//                               text: "Email",
//                               child: TextFormField(
//                                 controller: emailController,
//                                 style: const TextStyle(color: Colors.black87),
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.grey.withOpacity(0.1),
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16.0 * 1.5, vertical: 16.0),
//                                   border: const OutlineInputBorder(
//                                     borderSide: BorderSide.none,
//                                     borderRadius: BorderRadius.all(Radius.circular(50)),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             _buildUserInfoEditField(
//                               text: "Số điện thoại",
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   TextFormField(
//                                     controller: phoneController,
//                                     style: const TextStyle(color: Colors.black87),
//                                     focusNode: phoneFocusNode,
//                                     onEditingComplete: () {
//                                       _validatePhone(phoneController.text);
//                                       FocusScope.of(context).nextFocus();
//                                     },
//                                     decoration: InputDecoration(
//                                       filled: true,
//                                       fillColor: Colors.grey.withOpacity(0.1),
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 16.0 * 1.5, vertical: 16.0),
//                                       border: const OutlineInputBorder(
//                                         borderSide: BorderSide.none,
//                                         borderRadius: BorderRadius.all(Radius.circular(50)),
//                                       ),
//                                     ),
//                                   ),
//                                   ValueListenableBuilder<String?>(
//                                     valueListenable: phoneError,
//                                     builder: (context, error, child) {
//                                       if (error == null) return const SizedBox.shrink();
//                                       return Padding(
//                                         padding: const EdgeInsets.only(top: 4.0, left: 16.0),
//                                         child: Text(
//                                           error,
//                                           style: const TextStyle(color: Colors.red, fontSize: 12),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             _buildUserInfoEditField(
//                               text: "Ngày sinh",
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: TextFormField(
//                                       enabled: false,
//                                       controller: birthdateController,
//                                       style: const TextStyle(color: Colors.black87),
//                                       decoration: InputDecoration(
//                                         filled: true,
//                                         fillColor: Colors.grey.withOpacity(0.1),
//                                         contentPadding: const EdgeInsets.symmetric(horizontal: 16.0 * 1.5, vertical: 16.0),
//                                         border: const OutlineInputBorder(
//                                           borderSide: BorderSide.none,
//                                           borderRadius: BorderRadius.all(Radius.circular(50)),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: _pickBirthdate,
//                                     icon: const Icon(Icons.calendar_today, color: Colors.black87),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             _buildUserInfoEditField(
//                               text: "CCCD",
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   TextFormField(
//                                     controller: cccdController,
//                                     style: const TextStyle(color: Colors.black87),
//                                     focusNode: cccdFocusNode,
//                                     onEditingComplete: () {
//                                       _validateCccd(cccdController.text);
//                                       FocusScope.of(context).nextFocus();
//                                     },
//                                     decoration: InputDecoration(
//                                       filled: true,
//                                       fillColor: Colors.grey.withOpacity(0.1),
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 16.0 * 1.5, vertical: 16.0),
//                                       border: const OutlineInputBorder(
//                                         borderSide: BorderSide.none,
//                                         borderRadius: BorderRadius.all(Radius.circular(50)),
//                                       ),
//                                     ),
//                                   ),
//                                   ValueListenableBuilder<String?>(
//                                     valueListenable: cccdError,
//                                     builder: (context, error, child) {
//                                       if (error == null) return const SizedBox.shrink();
//                                       return Padding(
//                                         padding: const EdgeInsets.only(top: 4.0, left: 16.0),
//                                         child: Text(
//                                           error,
//                                           style: const TextStyle(color: Colors.red, fontSize: 12),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           SizedBox(
//                             width: 120,
//                             child: ElevatedButton(
//                               onPressed: _isProcessingFiles ? null : () => Get.back(),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.grey.withOpacity(0.1),
//                                 foregroundColor: Colors.black87,
//                                 minimumSize: const Size(double.infinity, 48),
//                                 shape: const StadiumBorder(),
//                               ),
//                               child: const Text("Hủy"),
//                             ),
//                           ),
//                           const SizedBox(width: 16.0),
//                           ValueListenableBuilder(
//                             valueListenable: ValueNotifier<bool>(_hasErrors),
//                             builder: (context, hasErrors, child) {
//                               return SizedBox(
//                                 width: 160,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.blue,
//                                     foregroundColor: Colors.white,
//                                     minimumSize: const Size(double.infinity, 48),
//                                     shape: const StadiumBorder(),
//                                   ),
//                                   onPressed: (_isProcessingFiles || _hasErrors) ? null : _saveChanges,
//                                   child: const Text("Lưu thay đổi"),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildUserInfoEditField({
//     required String text,
//     required Widget child,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 8),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ImageData {
//   final File? file;
//   final XFile? xFile;
//   final Uint8List? bytes;
//   final String? mimeType;
//   final int? fileSize;
//   final String? filename;

//   ImageData({
//     this.file,
//     this.xFile,
//     this.bytes,
//     this.mimeType,
//     this.fileSize,
//     this.filename,
//   });
// }