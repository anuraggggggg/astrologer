import 'package:get/get.dart';

import '../../../models/message_model.dart';

class MessageProvider extends GetxController {
  final List<MessageModel> _reverseMessage = [];
  final List<MessageModel> _messageList = [];

  List<MessageModel> get messageList => _messageList;
  List<MessageModel> get reverseMessage => _reverseMessage;
}
