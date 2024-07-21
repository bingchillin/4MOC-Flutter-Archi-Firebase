import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter_firebase/models/user.dart';

import 'firebase_data_source/remote_data_source.dart';

class AppRepository{
  final RemoteDataSource remoteDataSource;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  AppRepository({
    required this.remoteDataSource,
  });

  Future<AppUser> getUserProfil(String mail) async {
    return remoteDataSource.getUserProfil(mail);
  }

  Future<void> updateUserProfil(AppUser user) async {
    return remoteDataSource.updateUserProfil(user);
  }

  Future<String?> getCurrentUserEmail() async {
    return remoteDataSource.getCurrentUserEmail();
  }

  Future<List<AppUser>> getAllUsers() async {
    return remoteDataSource.getAllUsers();
  }

  Future<List<String>> getUserContacts(String currentUserId) async {
    return remoteDataSource.getUserContacts(currentUserId);
  }

  Future<void> addContact(String currentUserId, String friendId) async {
    return remoteDataSource.addContact(currentUserId, friendId);
  }

  Future<void> blockUser(String currentUserId, String friendId) async {
    return remoteDataSource.blockUser(currentUserId, friendId);
  }

  Future<void> unblockUser(String currentUserId, String friendId) async {
    return remoteDataSource.unblockUser(currentUserId, friendId);
  }

  Future<List<String>> getBlockedContacts(String currentUserId) async {
    return remoteDataSource.getBlockedContacts(currentUserId);
  }

}