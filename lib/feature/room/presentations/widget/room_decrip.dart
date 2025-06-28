import 'package:flutter/material.dart';
import '../../../../common/widgets/no_spell_check_text.dart';

class ExpandableDescription extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableDescription({super.key, required this.text, this.maxLines = 20});

  @override
  _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final showButton = widget.text.length > 150;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NoSpellCheckText(
          text: widget.text,
          maxLines: isExpanded ? null : widget.maxLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF374151),
            height: 1.6,
            fontSize: 15,
          ),
        ),
        if (showButton)
          TextButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              foregroundColor: Colors.blue[700],
              textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            child: NoSpellCheckText(
              text: isExpanded ? "Thu gọn" : "Xem thêm",
            ),
          ),
      ],
    );
  }
}
