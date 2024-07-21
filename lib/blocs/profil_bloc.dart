import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/app_repository.dart';
import '../models/user.dart';

part '../events/profil_event.dart';
part '../states/profil_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AppRepository repository;

  UserBloc(this.repository) : super(UserViewMode());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is ToggleEditMode) {
      if (state is UserViewMode) {
        yield UserEditMode();
      } else {
        yield UserViewMode();
      }
    } else if (event is LoadUserProfile) {
      yield* _mapLoadUserProfileToState(event);
    } else if (event is LoadCurrentUserProfile) {
      yield* _mapLoadCurrentUserProfileToState();
    }
  }

  Stream<UserState> _mapLoadUserProfileToState(LoadUserProfile event) async* {
    try {
      final user = await repository.getUserProfil(event.userEmail);
      yield UserProfileLoaded(user);
    } catch (e) {
      yield UserViewMode(); // Handle error appropriately
    }
  }

  Stream<UserState> _mapLoadCurrentUserProfileToState() async* {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final profile = await repository.getUserProfil(user.email!);
        yield UserProfileLoaded(profile);
      } else {
        yield UserViewMode(); // Handle error appropriately
      }
    } catch (e) {
      yield UserViewMode(); // Handle error appropriately
    }
  }
}
