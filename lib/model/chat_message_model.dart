import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required MessageType type,
    required DateTime timestamp,
    @Default(false) bool isLoading,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@JsonEnum()
enum MessageType {
  @JsonValue('user')
  user,
  @JsonValue('ai')
  ai,
}
