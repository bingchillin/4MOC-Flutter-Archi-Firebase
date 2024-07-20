import 'package:flutter/material.dart';

class UserListTileWidget extends StatefulWidget {
  final String pseudo;
  final String email;
  final bool isFriend;
  final Future<void> Function()? onAddPressed;
  final Future<void> Function()? onBlockPressed;

  const UserListTileWidget({
    super.key,
    required this.pseudo,
    required this.email,
    required this.isFriend,
    this.onAddPressed,
    this.onBlockPressed,
  });

  @override
  _UserListTileWidgetState createState() => _UserListTileWidgetState();
}

class _UserListTileWidgetState extends State<UserListTileWidget> {
  bool _isLoading = false;
  bool _isFriend = false;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _isFriend = widget.isFriend;
    _isBlocked = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget trailingWidget;

    if (_isBlocked) {
      trailingWidget = IconButton(
        icon: const Icon(Icons.block, color: Colors.red),
        onPressed: widget.onBlockPressed,
      );
    } else if (_isFriend) {
      trailingWidget = IconButton(
        icon: const Icon(Icons.block),
        onPressed: () async {
          if (widget.onBlockPressed != null) {
            setState(() => _isLoading = true);
            try {
              await widget.onBlockPressed!();
              setState(() {
                _isBlocked = true;
                _isLoading = false;
              });
            } catch (e) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors du blocage du contact.'))
              );
            }
          }
        },
      );
    } else {
      trailingWidget = _isLoading
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
      );
    }

    return ListTile(
      title: Text(widget.pseudo),
      subtitle: Text(widget.email),
      trailing: trailingWidget,
    );
  }
}