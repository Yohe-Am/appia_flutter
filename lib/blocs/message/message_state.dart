part of 'message_bloc.dart';

abstract class MessageState {
  const MessageState();
}

class MessagesLoading extends MessageState {}

class MessagesLoadFailure extends MessageState {}

class MessagesLoadSuccess extends MessageState {
  final List<TextMessage> messages;

  MessagesLoadSuccess([this.messages = const []]);
}

class MessageSentSuccess extends MessageState {
  final TextMessage message;
  MessageSentSuccess(this.message);
}

class MessageSentFailure extends MessageState {}
