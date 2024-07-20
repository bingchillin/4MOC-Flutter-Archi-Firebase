
import '../../models/user.dart';

abstract class RemoteDataSource {
  Future<AppUser> getUserProfil(String mail);
  Future<void> updateUserProfil(AppUser user);
  Future<String?> getCurrentUserEmail();
  Future<List<AppUser>> getAllUsers();
  Future<void> addContact(String currentUserId, String friendId);
  Future<List<String>> getUserContacts(String currentUserId);
  Future<void> blockUser(String currentUserId, String friendId);
  Future<void> unblockUser(String currentUserId, String friendId);

}