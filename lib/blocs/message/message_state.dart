part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessagesLoading extends MessageState {}

class MessagesLoadFailure extends MessageState {}

class MessagesLoadSuccess extends MessageState {
  final List<TextMessage> messages;

  MessagesLoadSuccess([this.messages = const []]);

  @override
  List<Object> get props => [messages];
}

class MessageSentSuccess extends MessageState {
  final TextMessage message;
  MessageSentSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSentFailure extends MessageState {}
