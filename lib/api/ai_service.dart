import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'ai_provider.dart';

class AIService {
  // ====== Config ======
  static AIProvider provider = AIProvider.chatGPT;
  static String openAIModel = 'gpt-4.1-mini';
  static String claudeModel = 'claude-3-5-sonnet-20241022'; // Latest Claude model
  static String? vectorStoreId = 'vs_68ec99dc0ab08191bed6cbbfbdb75e7a'; // set once from outside
  static String? _openAIApiKey;
  static String? _claudeApiKey;

  static bool _isInitialized = false;

  // Cache: one assistant per language so each has proper instructions (OpenAI only)
  static final Map<String, String> _assistantIdByLang = {};
  static String? _threadId; // reuse a single thread (optional, OpenAI only)

  // Conversation history for Claude (since it uses Messages API directly)
  static final List<Map<String, dynamic>> _claudeConversationHistory = [];

  // ====== Init ======
  static set openAIApiKey(String apiKey) {
    _openAIApiKey = apiKey;
    _isInitialized = true;
  }

  static set claudeApiKey(String apiKey) {
    _claudeApiKey = apiKey;
    _isInitialized = true;
  }

  // Legacy setter for backward compatibility
  static set apiKey(String apiKey) {
    if (provider == AIProvider.claude) {
      _claudeApiKey = apiKey;
    } else {
      _openAIApiKey = apiKey;
    }
    _isInitialized = true;
  }

  // ---------------- Language detection (light heuristics) ----------------
  static const String _persianOnlyChars = "گچپژکۀی۰۱۲۳۴۵۶۷۸۹";
  static const String _arabicOnlyChars  = "أإآةى٠١٢٣٤٥٦٧٨٩";
  static final RegExp _arabicScript = RegExp(r'[\u0600-\u06FF]');
  static final RegExp _latinLetters = RegExp(r'[A-Za-z]');


