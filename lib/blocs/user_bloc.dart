import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '../events/user_event.dart';
part '../states/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserViewMode());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is ToggleEditMode) {
      if (state is UserViewMode) {
        yield UserEditMode();
      } else {
        yield UserViewMode();
      }
    }
  }
}