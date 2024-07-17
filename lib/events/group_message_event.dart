import 'package:equatable/equatable.dart';


abstract class GroupMessageEvent extends Equatable {
  const GroupMessageEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupMessages extends GroupMessageEvent {}

class AddGroupMessage extends GroupMessageEvent {
  final String name;
  final String description;

  const AddGroupMessage(this.name, this.description);

  @override
  List<Object> get props => [name, description];
}
