import 'dart:async';

import 'package:flutter/material.dart';

class ChatedUser {
  ChatedUser({
    this.propertyId,
    this.title,
    this.translatedTitle,
    this.titleImage,
    this.userId,
    this.unreadCount,
    this.name,
    this.profile,
    this.firebaseId,
    this.fcmId,
    this.isBlockedByMe,
    this.isBlockedByUser,
  });

  ChatedUser.fromJson(Map<String, dynamic> json, {BuildContext? context}) {
    if (context != null && json['profile'] != null && json['profile'] != '') {
      unawaited(
        precacheImage(NetworkImage(json['profile']?.toString() ?? ''), context),
      );
    }
    if (context != null &&
        json['title_image'] != null &&
        json['title_image'] != '') {
      unawaited(
        precacheImage(
          NetworkImage(json['title_image']?.toString() ?? ''),
          context,
        ),
      );
    }
    propertyId = json['property_id'] as int?;
    userId = json['user_id'] as int?;
    title = json['title']?.toString() ?? '';
    translatedTitle = json['translated_title']?.toString() ?? '';
    titleImage = json['title_image']?.toString() ?? '';
    unreadCount = json['unread_count']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    profile = json['profile']?.toString() ?? '';
    firebaseId = json['firebase_id']?.toString() ?? '';
    fcmId = json['fcm_id']?.toString() ?? '';
    isBlockedByMe = json['is_blocked_by_me'] as bool? ?? false;
    isBlockedByUser = json['is_blocked_by_user'] as bool? ?? false;
  }
  int? propertyId;
  int? userId;
  String? title;
  String? translatedTitle;
  String? titleImage;

  String? name;
  String? unreadCount;
  String? profile;
  String? firebaseId;
  String? fcmId;
  bool? isBlockedByMe;
  bool? isBlockedByUser;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['property_id'] = propertyId;
    data['title'] = title;
    data['translated_title'] = translatedTitle;
    data['title_image'] = titleImage;
    data['user_id'] = userId;
    data['unread_count'] = unreadCount;
    data['name'] = name;
    data['profile'] = profile;
    data['firebase_id'] = firebaseId;
    data['fcm_id'] = fcmId;
    data['is_blocked_by_me'] = isBlockedByMe;
    data['is_blocked_by_user'] = isBlockedByUser;
    return data;
  }
}
