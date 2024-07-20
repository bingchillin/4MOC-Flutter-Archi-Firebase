import 'package:projet_flutter_firebase/models/user.dart';

import 'firebase_data_source/remote_data_source.dart';

class AppRepository{
  final RemoteDataSource remoteDataSource;

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

  Future<void> addContact(String currentUserId, String friendId) async {
    return remoteDataSource.addContact(currentUserId, friendId);
  }

  Future<List<String>> getUserContacts(String currentUserId) async {
    return remoteDataSource.getUserContacts(currentUserId);
  }
}