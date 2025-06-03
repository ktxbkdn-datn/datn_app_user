import 'package:flutter/material.dart';

import '../../domain/entities/room_entity.dart';
import '../widget/room_decrip.dart';
import '../../../../common/widgets/custom_elevated.dart';

class RoomItemWidget extends StatelessWidget {
  final RoomEntity room;
  final String Function(String) sanitize;
  final VoidCallback onShowImages;
  final VoidCallback onRegister;

  const RoomItemWidget({
    Key? key,
    required this.room,
    required this.sanitize,
    required this.onShowImages,
    required this.onRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
             "Phòng "+ sanitize(room.name),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Mô tả:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ExpandableDescription(text: sanitize(room.description ?? 'Không có mô tả')),
            const SizedBox(height: 5),
            Text(
              'Giá: ${room.price} VND',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              'Số người: ${room.currentPersonNumber}/${room.capacity}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Trạng thái: ${room.status == 'AVAILABLE' ? 'Còn chỗ trống' : 'Đang cho thuê'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: room.status == 'AVAILABLE' ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomElevatedButton(
                  text: 'Xem ảnh',
                  onPressed: onShowImages,
                  buttonWidth: (MediaQuery.of(context).size.width - 80) / 2,
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  textFontSize: 15,
                ),
            
                CustomElevatedButton(
                  text: 'Đăng ký xem phòng',
                  onPressed: onRegister,
                  buttonWidth: (MediaQuery.of(context).size.width - 80) / 2,
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  textFontSize: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}