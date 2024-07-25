part of '../blocs/profil_bloc.dart';

abstract class ProfilEvent extends Equatable {
  const ProfilEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends ProfilEvent {
  final String userEmail;

  const LoadUserProfile({required this.userEmail});

  @override
  List<Object> get props => [userEmail];
}

class UpdateUserProfile extends ProfilEvent {
  final AppUser user;

  const UpdateUserProfile(this.user);

  @override
  List<Object> get props => [user];
}
