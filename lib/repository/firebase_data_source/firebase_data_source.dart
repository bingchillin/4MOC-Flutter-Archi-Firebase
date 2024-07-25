import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_flutter_firebase/repository/firebase_data_source/remote_data_source.dart';

import '../../models/user.dart';

class FirebaseDataSource extends RemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<List<AppUser>> getAllUsers() async {
    final querySnapshot = await _firebaseFirestore.collection('person').get();
    final users = querySnapshot.docs.map((doc) {
      return AppUser.fromJson(doc.data(), doc.id);
    }).toList();
    return users;
  }

  @override
  Future<AppUser> getUserProfil(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('person')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data();
        return AppUser.fromJson(
          data,
          docSnapshot.id,
        );
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }


  @override
  Future<String?> getCurrentUserEmail() async {
    return _firebaseAuth.currentUser?.email;
  }

  @override
  Future<void> updateUserProfil(AppUser user) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('person')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    await _firebaseFirestore.collection('person').doc(querySnapshot.docs.first.id).update({
      'prenom': user.firstName,
      'pseudo': user.pseudo,
      'password': user.password,
      'description': user.description,
    });
  }

  @override
  Future<List<String>> getUserContacts(String currentUserId) async {
    final querySnapshot = await _firebaseFirestore
        .collection('contact')
        .where('id_person', isEqualTo: currentUserId)
        .where('is_friend', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['id_person_c'] as String)
        .toList();
  }

  @override
  Future<List<String>> getBlockedContacts(String currentUserId) async {
    final querySnapshot = await _firebaseFirestore
        .collection('contact')
        .where('id_person', isEqualTo: currentUserId)
        .where('is_blocked', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['id_person_c'] as String)
        .toList();
  }

  @override
  Future<void> addContact(String currentUserId, String friendId) async {
    // Vérifier si le contact existe déjà
    final querySnapshot = await _firebaseFirestore
        .collection('contact')
        .where('id_person', isEqualTo: currentUserId)
        .where('id_person_c', isEqualTo: friendId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Le contact n'existe pas, donc on peut l'ajouter
      await _firebaseFirestore.collection('contact').add({
        'id_person': currentUserId,
        'id_person_c': friendId,
        'is_blocked': false,
        'is_friend': true,
      });
    } else {
      throw Exception("Le contact existe déjà.");
    }
  }

  @override
  Future<void> blockUser(String currentUserId, String friendId) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('contact')
          .where('id_person', isEqualTo: currentUserId)
          .where('id_person_c', isEqualTo: friendId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _firebaseFirestore
            .collection('contact')
            .doc(querySnapshot.docs.first.id)
            .update({'is_blocked': true});
      } else {
        print("Le contact n'existe pas ou a déjà été bloqué.");
      }
    } catch (e) {
      print("Erreur lors du blocage de l'utilisateur : $e");
    }
  }

  @override
  Future<void> unblockUser(String currentUserId, String friendId) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('contact')
          .where('id_person', isEqualTo: currentUserId)
          .where('id_person_c', isEqualTo: friendId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _firebaseFirestore
            .collection('contact')
            .doc(querySnapshot.docs.first.id)
            .update({'is_blocked': false});
      } else {
        print("Le contact n'existe pas.");
      }
    } catch (e) {
      print("Erreur lors du déblocage de l'utilisateur : $e");
    }
  }

  @override
  Future<void> createGroupMessage(String groupName, List<String> emails) async {
    final docRef = await _firebaseFirestore.collection('group_message').add({
      'name': groupName,
      'description': "Discussion avec $groupName",
      'private_channel': emails.length == 2,
      'participants': emails,
    });

    // Adding to link_person_groupmessage collection
    for (var email in emails) {
      await _firebaseFirestore.collection('link_person_groupmessage').add({
        'id_groupmessage': docRef.id,
        'id_person': email,
      });
    }
  }

  @override
  Future<bool> privateConversationExists(String user1Email, String user2Email) async {
    final querySnapshot = await _firebaseFirestore
        .collection('group_message')
        .where('private_channel', isEqualTo: true)
        .where('participants', arrayContainsAny: [user1Email, user2Email])
        .get();

    for (var doc in querySnapshot.docs) {
      final List<dynamic> participants = doc['participants'];
      if (participants.contains(user1Email) && participants.contains(user2Email)) {
        return true;
      }
    }
    return false;
  }

}
