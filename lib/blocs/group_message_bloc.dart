import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../events/group_message_event.dart';
import '../states/group_message_state.dart';

class GroupMessageBloc extends Bloc<GroupMessageEvent, GroupMessageState> {
  final FirebaseFirestore firestore;

  GroupMessageBloc(this.firestore) : super(GroupMessageInitial()) {
    on<LoadGroupMessages>(_onLoadGroupMessages);
    on<AddGroupMessage>(_onAddGroupMessage);
  }

  void _onLoadGroupMessages(
      LoadGroupMessages event, Emitter<GroupMessageState> emit) async {
    emit(GroupMessageLoading());
    try {
      QuerySnapshot snapshot = await firestore.collection('group_message').get();
      List<Map<String, dynamic>> groupMessages = snapshot.docs
          .map((doc) => {'id': doc.id, 'data': doc.data() as Map<String, dynamic>})
          .toList();
      emit(GroupMessageLoaded(groupMessages));
    } catch (e) {
      emit(GroupMessageError(e.toString()));
    }
  }

  void _onAddGroupMessage(
      AddGroupMessage event, Emitter<GroupMessageState> emit) async {
    try {
      await firestore.collection('group_message').add({
        'name': event.name,
        'description': event.description,
      });
      add(LoadGroupMessages());
    } catch (e) {
      emit(GroupMessageError(e.toString()));
    }
  }
}
