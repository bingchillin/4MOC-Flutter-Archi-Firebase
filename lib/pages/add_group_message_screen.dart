import 'package:flutter/material.dart';
import 'package:projet_flutter_firebase/repository/firebase_data_source/firebase_data_source.dart';
import '../../models/user.dart';

class AddGroupMessageScreen extends StatelessWidget {
  static const routeName = 'addGroupMessageScreen';

  const AddGroupMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseDataSource dataSource = FirebaseDataSource();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un groupe de messages'),
      ),
      body: FutureBuilder<List<AppUser>>(
        future: dataSource.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot);
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.firstName),
                  subtitle: Text(user.email),
                );
              },
            );
          } else {
            return const Center(child: Text('Aucun utilisateur trouvé'));
          }
        },
      ),
    );
  }
}