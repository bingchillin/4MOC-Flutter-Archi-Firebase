import 'package:flutter/material.dart';
import 'package:projet_flutter_firebase/repository/app_repository.dart';
import '../../models/user.dart';
import '../repository/firebase_data_source/firebase_data_source.dart';

class AddGroupMessageScreen extends StatelessWidget {
  static const routeName = 'addGroupMessageScreen';

  const AddGroupMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRepository appRepository = AppRepository(remoteDataSource: FirebaseDataSource());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un groupe de messages'),
      ),
      body: FutureBuilder<String?>(
        future: appRepository.getCurrentUserEmail(), // Récupération de l'email de l'utilisateur actuel
        builder: (context, snapshotEmail) {
          if (snapshotEmail.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotEmail.hasError || snapshotEmail.data == null) {
            return const Center(child: Text('Impossible de récupérer l\'utilisateur actuel'));
          } else {
            return FutureBuilder<List<AppUser>>(
              future: appRepository.getAllUsers(), // Utilisation de AppRepository
              builder: (context, snapshotUsers) {
                if (snapshotUsers.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshotUsers.hasError) {
                  return Center(child: Text('Erreur: ${snapshotUsers.error}'));
                } else if (snapshotUsers.hasData) {
                  // Filtrage des utilisateurs pour exclure l'utilisateur connecté
                  final currentUserEmail = snapshotEmail.data!;
                  final users = snapshotUsers.data!.where((user) => user.email != currentUserEmail).toList();
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.pseudo),
                        subtitle: Text(user.email),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Aucun utilisateur trouvé'));
                }
              },
            );
          }
        },
      ),
    );
  }
}