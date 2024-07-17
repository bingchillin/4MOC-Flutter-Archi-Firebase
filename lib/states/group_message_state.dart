import 'package:equatable/equatable.dart';

abstract class GroupMessageState extends Equatable {
  const GroupMessageState();

  @override
  List<Object> get props => [];
}

class GroupMessageInitial extends GroupMessageState {}

class GroupMessageLoading extends GroupMessageState {}

class GroupMessageLoaded extends GroupMessageState {
  final List<Map<String, dynamic>> groupMessages;

  const GroupMessageLoaded(this.groupMessages);

  @override
  List<Object> get props => [groupMessages];
}

class GroupMessageError extends GroupMessageState {
  final String message;

  const GroupMessageError(this.message);

  @override
  List<Object> get props => [message];
}
