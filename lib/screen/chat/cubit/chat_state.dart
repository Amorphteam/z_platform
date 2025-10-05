part of 'chat_cubit.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.loaded(List<ChatMessage> messages) = _Loaded;
  const factory ChatState.sendingMessage() = _SendingMessage;
  const factory ChatState.messageSent(ChatMessage message) = _MessageSent;
  const factory ChatState.error(String message) = _Error;
}
