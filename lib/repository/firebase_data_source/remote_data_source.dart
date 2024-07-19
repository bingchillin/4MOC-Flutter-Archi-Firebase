
import '../../models/user.dart';

abstract class RemoteDataSource {
  Future<AppUser> getUserProfil(String mail);
  Future<void> updateUserProfil(AppUser user);
  Future<String?> getCurrentUserEmail();
  Future<List<AppUser>> getAllUsers();
}