import 'package:flutter/material.dart';

class ConversationProvider extends ChangeNotifier {
  String? _memberId;
  String? get memberId => _memberId;
  String? _conversationId;
  String? get conversationId => _conversationId;

  getIds(String newMemberId, String newConversationId) {
    _memberId = newMemberId;
    _conversationId = newConversationId;
    notifyListeners();
  }
}
