import 'package:flutter/material.dart';

class UserListTileWidget extends StatefulWidget {
  final String pseudo;
  final String email;
  final bool isFriend;
  final bool isBlocked;
  final bool isSelected;
  final Function(bool)? onSelectedChanged;
  final Future<void> Function()? onAddPressed;
  final Future<void> Function()? onBlockPressed;

  const UserListTileWidget({
    super.key,
    required this.pseudo,
    required this.email,
    required this.isFriend,
    required this.isBlocked,
    this.isSelected = false,
    this.onSelectedChanged,
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
    _isBlocked = widget.isBlocked;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.pseudo),
      subtitle: Text(widget.email),
      trailing: _isLoading ? const CircularProgressIndicator() : _buildTrailingIcon(),
      tileColor: widget.isSelected ? Colors.grey[300] : null,
      onTap: () {
        widget.onSelectedChanged?.call(!widget.isSelected);
      },
    );
  }

  Widget _buildTrailingIcon() {
    if (_isBlocked) {
      return IconButton(
          icon: const Icon(Icons.block, color: Colors.red),
          onPressed: _isLoading ? null : _handleUnblockUser);
    } else if (_isFriend) {
      return IconButton(
          icon: const Icon(Icons.block),
          onPressed: _isLoading ? null : _handleBlockUser);
    } else {
      return IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: _isLoading ? null : _handleAddUser);
    }
  }

  void _handleAddUser() async {
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
            const SnackBar(content: Text('Erreur lors de l\'ajout du contact.')));
      }
    }
  }

  void _handleBlockUser() async {
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
            const SnackBar(content: Text('Erreur lors du blocage du contact.')));
      }
    }
  }

  void _handleUnblockUser() async {
    if (widget.onBlockPressed != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onBlockPressed!();
        setState(() {
          _isBlocked = false;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors du déblocage du contact.')));
      }
    }
  }
}
