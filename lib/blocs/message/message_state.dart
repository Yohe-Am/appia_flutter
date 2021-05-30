part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessagesLoading extends MessageState {}

class MessageSentSuccess extends MessageState {
  final Message message;
  MessageSentSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSentFailure extends MessageState {}

class MessagesLoadFailure extends MessageState {}

class MessagesLoadSuccess extends MessageState {
  final List<Message> messages;

  MessagesLoadSuccess([this.messages = const []]);

  @override
  List<Object> get props => [messages];
}

// TODO: Add it's own Bloc, ChatBloc
class ChatLoadSuccess extends MessageState {
  final List<Message> chats;

  ChatLoadSuccess([this.chats = const []]);

  @override
  List<Object> get props => [chats];
}

// TODO: Add it's own Bloc, ChatBloc
class ChatsLoadFailure extends MessageState {}
