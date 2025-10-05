import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../api/ai_service.dart';
import '../../../model/chat_message_model.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState.initial());
  
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService();
  
  List<ChatMessage> get messages => _messages;

  /// Initialize the AI service with API key
  set apiKey(String apiKey) {
    AIService.apiKey = apiKey;
  }

  /// Test AI connection
  Future<bool> testAIConnection() async => _aiService.testConnection();

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // Create user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    
    // Add user message to list
    _messages.add(userMessage);
    emit(ChatState.loaded(List.from(_messages)));
    
    // Create loading AI message
    final aiMessage = ChatMessage(
      id: const Uuid().v4(),
      content: '',
      type: MessageType.ai,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    
    _messages.add(aiMessage);
    emit(ChatState.sendingMessage());
    
    try {
      // Call AI service
      final aiResponseText = await _aiService.askQuestion(content.trim());
      
      // Replace loading message with actual AI response
      final aiResponse = aiMessage.copyWith(
        content: aiResponseText,
        isLoading: false,
      );
      
      final index = _messages.indexWhere((msg) => msg.id == aiMessage.id);
      if (index != -1) {
        _messages[index] = aiResponse;
      }
      
      emit(ChatState.loaded(List.from(_messages)));
    } catch (e) {
      // Remove loading message on error
      _messages.removeWhere((msg) => msg.id == aiMessage.id);
      emit(ChatState.error('Failed to get AI response: $e'));
    }
  }
  
  void clearChat() {
    _messages.clear();
    emit(const ChatState.initial());
  }
}
