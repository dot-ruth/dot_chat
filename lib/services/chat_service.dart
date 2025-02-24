import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dot_chat/models/chat_message_model.dart';
import 'package:dot_chat/models/chat_session_model.dart';
import 'package:hive/hive.dart';

class ChatService {
  static final _chatBox = Hive.box<ChatSessionModel>('chatBox');

  // Create a new session
  static Future<ChatSessionModel> createSession() async {
    final newSession = ChatSessionModel(
      id: DateTime.now().toIso8601String(),
      title: "New Chat", // Use first message as session title
      messages: [],
      createdAt: DateTime.now(),
    );
    await _chatBox.add(newSession);
    return newSession;
  }

  // Get all sessions
  static List<ChatSessionModel> getSessions() {
    return _chatBox.values.toList().reversed.toList();
  }

  // Add a message to an existing session
  static Future<void> addMessageToSession(ChatSessionModel? session, ChatMessage message) async {
    if (_chatBox.isNotEmpty && session != null) {
      session.addMessage(message);
    } 
  }

  // Retrieve messages from a session
  static List<ChatMessage> getMessagesFromSession(ChatSessionModel session) {
    return session.getChatMessages();
  }

  // Clear all chat history
  static Future<void> clearSessions() async {
    await _chatBox.clear();
  }
}
