import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SettingsSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final Color bgColor, iconColor;
  final IconData icon;
  final Function(bool) onTap;

  const SettingsSwitch({
    super.key,
    required this.title,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
    this.value = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value ? "On" : "Off",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(
            width: 10,
          ),
          CupertinoSwitch(value: value, onChanged: onTap)
        ],
      ),
    );
  }
}
