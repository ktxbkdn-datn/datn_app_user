import 'package:flutter/material.dart';

import 'forward_button.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? value;
  final Color bgColor, iconColor;
  final IconData icon;
  final Function() onTap;
  const SettingsItem({
    super.key, required this.title, required this.bgColor, required this.iconColor, required this.icon, required this.onTap, this.value,
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
            child: Icon(icon, color: iconColor,),
          ),
          const SizedBox(width: 20,),
          Text(title,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
          const Spacer(),
          value!= null?Text(value!,style:const TextStyle(fontSize: 17, color: Colors.grey),)
                        : SizedBox(width: 20,),
          const SizedBox(width: 10,),
          ForwardButton(onTap: onTap,),
        ],
      ),
    );
  }
}


