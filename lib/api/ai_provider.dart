/// Enum to represent different AI providers
enum AIProvider {
  chatGPT,
  claude,
}

extension AIProviderExtension on AIProvider {
  String get displayName {
    switch (this) {
      case AIProvider.chatGPT:
        return 'ChatGPT';
      case AIProvider.claude:
        return 'Claude';
    }
  }
}

