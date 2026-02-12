import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/model/chat_message_model.dart';
import 'package:ebroker/ui/screens/chat/widgets/message_types/text_and_file.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

class FileMessage extends ChatMessage {
  FileMessage() {
    id = DateTime.now().toString();
  }

  String type = 'file';
  List<String> imageExtensions = ['png', 'jpg', 'jpeg', 'webp', 'bmp'];

  @override
  Future<void> init() async {
    if (isSentNow && isSentByMe && isSent == false) {
      await context!.read<SendMessageCubit>().send(
        senderId: HiveUtils.getUserId().toString(),
        recieverId: receiverId!,
        attachment: file,
        message: message!,
        proeprtyId: propertyId!,
        audio: audio,
      );
    }
    // if (isSentNow == false) {
    //   id = id;
    // }
    super.init();
  }

  @override
  Widget render(BuildContext context) {
    final extension = file!.split('.').last;
    final msg = ChatMessage();

    if (imageExtensions.contains(extension)) {
      return ImageAttachmentWidget(
        isSentByMe: isSentByMe,
        message: msg,
        onFileSent: () {
          isSent = true;
        },
        onId: (id) {
          this.id = id;
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: fileWidget(context, extension),
    );
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

  Widget fileWidget(BuildContext context, String extension) {
    return Align(
      alignment: isSentByMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: isSentByMe
            ? .end
            : .start,
        children: [
          Container(
            width: context.screenWidth * 0.74,
            // height: 65,
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.color.borderColor,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                SizedBox(
                  height: 65,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          height: 65,
                          child: Center(
                            child: CustomText(
                              extension.toUpperCase(),
                              fontSize: context.font.xs,
                              color: context.color.textColorDark,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1.5,
                        height: 50,
                        color: context.color.borderColor.darken(10),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: CustomText(file!.split('/').last),
                        ),
                      ),
                      FileDownloadButton(
                        url: file!,
                      ),
                    ],
                  ),
                ),
                BlocConsumer<SendMessageCubit, SendMessageState>(
                  listener: (context, state) {
                    if (state is SendMessageSuccess) {
                      id = state.messageId.toString();
                      // widget.onId.call(state.messageId.toString());
                      // widget.onFileSent.call();
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
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomText(
              timeAgo ?? format(DateTime.now()),
              fontSize: context.font.xs,
              color: context.color.textLightColor,
            ),
          ),
        ],
      ),
    );
  }
}
