import 'package:flutter/material.dart';
import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/widgets/no_spell_check_text.dart';

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
      margin: EdgeInsets.only(bottom: ResponsiveUtils.hp(context, 1.5)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.wp(context, 5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NoSpellCheckText(
                  text: "Phòng ${sanitize(room.name)}",
                  style: TextStyle(
                    fontSize: ResponsiveUtils.sp(context, 20), 
                    fontWeight: FontWeight.bold, 
                    color: const Color(0xFF22223B)
                  ),
                  semanticsLabel: "Phòng ${room.name}",
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.wp(context, 3), 
                    vertical: ResponsiveUtils.hp(context, 0.7)
                  ),
                  decoration: BoxDecoration(
                    color: (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFECACA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: NoSpellCheckText(
                    text: (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
                        ? 'Còn chỗ trống'
                        : 'Đã đầy',
                    style: TextStyle(
                      color: (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
                          ? const Color(0xFF047857)
                          : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.sp(context, 13),
                    ),
                    semanticsLabel: (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
                        ? 'Còn chỗ trống'
                        : 'Đã đầy',
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.hp(context, 1.2)),
            // Area
            if (room.areaDetails != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Color(0xFF6366F1)),
                  const SizedBox(width: 6),
                  NoSpellCheckText(
                    text: room.areaDetails!.name,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                    semanticsLabel: room.areaDetails!.name,
                  ),
                ],
              ),
            const SizedBox(height: 10),
            // Description
            const NoSpellCheckText(
              text: 'Mô tả:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
              semanticsLabel: 'Mô tả:',
            ),
            ExpandableDescription(text: sanitize(room.description ?? 'Không có mô tả')),
            const SizedBox(height: 14),
            // Details Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money, color: Color(0xFF059669), size: 18), // smaller icon
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const NoSpellCheckText(
                              text: 'Giá', 
                              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              semanticsLabel: 'Giá',
                            ),
                            NoSpellCheckText(
                              text: '${room.price.toString()} VND',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22223B), fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              semanticsLabel: '${room.price} VND',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8), // smaller spacing
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Color(0xFF2563EB), size: 18), // smaller icon
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const NoSpellCheckText(
                              text: 'Số người', 
                              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              semanticsLabel: 'Số người',
                            ),
                            NoSpellCheckText(
                              text: '${room.currentPersonNumber}/${room.capacity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22223B), fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              semanticsLabel: '${room.currentPersonNumber} trên ${room.capacity}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Available slots indicator
            if (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  border: Border.all(color: const Color(0xFF6EE7B7)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: NoSpellCheckText(
                  text: 'Còn ${room.capacity - room.currentPersonNumber} chỗ trống',
                  style: const TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.w600, fontSize: 14),
                  semanticsLabel: 'Còn ${room.capacity - room.currentPersonNumber} chỗ trống',
                ),
              ),            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    text: 'Xem ảnh',
                    onPressed: onShowImages,
                    buttonWidth: double.infinity,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    foregroundColor: const Color(0xFF2563EB),
                    textFontSize: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomElevatedButton(
                    text: (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
                        ? 'Đăng ký phòng'
                        : 'Hết chỗ',
                    onPressed: (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
                        ? onRegister
                        : () {}, // Disable bằng cách truyền hàm rỗng
                    buttonWidth: double.infinity,
                    backgroundColor: (room.status == 'AVAILABLE' && room.currentPersonNumber < room.capacity)
                        ? const Color(0xFF2563EB)
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    textFontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
