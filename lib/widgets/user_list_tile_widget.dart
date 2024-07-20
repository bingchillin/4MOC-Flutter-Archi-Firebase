import 'package:flutter/material.dart';

class UserListTileWidget extends StatefulWidget {
  final String pseudo;
  final String email;
  final bool isFriend;
  final Future<void> Function()? onAddPressed;

  const UserListTileWidget({
    super.key,
    required this.pseudo,
    required this.email,
    required this.isFriend,
    this.onAddPressed,
  });

  @override
  _UserListTileWidgetState createState() => _UserListTileWidgetState();
}

class _UserListTileWidgetState extends State<UserListTileWidget> {
  bool _isLoading = false;
  bool _isFriend = false;

  _UserListTileWidgetState() : _isFriend = false;

  @override
  void initState() {
    super.initState();
    _isFriend = widget.isFriend; // Initialiser _isFriend avec la valeur passée au widget
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.pseudo),
      subtitle: Text(widget.email),
      trailing: _isFriend
          ? null
          : (_isLoading
          ? const CircularProgressIndicator()
          : IconButton(
        icon: const Icon(Icons.person_add),
        onPressed: () async {
          if (widget.onAddPressed != null) {
            setState(() => _isLoading = true);
            try {
              await widget.onAddPressed!();
              setState(() {
                _isFriend = true;
                _isLoading = false;
              });
            } catch (e) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors de l\'ajout du contact.'))
              );
            }
          }
        },
      )),
    );
  }
}