import 'package:flutter/material.dart';

class UserIcon extends StatelessWidget {
  const UserIcon({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const CircleAvatar(

        child: Icon(Icons.person),
      )
    );
  }
}
