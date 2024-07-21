part of '../blocs/profil_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserViewMode extends UserState {}

class UserEditMode extends UserState {
}

class UserProfileLoaded extends UserState {
  final AppUser user;

  const UserProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}