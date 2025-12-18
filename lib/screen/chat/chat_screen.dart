import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/chat_message_model.dart';
import '../../api/ai_provider.dart';
import 'cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(message);
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          // Provider selector
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              final currentProvider = context.read<ChatCubit>().currentProvider;
              return PopupMenuButton<AIProvider>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      currentProvider == AIProvider.chatGPT
                          ? Icons.chat_bubble
                          : Icons.psychology,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentProvider.displayName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                tooltip: 'Select AI Provider',
                onSelected: (AIProvider provider) {
                  context.read<ChatCubit>().setProvider(provider);
                  context.read<ChatCubit>().clearChat();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Switched to ${provider.displayName}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<AIProvider>(
                    value: AIProvider.chatGPT,
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          size: 20,
                          color: currentProvider == AIProvider.chatGPT
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AIProvider.chatGPT.displayName,
                          style: TextStyle(
                            fontWeight: currentProvider == AIProvider.chatGPT
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (currentProvider == AIProvider.chatGPT) ...[
                          const Spacer(),
                          Icon(
                            Icons.check,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuItem<AIProvider>(
                    value: AIProvider.claude,
                    child: Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 20,
                          color: currentProvider == AIProvider.claude
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AIProvider.claude.displayName,
                          style: TextStyle(
                            fontWeight: currentProvider == AIProvider.claude
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (currentProvider == AIProvider.claude) ...[
                          const Spacer(),
                          Icon(
                            Icons.check,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<ChatCubit>().clearChat();
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.when(
                  initial: () => const Center(
                    child: Text(
                      'Start a conversation with AI',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (messages) => _buildMessagesList(messages),
                  sendingMessage: () => _buildMessagesList(context.read<ChatCubit>().messages),
                  messageSent: (message) => _buildMessagesList(context.read<ChatCubit>().messages),
                  error: (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Start a conversation with AI',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.smart_toy,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUser ? Colors.white : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI is typing...',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  : _buildMessageContent(context, message, isUser),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ChatMessage message, bool isUser) {
    final text = message.content;
    final chunkRegex = RegExp(r'(?:chunk|Chunk)[ _-]?(\d+)(?:\.txt)?');
    // Matches bracketed references that include a chunk mention, e.g. [4:0 chunk_0076.txt] or 【4:0 chunk_0076.txt】
    final bracketedAsciiRefRegex = RegExp(r'\[[^\]]*?(?:chunk|Chunk)[^\]]*?\]', caseSensitive: false);
    final bracketedUnicodeRefRegex = RegExp('【[^】]*?(?:chunk|Chunk)[^】]*?】', caseSensitive: false);

    final matches = chunkRegex.allMatches(text).toList();
    if (message.type == MessageType.ai && matches.isNotEmpty) {
      // Build unique list of file tokens preserving order
      final List<String> uniqueTokens = [];
      for (final m in matches) {
        final token = m.group(0)!; // e.g., chunk_0076.txt
        if (!uniqueTokens.contains(token)) uniqueTokens.add(token);
      }

      // Clean the visible text by removing inline bracketed chunk references (ASCII and Unicode forms)
      String cleanedText = text
          .replaceAll(bracketedAsciiRefRegex, '')
          .replaceAll(bracketedUnicodeRefRegex, '');
      // Collapse excessive whitespace created by removals
      cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ').trim();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cleanedText.isNotEmpty)
            Text(
              cleanedText,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < uniqueTokens.length; i++)
                _buildSourceCard(
                  context,
                  fileToken: uniqueTokens[i],
                  label: 'المصدر ${_toPersianDigits(i + 1)}',
                ),
            ],
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: isUser ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildSourceCard(BuildContext context, {required String fileToken, required String label}) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Open link for $fileToken')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.description, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toPersianDigits(int number) {
    const persianDigits = ['\u06F0','\u06F1','\u06F2','\u06F3','\u06F4','\u06F5','\u06F6','\u06F7','\u06F8','\u06F9'];
    final chars = number.toString().split('').map((c) {
      final d = int.tryParse(c);
      if (d == null) return c;
      return persianDigits[d];
    }).join();
    return chars;
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
