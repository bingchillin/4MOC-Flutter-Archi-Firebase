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
    on<ToggleEditMode>(_onToggleEditMode);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<LoadCurrentUserProfile>(_onLoadCurrentUserProfile);
  }

  void _onToggleEditMode(ToggleEditMode event, Emitter<ProfilState> emit) {
    if (state.status == ProfilStatus.viewMode) {
      emit(state.copyWith(status: ProfilStatus.editMode));
    } else {
      emit(state.copyWith(status: ProfilStatus.viewMode));
    }
  }

  Future<void> _onLoadUserProfile(LoadUserProfile event, Emitter<ProfilState> emit) async {
    try {
      emit(state.copyWith(status: ProfilStatus.loadUserProfile));
      final user = await repository.getUserProfil(event.userEmail);
      emit(state.copyWith(status: ProfilStatus.successUserProfile, user: user));
    } catch (e) {
      emit(state.copyWith(status: ProfilStatus.errorLoadUserProfile, error: e as Exception));
    }
  }

  Future<void> _onLoadCurrentUserProfile(LoadCurrentUserProfile event, Emitter<ProfilState> emit) async {
    try {
      emit(state.copyWith(status: ProfilStatus.loadUserProfile));
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final profile = await repository.getUserProfil(user.email!);
        emit(state.copyWith(status: ProfilStatus.successUserProfile, user: profile));
      } else {
        emit(state.copyWith(status: ProfilStatus.viewMode, error: Exception("No user signed in"))); // Handle error appropriately
      }
    } catch (e) {
      emit(state.copyWith(status: ProfilStatus.errorLoadUserProfile, error: e as Exception)); // Handle error appropriately
    }
  }
}
