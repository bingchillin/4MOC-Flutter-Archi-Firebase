
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
  Future<AppUser> getUserProfil(String mail) async {
    final userDoc = await _firebaseFirestore.collection('person').doc(mail).get();
    final user = AppUser.fromJson(userDoc.data()!, userDoc.id);
    return user;
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return _firebaseAuth.currentUser?.email;
  }

  @override
  Future<void> updateUserProfil(AppUser user) async {
    await _firebaseFirestore.collection('person').doc(user.email).set({
      'name': user.firstName,
      'pseudo': user.pseudo,
      'password': user.password,
      'description': user.description,
    });
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
      // Le contact existe déjà, gérer cette situation selon les besoins de l'application
      throw Exception("Le contact existe déjà.");
    }
  }

  @override
  Future<List<String>> getUserContacts(String currentUserId) async {
    final querySnapshot = await _firebaseFirestore.collection('contact')
        .where('id_person', isEqualTo: currentUserId)
        .where('is_friend', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()['id_person_c'] as String).toList();
  }
}