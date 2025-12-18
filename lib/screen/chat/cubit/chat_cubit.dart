import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../api/ai_service.dart';
import '../../../api/ai_provider.dart';
import '../../../model/chat_message_model.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState.initial());
  
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService();
  
  List<ChatMessage> get messages => _messages;

  /// Initialize the AI service with API key (legacy method for backward compatibility)
  set apiKey(String apiKey) {
    AIService.apiKey = apiKey;
  }

  /// Set the AI provider (ChatGPT or Claude)
  void setProvider(AIProvider provider) {
    AIService.provider = provider;
    // Clear conversation history when switching providers
    AIService.clearConversationHistory();
  }

  /// Get the current AI provider
  AIProvider get currentProvider => AIService.provider;

  /// Initialize OpenAI API key
  void setOpenAIApiKey(String apiKey) {
    AIService.openAIApiKey = apiKey;
  }

  /// Initialize Claude API key
  void setClaudeApiKey(String apiKey) {
    AIService.claudeApiKey = apiKey;
  }

  /// Test AI connection for the current provider
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
    AIService.clearConversationHistory();
    emit(const ChatState.initial());
  }
}
