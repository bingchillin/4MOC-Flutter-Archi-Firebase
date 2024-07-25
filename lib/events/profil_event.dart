part of '../blocs/profil_bloc.dart';

abstract class ProfilEvent {
  const ProfilEvent();
}

class LoadUserProfile extends ProfilEvent {
  final String userEmail;

  const LoadUserProfile({required this.userEmail});
}

class UpdateUserProfile extends ProfilEvent {
  final AppUser user;

  const UpdateUserProfile(this.user);
}
