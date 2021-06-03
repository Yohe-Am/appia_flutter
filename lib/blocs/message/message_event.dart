part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class SendMessage extends MessageEvent {
  final TextMessage message;

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];

  @override
  toString() => 'Message sent {message: $message}';
}

class LoadMessages extends MessageEvent {
  const LoadMessages();

  @override
  List<Object> get props => [];
}
