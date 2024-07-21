import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_flutter_firebase/profil_screen/profil_screen.dart';

class MyMessageDetailScreen extends StatelessWidget {
  static const routeName = 'my_message_detail_screen';

  Future<Map<String, String>> _fetchGroupContactPseudos(String groupId) async {
    Map<String, String> personPseudos = {};
    try {
      QuerySnapshot linkSnapshot = await FirebaseFirestore.instance
          .collection('link_person_groupmessage')
          .where('id_groupmessage', isEqualTo: groupId)
          .get();

      List<String> personEmails = linkSnapshot.docs.map((doc) {
        return doc['id_person'] as String;
      }).toList();

      for (String email in personEmails) {
        QuerySnapshot personSnapshot = await FirebaseFirestore.instance
            .collection('person')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (personSnapshot.docs.isNotEmpty) {
          DocumentSnapshot personDoc = personSnapshot.docs.first;
          String pseudo = personDoc['pseudo'] as String;
          personPseudos[email] = pseudo;
        } else {
          personPseudos[email] = email;
        }
      }
    } catch (e) {
      print('Error fetching group contact pseudonyms: $e');
    }
    return personPseudos;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String groupId = args['groupId'];
    final String groupName = args['groupName'];
    final String groupDescription = args['groupDescription'];

    final String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du groupe'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _fetchGroupContactPseudos(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun contact trouvé pour ce groupe'));
          }

          Map<String, String> personPseudos = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  groupDescription,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Text(
                  'Contacts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: personPseudos.length,
                    itemBuilder: (context, index) {
                      String email = personPseudos.keys.elementAt(index);
                      String pseudo = personPseudos[email]!;

                      return ListTile(
                        title: Text(email == currentUserEmail ? 'Moi' : pseudo),
                        onTap: () {
                          /*Navigator.of(context).pushNamed(
                            ProfilScreen.routeName,
                            arguments: {'email': email},
                          );*/
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
