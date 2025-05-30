import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EditItem extends StatelessWidget {
  final Widget widget;
  final String title;
  final Function() onPressed;
  final bool changeIcon, canEdit;

  const EditItem({
    super.key,
    required this.widget,
    required this.title,
    required this.onPressed,
    this.changeIcon = true,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            )),
        const SizedBox(width: 40),
        Expanded(
          flex: 4,
          child: widget,
        ),
        canEdit
            ? Expanded(
          child: IconButton(
            onPressed: () {
              onPressed();
            },
            icon: Icon(changeIcon ? Ionicons.checkmark : Ionicons.pencil),
          ),
        )
            : const SizedBox(width: 30),
      ],
    );
  }
}
