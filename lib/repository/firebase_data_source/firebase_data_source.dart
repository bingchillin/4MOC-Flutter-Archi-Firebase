
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_flutter_firebase/repository/firebase_data_source/remote_data_source.dart';

import '../../models/user.dart';

class FirebaseDataSource extends RemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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
  Future<AppUser> getUserProfil(String mail) async {
    final userDoc = await _firebaseFirestore.collection('person').doc(mail).get();
    final user = AppUser.fromJson(userDoc.data()!, userDoc.id);
    return user;
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final querySnapshot = await _firebaseFirestore.collection('person').get();
    final users = querySnapshot.docs.map((doc) {
      return AppUser.fromJson(doc.data(), doc.id);
    }).toList();
    return users;
  }
}