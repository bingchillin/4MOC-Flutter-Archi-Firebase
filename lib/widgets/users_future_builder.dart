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
            itemBuilder: (context, index) {
              final user = users[index];
              final isFriend = contacts.contains(user.id);
              return UserListTileWidget(
                pseudo: user.pseudo,
                email: user.email,
                isFriend: isFriend,
                onAddPressed: isFriend ? null : () async {
                  try {
                    await appRepository.addContact(currentUserId, user.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact ajouté avec succès.')));
                    // Mise à jour de l'état pour refléter le changement dans l'interface utilisateur
                    contacts.add(user.id); // Ajoute l'ID de l'utilisateur aux contacts pour mettre à jour l'état localement
                    (context as Element).markNeedsBuild(); // Demande à Flutter de reconstruire l'interface utilisateur avec les nouvelles données
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'ajout du contact.')));
                  }
                },
              );
            },
          );
        } else {
          return const Center(child: Text('Aucun utilisateur trouvé'));
        }
      },
    );
  }
}