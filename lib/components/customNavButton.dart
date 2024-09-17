import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBackgroundColor;
  final IconData trailingIcon;

  const CustomListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackgroundColor = const Color(0xFFc5e5d6),
    this.trailingIcon = Icons.arrow_right_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(55)),
      horizontalTitleGap: 30,
      contentPadding: const EdgeInsets.all(20),
      leading: Container(
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Icon(
            leadingIcon,
            color: Colors.green,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: Icon(trailingIcon),
      tileColor: Colors.white,
      minVerticalPadding: 6, // Or use minVerticalPadding
    );
  }
}
