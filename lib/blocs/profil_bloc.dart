import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/app_repository.dart';
import '../models/user.dart';

part '../events/profil_event.dart';
part '../states/profil_state.dart';

class UserBloc extends Bloc<ProfilEvent, ProfilState> {
  final AppRepository repository;

  UserBloc(this.repository) : super(const ProfilState()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(LoadUserProfile event, Emitter<ProfilState> emit) async {
    try {
      emit(state.copyWith(status: ProfilStatus.getUserProfile));
      final user = await repository.getUserProfil(event.userEmail);
      emit(state.copyWith(status: ProfilStatus.successUserProfile, user: user));
    } catch (e) {
      emit(state.copyWith(status: ProfilStatus.errorLoadUserProfile, error: e as Exception));
    }
  }

  Future<void> _onUpdateUserProfile(UpdateUserProfile event, Emitter<ProfilState> emit) async {
    try {
      emit(state.copyWith(status: ProfilStatus.updateUserProfile));
      await repository.updateUserProfil(event.user);
      emit(state.copyWith(status: ProfilStatus.successUpdateUserProfile, user: event.user));
    } catch (e) {
      emit(state.copyWith(status: ProfilStatus.errorUpdateUserProfile, error: e as Exception));
    }
  }
}
