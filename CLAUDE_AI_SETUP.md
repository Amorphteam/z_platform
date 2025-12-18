# Claude AI Integration Setup

## 🎉 Integration Complete!

Your AI service now supports both **ChatGPT** and **Claude AI**! Users can seamlessly switch between the two providers.

### ✅ What's Been Added:

1. **AI Provider Enum** (`lib/api/ai_provider.dart`)
   - Defines available AI providers (ChatGPT, Claude)
   - Provides display names for UI

2. **Enhanced AI Service** (`lib/api/ai_service.dart`)
   - Refactored to support multiple providers
   - Separate implementations for ChatGPT (Assistants API) and Claude (Messages API)
   - Provider selection with `AIService.provider`
   - Separate API keys for each provider

3. **Updated Chat Cubit** (`lib/screen/chat/cubit/chat_cubit.dart`)
   - Methods to set provider and API keys
   - Automatic conversation history management
   - Provider switching support

4. **UI Provider Selector** (`lib/screen/chat/chat_screen.dart`)
   - Dropdown menu in app bar to switch between providers
   - Visual indicators for current provider
   - Automatic chat clearing when switching providers

5. **Configuration** (`lib/util/constants.dart`)
   - Added `claudeApiKey` getter (optional, from environment)

### 🔧 Setup Instructions:

#### Step 1: Get Your Claude API Key

1. **Sign up for Anthropic**: Go to [console.anthropic.com](https://console.anthropic.com/)
2. **Create an API Key**: 
   - Navigate to API Keys section
   - Create a new API key
   - Copy the key (starts with `sk-ant-...`)

#### Step 2: Add Claude API Key to Environment

Add the Claude API key to your `.env` file:

```env
OPENAI_API_KEY=sk-your-openai-key-here
CLAUDE_API_KEY=sk-ant-your-claude-key-here
```

**Note**: The `CLAUDE_API_KEY` is optional. If not provided, only ChatGPT will be available.

#### Step 3: Test the Integration

1. Run your app: `flutter run`
2. Navigate to the chat screen
3. Click on the provider selector in the app bar (shows "ChatGPT" or "Claude")
4. Select your preferred provider
5. Send a test message

### 🚀 How to Use:

#### Switching Providers:

Users can switch between providers using the dropdown menu in the chat screen's app bar. The chat history is automatically cleared when switching to maintain context integrity.

#### Programmatic Usage:

```dart
// Set provider
AIService.provider = AIProvider.claude; // or AIProvider.chatGPT

// Set API keys
AIService.openAIApiKey = 'your-openai-key';
AIService.claudeApiKey = 'your-claude-key';

// Use the service
final aiService = AIService();
final response = await aiService.askQuestion('Hello!');
```

#### Via ChatCubit:

```dart
final chatCubit = ChatCubit();

// Initialize both API keys
chatCubit.setOpenAIApiKey('your-openai-key');
chatCubit.setClaudeApiKey('your-claude-key');

// Set provider
chatCubit.setProvider(AIProvider.claude);

// Test connection
final isConnected = await chatCubit.testAIConnection();
```

### 📝 Important Notes:

#### File Attachments & Vector Stores:

- **ChatGPT**: Uses OpenAI's Assistants API with vector stores for RAG (Retrieval Augmented Generation). Your EPUB files are stored in a vector store and can be queried.

- **Claude**: Currently uses the Messages API without file attachments. Claude supports file attachments, but it requires a different approach:
  - Files need to be uploaded first via the Files API
  - Then referenced in messages
  - This is different from OpenAI's vector store approach

**Current Behavior**:
- **ChatGPT**: Can answer questions about your EPUB content using the vector store
- **Claude**: Can answer general questions but doesn't have access to EPUB content yet

**Future Enhancement**: To add EPUB support for Claude, you would need to:
1. Upload EPUB content as files to Claude's API
2. Reference those files in messages
3. This requires additional implementation

### 🛠️ Features:

#### ✅ Working Features:
- ✅ Provider selection (ChatGPT/Claude)
- ✅ Separate API key management
- ✅ Conversation history per provider
- ✅ Language detection (AR/FA/EN)
- ✅ Poetry filtering (for ChatGPT with vector store)
- ✅ Error handling for both providers
- ✅ UI provider selector with visual indicators

#### ⚠️ Limitations:
- ⚠️ Claude doesn't have EPUB/vector store access yet (general questions only)
- ⚠️ ChatGPT requires vector store ID for EPUB content

### 🔍 API Differences:

| Feature | ChatGPT | Claude |
|---------|---------|--------|
| API Type | Assistants API v2 | Messages API |
| File Support | Vector Stores | File Uploads (not implemented) |
| Conversation | Threads/Runs | Direct Messages |
| Authentication | `Authorization: Bearer` | `x-api-key` header |
| Model | `gpt-4.1-mini` | `claude-3-5-sonnet-20241022` |

### 🐛 Troubleshooting:

#### "Claude API key not set" error:
- Make sure `CLAUDE_API_KEY` is in your `.env` file
- Verify the key is correct (starts with `sk-ant-`)

#### "OpenAI API key not set" error:
- Make sure `OPENAI_API_KEY` is in your `.env` file
- Verify the key is correct (starts with `sk-`)

#### Provider not switching:
- Check that both API keys are set
- Verify the provider is being set correctly: `AIService.provider = AIProvider.claude`

### 📚 Additional Resources:

- [Claude API Documentation](https://docs.anthropic.com/)
- [OpenAI Assistants API Documentation](https://platform.openai.com/docs/assistants)
- [Anthropic Console](https://console.anthropic.com/)

---

**Need Help?** If you encounter any issues, check:
1. API keys are correctly set in `.env`
2. Both providers are initialized in `route_generator.dart`
3. Network connectivity for API calls

