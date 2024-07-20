import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter_firebase/repository/app_repository.dart';
import '../models/user.dart';
import 'user_list_tile_widget.dart';

class UserContactsFutureBuilder extends StatelessWidget {
  final AppRepository appRepository;
  final String currentUserId;
  final List<String> contacts;

  const UserContactsFutureBuilder({
    super.key,
    required this.appRepository,
    required this.currentUserId,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
      future: appRepository.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final users = snapshot.data!.where((user) => user.email != FirebaseAuth.instance.currentUser?.email).toList();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => _buildUserTile(context, users[index]),
          );
        } else {
          return const Center(child: Text('Aucun utilisateur trouvé'));
        }
      },
    );
  }

  Widget _buildUserTile(BuildContext context, AppUser user) {
    final isFriend = contacts.contains(user.id);
    return UserListTileWidget(
      pseudo: user.pseudo,
      email: user.email,
      isFriend: isFriend,
      onAddPressed: isFriend ? null : () => _addUserToContacts(context, user.id),
      onBlockPressed: isFriend ? () => _removeUserFromContacts(context, user.id) : null,
    );
  }

  Future<void> _addUserToContacts(BuildContext context, String userId) async {
    try {
      await appRepository.addContact(currentUserId, userId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact ajouté avec succès.')));
      contacts.add(userId);
      (context as Element).markNeedsBuild();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'ajout du contact.')));
    }
  }

  Future<void> _removeUserFromContacts(BuildContext context, String userId) async {
    try {
      await appRepository.blockUser(currentUserId, userId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact bloqué avec succès.')));
      contacts.remove(userId);
      (context as Element).markNeedsBuild();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du blocage du contact.')));
    }
  }
}