part of 'message_bloc.dart';

abstract class MessageEvent {
  const MessageEvent();

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


}
