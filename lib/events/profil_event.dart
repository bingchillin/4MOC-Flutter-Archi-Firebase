part of '../blocs/profil_bloc.dart';

abstract class ProfilEvent extends Equatable {
  const ProfilEvent();

  @override
  List<Object> get props => [];
}

class ToggleEditMode extends ProfilEvent {}

class LoadUserProfile extends ProfilEvent {
  final String userEmail;

  LoadUserProfile(this.userEmail);

  @override
  List<Object> get props => [userEmail];
}

class LoadCurrentUserProfile extends ProfilEvent {}
