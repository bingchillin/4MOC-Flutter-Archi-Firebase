part of '../blocs/profil_bloc.dart';

enum ProfilStatus {
  initial,

  getUserProfile,
  successUserProfile,

  updateUserProfile,
  successUpdateUserProfile,

  errorUpdateUserProfile,
  errorLoadUserProfile,
}

class ProfilState {
  final ProfilStatus status;
  final AppUser? user;
  final Exception? error;

  const ProfilState({
      this.status=ProfilStatus.initial,
      this.user,
      this.error
  });

  ProfilState copyWith({
    ProfilStatus? status,
    AppUser? user,
    Exception? error,
  }) {
    return ProfilState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}