import 'package:flutter/material.dart';

class UserListTileWidget extends StatelessWidget {
  final String pseudo;
  final String email;
  final bool isFriend;
  final VoidCallback? onAddPressed;

  const UserListTileWidget({
    super.key,
    required this.pseudo,
    required this.email,
    this.isFriend = false,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pseudo),
      subtitle: Text(email),
      trailing: isFriend
          ? null
          : IconButton(
        icon: const Icon(Icons.person_add),
        onPressed: onAddPressed,
      ),
    );
  }
}