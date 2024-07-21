part of '../blocs/profil_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class ToggleEditMode extends UserEvent {}

class LoadUserProfile extends UserEvent {
  final String userEmail;

  LoadUserProfile(this.userEmail);

  @override
  List<Object> get props => [userEmail];
}

class LoadCurrentUserProfile extends UserEvent {}
