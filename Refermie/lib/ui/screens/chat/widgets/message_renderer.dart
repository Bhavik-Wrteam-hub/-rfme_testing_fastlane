import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/helpers/registerar.dart';
import 'package:ebroker/ui/screens/chat/model/chat_message_model.dart';
import 'package:ebroker/ui/screens/chat/widgets/audio_message.dart';
import 'package:ebroker/utils/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

/// A unified message renderer that handles all message types
class UnifiedMessageRenderer extends StatefulWidget {
  const UnifiedMessageRenderer({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  State<UnifiedMessageRenderer> createState() => _UnifiedMessageRendererState();
}

class _UnifiedMessageRendererState extends State<UnifiedMessageRenderer>
    with AutomaticKeepAliveClientMixin {
  ValueNotifier<bool> showDeletebutton = ValueNotifier<bool>(false);

  /// List of supported image types
  static final List<String> supportedImageTypes = [
    'jpeg',
    'jpg',
    'png',
  ];

  @override
  void initState() {
    super.initState();
    if (context.mounted) {
      widget.message.setContext(context);
      widget.message.init();
    }
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      widget.message.setContext(context);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isSentByMe = widget.message.isSentByMe;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: isSentByMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: _buildMessageContainer(
            context,
            isSentByMe,
          ),
        ),
      ),
    );
  }

  /// Build the message container with appropriate styling
  Widget _buildMessageContainer(
    BuildContext context,
    bool isSentByMe,
  ) {
    return ContextMenuRegion(
      contextMenuBuilder: (context, offset) {
        return AdaptiveTextSelectionToolbar(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: offset,
          ),
          children: <Widget>[
            if (widget.message.chatMessageType == 'text' ||
                widget.message.chatMessageType == 'file_and_text')
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: widget.message.message ?? '',
                    ),
                  );
                  ContextMenuController.removeAny();
                  HelperUtils.showSnackBarMessage(
                    context,
                    'copied',
                  );
                },
                child: Container(
                  color: context.color.brightness == .light
                      ? Colors.white
                      : Colors.black,
                  padding: const EdgeInsets.all(8),
                  child: CustomText(
                    'Copy${widget.message.chatMessageType == "file_and_text" ? " Text" : ""}',
                    color: context.color.inverseSurface,
                  ),
                ),
              ),
            if (widget.message.isSentByMe)
              BlocListener<DeleteMessageCubit, DeleteMessageState>(
                listener: (context, state) async {
                  if (state is DeleteMessageSuccess) {
                    await ChatMessageHandler.remove(state.id);
                    showDeletebutton.value = false;
                    ContextMenuController.removeAny();
                  }
                  if (state is DeleteMessageFail) {
                    ContextMenuController.removeAny();
                  }
                },
                child: GestureDetector(
                  onTap: () async {
                    await context.read<DeleteMessageCubit>().delete(
                      messageId: widget.message.id,
                      propertyId: '',
                      receiverId: widget.message.receiverId ?? '',
                      senderId: '',
                    );
                  },
                  child: Container(
                    color: context.color.brightness == .light
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.all(8),
                    child: CustomText(
                      'deleteBtnLbl'.translate(context),
                      color: context.color.inverseSurface,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSentByMe
              ? context.color.tertiaryColor
              : context.color.secondaryColor,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(12),
            topEnd: const Radius.circular(12),
            bottomStart: Radius.circular(isSentByMe ? 12 : 3),
            bottomEnd: Radius.circular(isSentByMe ? 3 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Wrap(
          alignment: .end,
          crossAxisAlignment: .end,
          children: [
            _buildMessageContent(context, isSentByMe),
            const SizedBox(width: 8),
            _buildTimeStamp(
              context: context,
              isSentByMe: isSentByMe,
              date: widget.message.date ?? '',
            ),
          ],
        ),
      ),
    );
  }

  /// Build the message content based on message type
  Widget _buildMessageContent(
    BuildContext context,
    bool isSentByMe,
  ) {
    // Handle audio messages
    if (widget.message.chatMessageType == 'audio' ||
        (widget.message.audio != null && widget.message.audio!.isNotEmpty)) {
      if (widget.message is AudioMessage) {
        return (widget.message as AudioMessage).render(context);
      } else {
        // If we have a standard ChatMessage with audio content, create a renderer
        final audioMessage = AudioMessage()
          ..id = widget.message.id
          ..message = widget.message.message ?? ''
          ..senderId = widget.message.senderId
          ..receiverId = widget.message.receiverId
          ..propertyId = widget.message.propertyId
          ..date = widget.message.date
          ..timeAgo = widget.message.timeAgo
          ..isSentByMe = widget.message.isSentByMe
          ..isSentNow = widget.message.isSentNow
          ..audio = widget.message.audio
          ..chatMessageType = 'audio'
          ..isSent = widget.message.isSent
          ..setContext(context);

        return audioMessage.render(context);
      }
    }

    // Handle image messages
    if (widget.message.chatMessageType == 'image' ||
        (widget.message.file != null && _isImageFile(widget.message.file!))) {
      return _buildImageMessage(context, isSentByMe);
    }

    // Handle file messages
    if (widget.message.file != null &&
        widget.message.chatMessageType == 'file') {
      return _buildFileMessage(context, isSentByMe);
    }

    // Default text message
    return _buildTextMessage(context, isSentByMe);
  }

  /// Build an image message
  Widget _buildImageMessage(BuildContext context, bool isSentByMe) {
    return GestureDetector(
      onTap: () async {
        await UiUtils.showFullScreenImage(
          context,
          provider: NetworkImage(
            widget.message.file ?? '',
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomImage(
          imageUrl: widget.message.file ?? '',
          height: 100,
          width: 100,
        ),
      ),
    );
  }

  // file message
  Widget _buildFileMessage(BuildContext context, bool isSentByMe) {
    final fileName = widget.message.file?.split('/').last ?? 'File';
    // Create these as state variables instead of local variables
    final dio = Dio();
    final percentage = ValueNotifier<double>(0);
    final downloadedState = ValueNotifier<bool>(false);

    return Column(
      mainAxisSize: .min,
      children: [
        Row(
          mainAxisSize: .min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: isSentByMe
                  ? context.color.buttonColor
                  : context.color.textColorDark,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(
                  color: isSentByMe
                      ? context.color.buttonColor
                      : context.color.textColorDark,
                ),
                maxLines: 2,
                overflow: .ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(4),
              child: ValueListenableBuilder(
                valueListenable: percentage,
                builder: (context, value, child) {
                  return ValueListenableBuilder(
                    valueListenable: downloadedState,
                    builder: (context, isDownloaded, _) {
                      if (value > 0.0 && value < 1.0) {
                        return SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            value: value,
                            color: isSentByMe
                                ? context.color.buttonColor
                                : context.color.textColorDark,
                          ),
                        );
                      }
                      if (isDownloaded) {
                        return GestureDetector(
                          onTap: () async {
                            final downloadPath = await path();
                            await OpenFilex.open('$downloadPath/$fileName');
                          },
                          child: Icon(
                            Icons.file_open,
                            color: isSentByMe
                                ? context.color.buttonColor
                                : context.color.textColorDark,
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () async {
                          final downloadPath = await path();
                          final storagePermission =
                              await HelperUtils.hasStoragePermissionGiven();
                          if (storagePermission) {
                            try {
                              await dio.download(
                                widget.message.file ?? '',
                                '$downloadPath/$fileName',
                                onReceiveProgress: (count, total) {
                                  // Update on the main thread to ensure UI updates
                                  if (total > 0) {
                                    WidgetsBinding.instance.addPostFrameCallback(
                                      (_) async {
                                        percentage.value = count / total;
                                        if (count == total) {
                                          downloadedState.value = true;
                                          // Open file after download completes
                                          await OpenFilex.open(
                                            '$downloadPath/$fileName',
                                          );
                                        }
                                      },
                                    );
                                  }
                                },
                              );
                            } on Exception catch (e) {
                              HelperUtils.showSnackBarMessage(
                                context,
                                'Download failed: $e',
                              );
                            }
                          } else {
                            HelperUtils.showSnackBarMessage(
                              context,
                              'Storage Permission denied!',
                            );
                          }
                        },
                        child: Icon(
                          Icons.download,
                          color: isSentByMe
                              ? context.color.buttonColor
                              : context.color.textColorDark,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        if (widget.message.message != null &&
            widget.message.message!.isNotEmpty &&
            widget.message.message != '[File]') ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.message.message!,
              style: TextStyle(
                color: isSentByMe
                    ? context.color.buttonColor
                    : context.color.textColorDark,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<String?>? path() async {
    final downloadPath = await HelperUtils.getDownloadPath();
    return downloadPath;
  }

  /// Build a text message
  Widget _buildTextMessage(
    BuildContext context,
    bool isSentByMe,
  ) {
    return Text(
      widget.message.message ?? '',
      style: TextStyle(
        color: isSentByMe
            ? context.color.buttonColor
            : context.color.textColorDark,
        fontSize: 15,
      ),
    );
  }

  /// Build the timestamp display
  Widget _buildTimeStamp({
    required BuildContext context,
    required bool isSentByMe,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '${DateTime.parse(date).toLocal().hour}:${DateTime.parse(date).toLocal().minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: isSentByMe
              ? context.color.buttonColor.withValues(alpha: .7)
              : context.color.textColorDark.withValues(alpha: .7),
          fontSize: 10,
        ),
      ),
    );
  }

  // Helper method to check if a file is an image based on extension
  bool _isImageFile(String filePath) {
    final fileExt = filePath.split('.').last.toLowerCase();
    return supportedImageTypes.contains(fileExt);
  }

  @override
  bool get wantKeepAlive => false;
}

/// Helper class for chat message rendering utilities
class MessageRenderUtils {
  /// Get message type based on content
  static String getMessageType(
    String? audioPath,
    String? message,
    String? file,
  ) {
    if (audioPath != null) return 'audio';
    if (file != null && message != null && message.isNotEmpty) {
      return 'file_and_text';
    }
    if (file != null) {
      // Check if it's an image
      final fileExt = file.split('.').last.toLowerCase();
      if (['jpeg', 'jpg', 'png'].contains(fileExt)) {
        return 'image';
      }
      return 'file';
    }
    return 'text';
  }

  /// Create a chat message object
  static ChatMessage createChatMessage({
    required String message,
    required String receiverId,
    required String propertyId,
    String? file,
    String? audio,
    String? audioPath,
  }) {
    return ChatMessage(
      message: message,
      file: file,
      audio: audio ?? '',
      isSentByMe: true,
      id: DateTime.now().toIso8601String(),
      senderId: HiveUtils.getUserId().toString(),
      receiverId: receiverId,
      propertyId: propertyId,
      chatMessageType: getMessageType(audioPath, message, file),
      date: DateTime.now().toIso8601String(),
      isSentNow: true,
    );
  }

  /// Format a date key for display in chat timeline
  static String formatDateKey(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if date is today
    if (getDateKey(date) == getDateKey(today)) {
      return 'Today';
    }

    // Check if date is yesterday
    if (getDateKey(date) == getDateKey(yesterday)) {
      return 'Yesterday';
    }

    // Check if date is within this week
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    if (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek)) {
      // Return day name
      final weekdays = <String>[
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[date.weekday - 1];
    }

    // For older dates, return formatted date
    return '${date.day} ${getMonthName(date.month)} ${date.year != now.year ? date.year : ''}';
  }

  /// Get a date key for grouping messages
  static String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Compare date keys for sorting
  static int compareDateKeys(String a, String b) {
    final dateA = DateTime.parse(a);
    final dateB = DateTime.parse(b);
    return dateA.compareTo(dateB);
  }

  /// Get month name from month number
  static String getMonthName(int month) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Build a date divider widget for chat timeline
  static Widget buildDateDivider(BuildContext context, String dateKey) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.color.textLightColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateKey.formatDate(),
          style: TextStyle(
            color: context.color.textLightColor,
            fontSize: 12,
            fontWeight: .w500,
          ),
        ),
      ),
    );
  }

  /// Group messages by date and create a list of widgets with date dividers
  static List<Widget> groupMessagesByDate(
    BuildContext context,
    List<ChatMessage> messages,
  ) {
    // Group messages by date
    final messagesByDate = <String, List<ChatMessage>>{};

    for (final message in messages) {
      // Parse the date from the message
      final messageDate =
          DateTime.tryParse(message.date ?? '') ?? DateTime.now();
      final dateKey = getDateKey(messageDate);

      if (!messagesByDate.containsKey(dateKey)) {
        messagesByDate[dateKey] = [];
      }
      messagesByDate[dateKey]!.add(message);
    }

    // Create a list of all items to display (dividers + messages)
    final listItems = <Widget>[];

    // Sort date keys in reverse chronological order
    final sortedDateKeys = messagesByDate.keys.toList()
      ..sort((a, b) => compareDateKeys(b, a)); // Reverse order for newest first

    for (final dateKey in sortedDateKeys) {
      // Add messages for this date
      final messagesForDate = messagesByDate[dateKey]!
        ..sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA); // Newest first
        });

      // First add the messages
      for (final message in messagesForDate) {
        listItems.add(
          UnifiedMessageRenderer(message: message),
        );
      }

      // Then add the date divider (it will appear at the end of the list for this date)
      // When the list is reversed, this will show at the top of each day's messages
      listItems.add(buildDateDivider(context, dateKey));
    }

    return listItems;
  }
}
