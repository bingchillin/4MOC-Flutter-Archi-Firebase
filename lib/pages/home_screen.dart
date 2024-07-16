import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter_firebase/profil_screen/profil_screen.dart';
import 'package:projet_flutter_firebase/pages/add_group_message_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = 'homeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // case: user not connected
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accueil'),
        ),
        body: const Center(
          child: Text('Utilisateur non connecté'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).pushNamed(ProfilScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('link_person_groupmessage').where('id_person', isEqualTo: user.email).get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Vous n\'avez pas encore de conversation'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String groupId = doc['id_groupmessage'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('group_message').doc(groupId).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> groupSnapshot) {
                  if (groupSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink(); // Ou un widget de chargement
                  }
                  if (groupSnapshot.hasError) {
                    return Text('Erreur : ${groupSnapshot.error}');
                  }
                  if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
                    return const SizedBox.shrink(); // Document non trouvé
                  }

                  // get messages group data
                  Map<String, dynamic> groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
                  String groupName = groupData['name'] ?? 'Nom inconnu';
                  String groupDescription = groupData['description'] ?? 'Description inconnue';

                  // display messages group data in list
                  return ListTile(
                    title: Text(groupName),
                    subtitle: Text(groupDescription),
                    onTap: () {
                      // pour naviguer après
                      // pas tester mais possiblement: Navigator.of(context).pushNamed(GroupDetailScreen.routeName, arguments: groupId);
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddGroupMessageScreen.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un groupe',
      ),
    );
  }
}
