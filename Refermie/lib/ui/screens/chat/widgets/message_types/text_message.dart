import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/model/chat_message_model.dart';
import 'package:flutter/material.dart';

class TextMessage extends ChatMessage {
  TextMessage() {
    id = DateTime.now().toString();
  }

  @override
  Future<void> init() async {
    if (isSentNow && isSentByMe && isSent == false) {
      await context?.read<SendMessageCubit>().send(
        senderId: HiveUtils.getUserId().toString(),
        recieverId: receiverId ?? '0',
        attachment: file,
        message: message!,
        proeprtyId: propertyId!,
        audio: audio,
      );
    }

    ///if this message is not sent now so it will set id from server
    // if (isSentNow == false) {
    //   id = id;
    // }

    super.init();
  }

  @override
  Future<void> onRemove() async {
    await context!.read<DeleteMessageCubit>().delete(
      messageId: id,
      receiverId: receiverId!,
      senderId: '',
      propertyId: '',
    );

    super.onRemove();
  }

  @override
  Widget render(BuildContext context) {
    var messageColor = context.color.textColorDark;
    if (isSentByMe) {
      messageColor = context.color.brightness == .light
          ? context.color.secondaryColor
          : context.color.textColorDark;
    }

    return Align(
      alignment: isSentByMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: EdgeInsetsDirectional.only(end: isSentByMe ? 0 : 10),
        child: Column(
          crossAxisAlignment: isSentByMe
              ? .end
              : .start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: context.screenWidth * 0.74),
              decoration: isSentByMe
                  ? getSentByMeDecoration(context)
                  : getOtherUserDecoration(context),
              child: Row(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: context.screenWidth * 0.76,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomText(
                            message ?? '',
                            fontSize: context.font.sm,
                            color: messageColor,
                          ),
                        ),
                      );
                    },
                  ),
                  BlocConsumer<SendMessageCubit, SendMessageState>(
                    listener: (context, state) {
                      if (state is SendMessageSuccess) {
                        id = state.messageId.toString();
                        isSent = true;
                      }
                    },
                    builder: (context, state) {
                      if (state is SendMessageInProgress) {
                        return const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.watch_later_outlined,
                            size: 10,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration getSentByMeDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.color.tertiaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.color.borderColor, width: 1.5),
    );
  }

  BoxDecoration getOtherUserDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.color.borderColor, width: 1.5),
    );
  }

  String type = 'text';
}