  Future<bool> testConnection() async {
    if (!_isInitialized) return false;
    
    if (provider == AIProvider.claude) {
      if (_claudeApiKey == null) return false;
      try {
        // Simple auth probe for Claude
        final uri = Uri.parse('https://api.anthropic.com/v1/messages');
        final body = {
          'model': claudeModel,
          'max_tokens': 1,
          'messages': [
            {'role': 'user', 'content': 'test'}
          ]
        };
        final r = await _postClaude(uri, body);
        return r.statusCode == 200 || r.statusCode == 400; // 400 is OK for auth test
      } catch (_) {
        return false;
      }
    } else {
      if (_openAIApiKey == null) return false;
      try {
        // Simple auth probe that costs $0 in tokens.
        final uri = Uri.parse('https://api.openai.com/v1/assistants?limit=1');
        final r = await _get(uri);
        return r.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }

  bool _isPersian(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    if (t.split('').any((ch) => _persianOnlyChars.contains(ch))) return true;
    if (t.split('').any((ch) => _arabicOnlyChars.contains(ch))) return false;
    return _arabicScript.hasMatch(t); // generic Arabic script -> default FA
  }

  bool _isArabic(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    if (t.split('').any((ch) => _arabicOnlyChars.contains(ch))) return true;
    if (t.split('').any((ch) => _persianOnlyChars.contains(ch))) return false;
    return _arabicScript.hasMatch(t);
  }

  bool _isEnglish(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    return _latinLetters.hasMatch(t) && !_arabicScript.hasMatch(t);
  }

  bool _wantsSher(String q) {
    final x = q.toLowerCase();
    return x.contains('شعر') || x.contains('شاعری') || x.contains('ابیات') ||
        x.contains('sher') || x.contains('poem') || x.contains('poetry') ||
        x.contains('verse') || x.contains('verses');
  }

  // ---------------- Instructions (AR / FA / EN) ----------------
  static const String _INSTRUCTIONS_AR =
      "المهمة: سؤال/جواب من نص EPUB المرفق فقط.\n"
      "استعمل الوسوم (Tags) لتحديد المحتوى الخاص.\n"
      "إذا سُئلت عن الشعر، فتجاهل أي مقطع لا يحتوي على العلامة [TAG:sher] أو سطر «Tags: sher».\n"
      "كل مقطع يبدأ بـ «=== Chapter N: title ===» ثم «Tags: sher|none».\n"
      "أعِد إجابة موجزة ودقيقة ومدعومة بالنص. إذا لم تجد مطابقًا فقل: لا أعلم.\n"
      "يُمنع استخدام معلومات خارج الملفات.";

  static const String _INSTRUCTIONS_FA =
      "وظیفه: پرسش/پاسخ فقط از متن EPUBِ پیوست‌شده.\n"
      "برای محتوای خاص از برچسب‌ها (Tags) استفاده کن.\n"
      "اگر سؤال دربارهٔ شعر بود، هر بخشی که [TAG:sher] یا «Tags: sher» ندارد را نادیده بگیر.\n"
      "هر قطعه با «=== Chapter N: title ===» شروع شده و سپس «Tags: sher|none» می‌آید.\n"
      "پاسخی کوتاه، دقیق و مبتنی بر متن بده. اگر چیزی نبود بگو: نمی‌دانم.\n"
      "هیچ اطلاعاتی خارج از فایل‌ها استفاده نکن.";

  static const String _INSTRUCTIONS_EN =
      "Task: Answer ONLY from the attached EPUB text.\n"
      "Use tags to constrain content when needed.\n"
      "If the user asks for poetry, ignore any passage that does NOT contain [TAG:sher] or a line 'Tags: sher'.\n"
      "Each passage starts with '=== Chapter N: title ===' followed by 'Tags: sher|none'.\n"
      "Return a concise, evidence-based answer. If nothing matches say: I don't know.\n"
      "Do not use any information beyond the provided files.";

  String _pickInstructions(String lang) {
    if (lang == 'fa') return _INSTRUCTIONS_FA;
    if (lang == 'en') return _INSTRUCTIONS_EN;
    return _INSTRUCTIONS_AR;
  }

  // ====== Public API ======
  Future<String> askQuestion(String question) async {
    if (!_isInitialized) {
      throw Exception('AI service not initialized. Please set the API key first.');
    }

    final q = question.trim().isEmpty ? 'Summarize the book briefly.' : question.trim();

    // Route to appropriate provider
    if (provider == AIProvider.claude) {
      return _askClaude(q);
    } else {
      return _askChatGPT(q);
    }
  }

  // ====== ChatGPT Implementation ======
  Future<String> _askChatGPT(String question) async {
    if (_openAIApiKey == null) {
      throw Exception('OpenAI API key not set. Please set AIService.openAIApiKey first.');
    }
    if ((vectorStoreId ?? '').isEmpty) {
      throw Exception('Vector Store ID is required. Set AIService.vectorStoreId first.');
    }

    // detect language like your Python script
    final lang = _isEnglish(question) ? 'en' : (_isPersian(question) ? 'fa' : (_isArabic(question) ? 'ar' : 'en'));
    final onlySher = _wantsSher(question);
    final restrictMsg =
        "Use ONLY passages explicitly marked as poetry: those that include [TAG:sher] "
        "or the line 'Tags: sher'. Ignore everything else.";
    final userMsg = onlySher ? "$restrictMsg\n\n$question" : question;

    try {
      // 1) Assistant per language (cached)
      final asstId = await _getOrCreateAssistantForLang(lang);

      // 2) Thread (reuse or create)
      _threadId ??= await _createThread();

      // 3) User message
      await _createMessage(threadId: _threadId!, text: userMsg);

      // 4) Run
      final runId = await _createRun(threadId: _threadId!, assistantId: asstId);

      // 5) Poll
      await _waitForRun(threadId: _threadId!, runId: runId);

      // 6) Read latest assistant message
      final answer = await _getLatestAssistantMessage(threadId: _threadId!);

      return answer.isNotEmpty ? answer : _fallbackDontKnow(lang);
    } on Exception catch (e) {
      final s = e.toString().toLowerCase();
      if (s.contains('unauthorized') || s.contains('api key')) {
        return 'Error: Please check your OpenAI API key configuration.';
      } else if (s.contains('quota') || s.contains('insufficient')) {
        return 'Error: API quota exceeded. Please check your OpenAI billing.';
      } else if (s.contains('rate limit')) {
        return 'Error: Rate limit exceeded. Please try again in a moment.';
      } else {
        return 'Error: Failed to get AI response. ${e.toString()}';
      }
    }
  }

  // ====== Claude Implementation ======
  Future<String> _askClaude(String question) async {
    if (_claudeApiKey == null) {
      throw Exception('Claude API key not set. Please set AIService.claudeApiKey first.');
    }

    // detect language
    final lang = _isEnglish(question) ? 'en' : (_isPersian(question) ? 'fa' : (_isArabic(question) ? 'ar' : 'en'));
    final onlySher = _wantsSher(question);

    // Build system message with instructions
    final systemMessage = _pickInstructions(lang);
    final restrictMsg =
        "Use ONLY passages explicitly marked as poetry: those that include [TAG:sher] "
        "or the line 'Tags: sher'. Ignore everything else.";
    final userMsg = onlySher ? "$restrictMsg\n\n$question" : question;

    try {
      // Add user message to conversation history
      _claudeConversationHistory.add({
        'role': 'user',
        'content': userMsg,
      });

      // Build messages array (keep last 10 messages for context)
      final messages = _claudeConversationHistory.length > 10
          ? _claudeConversationHistory.sublist(_claudeConversationHistory.length - 10)
          : List<Map<String, dynamic>>.from(_claudeConversationHistory);

      // Call Claude API
      final uri = Uri.parse('https://api.anthropic.com/v1/messages');
      final body = {
        'model': claudeModel,
        'max_tokens': 4096,
        'system': systemMessage,
        'messages': messages,
      };

      final resp = await _postClaude(uri, body);
      _ensureOk(resp, 'claudeMessage');

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = json['content'] as List;
      
      // Extract text from response
      final texts = <String>[];
      for (final item in content) {
        if (item['type'] == 'text') {
          final text = item['text']?.toString();
          if (text != null && text.isNotEmpty) {
            texts.add(text);
          }
        }
      }

      final answer = texts.join('\n').trim();

      // Add assistant response to conversation history
      if (answer.isNotEmpty) {
        _claudeConversationHistory.add({
          'role': 'assistant',
          'content': answer,
        });
      }

      return answer.isNotEmpty ? answer : _fallbackDontKnow(lang);
    } on Exception catch (e) {
      final s = e.toString().toLowerCase();
      if (s.contains('unauthorized') || s.contains('api key') || s.contains('authentication')) {
        return 'Error: Please check your Claude API key configuration.';
      } else if (s.contains('quota') || s.contains('insufficient')) {
        return 'Error: API quota exceeded. Please check your Claude billing.';
      } else if (s.contains('rate limit')) {
        return 'Error: Rate limit exceeded. Please try again in a moment.';
      } else {
        return 'Error: Failed to get AI response. ${e.toString()}';
      }
    }
  }

  // Clear conversation history (useful when switching providers or clearing chat)
  static void clearConversationHistory() {
    _claudeConversationHistory.clear();
    _threadId = null;
    _assistantIdByLang.clear();
  }

  String _fallbackDontKnow(String lang) =>
      (lang == 'fa') ? 'نمی‌دانم' : (lang == 'ar') ? 'لا أعلم' : 'I don’t know';

  // ====== Assistant-per-language ======
  Future<String> _getOrCreateAssistantForLang(String lang) async {
    if (_assistantIdByLang.containsKey(lang)) return _assistantIdByLang[lang]!;
    final id = await _createAssistant(
      name: 'EPUB QA (${lang.toUpperCase()})',
      instructions: _pickInstructions(lang),
      model: openAIModel,
      vectorStoreId: vectorStoreId!,
    );
    _assistantIdByLang[lang] = id;
    return id;
  }

  // ====== Assistants v2 REST (raw HTTP) ======
  Future<String> _createAssistant({
    required String name,
    required String instructions,
    required String model,
    required String vectorStoreId,
  }) async {
    final uri = Uri.parse('https://api.openai.com/v1/assistants');
    final body = {
      'name': name,
      'model': model,
      'instructions': instructions,
      'tools': [
        {'type': 'file_search'}
      ],
      'tool_resources': {
        'file_search': {
          'vector_store_ids': [vectorStoreId]
        }
      }
    };

    final resp = await _post(uri, body);
    _ensureOk(resp, 'createAssistant');
    return (jsonDecode(resp.body) as Map<String, dynamic>)['id'] as String;
  }

  Future<String> _createThread() async {
    final uri = Uri.parse('https://api.openai.com/v1/threads');
    final resp = await _post(uri, {});
    _ensureOk(resp, 'createThread');
    return (jsonDecode(resp.body) as Map<String, dynamic>)['id'] as String;
  }

  Future<void> _createMessage({required String threadId, required String text}) async {
    final uri = Uri.parse('https://api.openai.com/v1/threads/$threadId/messages');
    final body = {
      'role': 'user',
      'content': [
        {'type': 'text', 'text': text}
      ],
    };
    final resp = await _post(uri, body);
    _ensureOk(resp, 'createMessage');
  }

  Future<String> _createRun({required String threadId, required String assistantId}) async {
    final uri = Uri.parse('https://api.openai.com/v1/threads/$threadId/runs');
    final body = {'assistant_id': assistantId};
    final resp = await _post(uri, body);
    _ensureOk(resp, 'createRun');
    return (jsonDecode(resp.body) as Map<String, dynamic>)['id'] as String;
  }

  Future<void> _waitForRun({required String threadId, required String runId}) async {
    final uri = Uri.parse('https://api.openai.com/v1/threads/$threadId/runs/$runId');
    while (true) {
      final resp = await _get(uri);
      _ensureOk(resp, 'getRun');
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final status = (json['status'] as String?) ?? 'unknown';
      if (status == 'completed') return;
      if (status == 'failed' || status == 'expired' || status == 'cancelled') {
        final err = (json['last_error']?['message']) ?? 'unknown error';
        throw Exception('Run $status: $err');
      }
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
  }

  Future<String> _getLatestAssistantMessage({required String threadId}) async {
    final uri = Uri.parse('https://api.openai.com/v1/threads/$threadId/messages?order=desc&limit=10');
    final resp = await _get(uri);
    _ensureOk(resp, 'listMessages');

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final data = (json['data'] as List).cast<Map<String, dynamic>>();
    for (final msg in data) {
      if (msg['role'] == 'assistant') {
        final parts = (msg['content'] as List).cast<Map<String, dynamic>>();
        final texts = <String>[];
        for (final p in parts) {
          if (p['type'] == 'text') {
            final value = p['text']?['value']?.toString();
            if (value != null && value.isNotEmpty) texts.add(value);
          }
        }
        if (texts.isNotEmpty) return texts.join('\n').trim();
      }
    }
    return '';
  }

  // ====== HTTP helpers ======
  void _ensureOk(_HttpResponse r, String label) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    throw Exception('$label failed: ${r.statusCode} ${r.body}');
  }

  Future<_HttpResponse> _post(Uri uri, Map<String, dynamic> body) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(uri);
      _applyHeaders(req);
      req.add(utf8.encode(jsonEncode(body)));
      final res = await req.close();
      final text = await utf8.decodeStream(res);
      return _HttpResponse(res.statusCode, text);
    } finally {
      client.close(force: true);
    }
  }

  Future<_HttpResponse> _get(Uri uri) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      _applyHeaders(req);
      final res = await req.close();
      final text = await utf8.decodeStream(res);
      return _HttpResponse(res.statusCode, text);
    } finally {
      client.close(force: true);
    }
  }

  void _applyHeaders(HttpClientRequest req) {
    req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_openAIApiKey');
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.headers.set('OpenAI-Beta', 'assistants=v2'); // required
  }

  // ====== Claude HTTP helpers ======
  Future<_HttpResponse> _postClaude(Uri uri, Map<String, dynamic> body) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(uri);
      _applyClaudeHeaders(req);
      req.add(utf8.encode(jsonEncode(body)));
      final res = await req.close();
      final text = await utf8.decodeStream(res);
      return _HttpResponse(res.statusCode, text);
    } finally {
      client.close(force: true);
    }
  }

  void _applyClaudeHeaders(HttpClientRequest req) {
    req.headers.set('x-api-key', _claudeApiKey!);
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.headers.set('anthropic-version', '2023-06-01'); // Required Claude API version
  }
}


class _HttpResponse {
  final int statusCode;
  final String body;
  _HttpResponse(this.statusCode, this.body);
}
