import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter_firebase/profil_screen/profil_screen.dart';
import 'package:projet_flutter_firebase/pages/add_group_message_screen.dart';
import 'package:projet_flutter_firebase/pages/my_message_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = 'homeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          if (user != null) ...[
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.of(context).pushNamed(ProfilScreen.routeName);
              },
            ),
          ],
        ],
      ),
      body: user == null
          ? _buildUserNotLoggedIn()
          : _buildGroupListView(user.email!, user.uid, context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddGroupMessageScreen.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un groupe',
      ),
    );
  }

  Widget _buildUserNotLoggedIn() {
    return const Center(child: Text('Utilisateur non connecté'));
  }

  Future<List<DocumentSnapshot>> _getUserGroups(String userEmail) async {
    try {
      QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('link_person_groupmessage')
          .where('id_person', isEqualTo: userEmail)
          .get();

      if (groupSnapshot.docs.isEmpty) {
        print('Aucun groupe trouvé pour l\'utilisateur $userEmail');
      }

      return groupSnapshot.docs;
    } catch (e) {
      print('Erreur lors de la récupération des groupes : $e');
      return [];
    }
  }

  Future<List<DocumentSnapshot>> _getGroupMembers(String groupId) async {
    try {
      QuerySnapshot memberSnapshot = await FirebaseFirestore.instance
          .collection('link_person_groupmessage')
          .where('id_groupmessage', isEqualTo: groupId)
          .get();

      if (memberSnapshot.docs.isEmpty) {
        print('Aucun membre trouvé pour le groupe $groupId');
      }
      print('membre trouvé pour le groupe $groupId: ');
      print(memberSnapshot.docs);

      return memberSnapshot.docs;
    } catch (e) {
      print('Erreur lors de la récupération des membres du groupe : $e');
      return [];
    }
  }

  Future<List<String>> _getBlockedUserEmails(String currentUserId) async {
    try {
      QuerySnapshot blockedSnapshot = await FirebaseFirestore.instance
          .collection('contact')
          .where('id_person', isEqualTo: currentUserId)
          .where('is_blocked', isEqualTo: true)
          .get();

      List<String> blockedUserIds = blockedSnapshot.docs.map((doc) {
        return doc['id_person_c'] as String;
      }).toList();

      if (blockedUserIds.isNotEmpty) {
        QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('person')
            .where(FieldPath.documentId, whereIn: blockedUserIds)
            .get();

        List<String> blockedUserEmails = usersSnapshot.docs.map((doc) {
          return doc['email'] as String;
        }).toList();

        return blockedUserEmails;
      }

      return [];
    } catch (e) {
      print('Erreur lors de la récupération des e-mails des utilisateurs bloqués : $e');
      return [];
    }
  }

  Future<bool> _isGroupPrivate(String groupId) async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('group_message')
          .doc(groupId)
          .get();

      if (!groupSnapshot.exists) {
        print('Groupe $groupId non trouvé');
        return false;
      }

      Map<String, dynamic> groupData = groupSnapshot.data() as Map<String, dynamic>;
      return groupData['private_channel'] ?? false;
    } catch (e) {
      print('Erreur lors de la récupération des détails du groupe : $e');
      return false;
    }
  }

  Widget _buildGroupListView(String userEmail, String userId, BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _getUserGroups(userEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Vous n\'avez pas encore de conversation'));
        }

        List<DocumentSnapshot> groups = snapshot.data!;

        return FutureBuilder<List<String>>(
          future: _getBlockedUserEmails(userId),
          builder: (context, blockedSnapshot) {
            if (blockedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (blockedSnapshot.hasError) {
              return Center(child: Text('Erreur : ${blockedSnapshot.error}'));
            }
            if (!blockedSnapshot.hasData) {
              return const Center(child: Text('Erreur lors de la récupération des e-mails des utilisateurs bloqués'));
            }

            List<String> blockedUserEmails = blockedSnapshot.data!;
            print('E-mails des utilisateurs bloqués : $blockedUserEmails');

            return FutureBuilder<List<Widget>>(
              future: Future.wait(groups.map((doc) async {
                String groupId = doc['id_groupmessage'] as String;
                bool isPrivate = await _isGroupPrivate(groupId);

                if (isPrivate) {
                  List<DocumentSnapshot> members = await _getGroupMembers(groupId);
                  bool isVisible = false; 

                  for (DocumentSnapshot memberDoc in members) {
                    String memberEmail = memberDoc['id_person'] as String;
                    if (memberEmail != userEmail && blockedUserEmails.contains(memberEmail)) {
                      print('Groupe $groupId filtré car membre avec email $memberEmail est bloqué.');
                      return const SizedBox.shrink(); // Cache le groupe
                    }
                    if (memberEmail == userEmail) {
                      isVisible = true;
                    }
                  }

                  return isVisible ? _createGroupListItem(groupId, context) : const SizedBox.shrink();
                } else {

                  return _createGroupListItem(groupId, context);
                }
              }).toList()),
              builder: (context, itemsSnapshot) {
                if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (itemsSnapshot.hasError) {
                  return Center(child: Text('Erreur : ${itemsSnapshot.error}'));
                }
                if (!itemsSnapshot.hasData || itemsSnapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun groupe à afficher.'));
                }

                List<Widget> groupItems = itemsSnapshot.data!;
                return ListView(children: groupItems);
              },
            );
          },
        );
      },
    );
  }

  Widget _createGroupListItem(String groupId, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('group_message')
          .doc(groupId)
          .get(),
      builder: (context, groupSnapshot) {
        if (groupSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (groupSnapshot.hasError) {
          return Text('Erreur : ${groupSnapshot.error}');
        }
        if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        Map<String, dynamic> groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
        String groupName = groupData['name'] ?? 'Nom inconnu';
        String groupDescription = groupData['description'] ?? 'Description inconnue';

        return ListTile(
          title: Text(groupName),
          subtitle: Text(groupDescription),
          onTap: () {
            Navigator.pushNamed(
              context,
              MyMessageScreen.routeName,
              arguments: {
                'groupId': groupId,
                'groupName': groupName,
                'groupDescription': groupDescription,
              },
            );
          },
        );
      },
    );
  }
}
