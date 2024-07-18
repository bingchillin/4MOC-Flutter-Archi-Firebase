part of '../blocs/profil_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class ToggleEditMode extends UserEvent {}
