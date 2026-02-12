import 'package:ebroker/utils/hive_utils.dart'; // Add this import
import 'package:flutter/material.dart';

class ChatMessage {
  ChatMessage({
    this.id = '',
    this.senderId,
    this.isSentByMe = false,
    this.isSentNow = false,
    this.date,
    this.propertyTitleImage,
    this.timeAgo,
    this.receiverId,
    this.sound,
    this.userProfile,
    this.body,
    this.title,
    this.clickAction,
    this.message,
    this.propertyId,
    this.file,
    this.chatMessageType = 'text',
    this.audio,
    this.username,
    this.context,
  });

  // Serialization
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final currentUserId = HiveUtils.getUserId() ?? '';
    final senderId = json['sender_id']?.toString() ?? '';
    final isSentByMe = senderId == currentUserId;

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      isSentByMe: isSentByMe,
      isSentNow: json['isSentNow'] as bool? ?? false,
      date: json['created_at']?.toString(),
      propertyTitleImage: json['property_title_image']?.toString(),
      timeAgo: json['time_ago']?.toString(),
      receiverId: json['receiver_id']?.toString(),
      senderId: senderId,
      sound: json['sound']?.toString(),
      userProfile: json['user_profile']?.toString(),
      body: json['body']?.toString(),
      title: json['title']?.toString(),
      clickAction: json['click_action']?.toString(),
      message: json['message']?.toString(),
      propertyId: json['property_id']?.toString(),
      file: json['file']?.toString(),
      chatMessageType: json['chat_message_type']?.toString() ?? 'text',
      audio: json['audio']?.toString(),
      username: json['username']?.toString(),
    );
  }

  // core metadata
  String id;
  String? senderId;
  bool? isSent;
  bool isSentByMe;
  bool isSentNow;
  String chatMessageType;

  // timestamps
  String? date;
  String? timeAgo;

  // UI extras
  BuildContext? context;
  String? username;
  String? userProfile;
  String? sound;
  String? propertyTitleImage;

  // payload
  String? receiverId;
  String? propertyId;
  String? title;
  String? body;
  String? message;
  String? clickAction;
  String? file;
  String? audio;

  // Methods

  void init() {}
  void dispose() {}
  void onRemove() {}

  void setContext(BuildContext context) {
    this.context = context;
  }

  Widget render(BuildContext context) {
    // Placeholder for now, or inject your RenderMessage widget here
    return const SizedBox();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'isSentByMe': isSentByMe,
        'isSentNow': isSentNow,
        'created_at': date,
        'property_title_image': propertyTitleImage,
        'time_ago': timeAgo,
        'sound': sound,
        'user_profile': userProfile,
        'body': body,
        'title': title,
        'click_action': clickAction,
        'message': message,
        'property_id': propertyId,
        'file': file,
        'chat_message_type': chatMessageType,
        'audio': audio,
        'username': username,
      };

  @override
  String toString() {
    return 'ChatMessage('
        'id: $id, '
        'isSentByMe: $isSentByMe, '
        'isSentNow: $isSentNow, '
        'date: $date, '
        'propertyTitleImage: $propertyTitleImage, '
        'timeAgo: $timeAgo, '
        'receiverId: $receiverId, '
        'senderId: $senderId, '
        'sound: $sound, '
        'userProfile: $userProfile, '
        'body: $body, '
        'title: $title, '
        'clickAction: $clickAction, '
        'message: $message, '
        'propertyId: $propertyId, '
        'file: $file, '
        'chatMessageType: $chatMessageType, '
        'audio: $audio, '
        'username: $username, '
        ')';
  }

  void setIsSentByMe({required bool value}) {
    isSentByMe = value;
  }
}

class MessageAction {
  MessageAction({required this.action, required this.message});
  final String action;
  final ChatMessage message;
}

class MessageId {
  MessageId(this.id);
  factory MessageId.empty(String id) => MessageId(id);
  factory MessageId.senderId(String id) => MessageId(id);
  final String id;
}
