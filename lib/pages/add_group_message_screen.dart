import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter_firebase/repository/app_repository.dart';
import '../repository/firebase_data_source/firebase_data_source.dart';
import '../widgets/user_contacts_future_builder.dart';

class AddGroupMessageScreen extends StatelessWidget {
  static const routeName = 'addGroupMessageScreen';

  const AddGroupMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRepository appRepository = AppRepository(remoteDataSource: FirebaseDataSource());
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un groupe de messages'),
      ),
      body: FutureBuilder<String?>(
        future: appRepository.getCurrentUserEmail(),
        builder: (context, snapshotEmail) {
          if (snapshotEmail.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotEmail.hasError || snapshotEmail.data == null) {
            return const Center(child: Text('Impossible de récupérer l\'utilisateur actuel'));
          } else {
            return FutureBuilder<List<String>>(
              future: appRepository.getUserContacts(currentUserId!),
              builder: (context, snapshotContacts) {
                if (snapshotContacts.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshotContacts.hasError || !snapshotContacts.hasData) {
                  return const Center(child: Text('Impossible de récupérer les contacts de l\'utilisateur'));
                } else {
                  final contacts = snapshotContacts.data!;
                  return UserContactsFutureBuilder(
                    appRepository: appRepository,
                    currentUserId: currentUserId,
                    contacts: contacts,
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}