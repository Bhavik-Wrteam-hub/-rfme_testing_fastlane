import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/helpers/attachment.dart';
import 'package:ebroker/ui/screens/chat/helpers/chat_helpers.dart';
import 'package:ebroker/ui/screens/chat/helpers/registerar.dart';
import 'package:ebroker/ui/screens/chat/widgets/message_renderer.dart';
import 'package:ebroker/ui/screens/chat/widgets/record_button.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.receiverId,
    required this.propertyId,
    required this.scrollController,
    super.key,
  });

  final String receiverId;
  final String propertyId;
  final ScrollController scrollController;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<bool> _showRecordButton = ValueNotifier(true);
  PlatformFile? _attachment;
  late final AnimationController _recordAnimation;

  @override
  void initState() {
    super.initState();

    _recordAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _textController.addListener(() {
      _showRecordButton.value =
          _textController.text.trim().isEmpty && _attachment == null;
    });
  }

  @override
  void dispose() {
    _recordAnimation.dispose();
    _textController.dispose();
    _showRecordButton.dispose();
    super.dispose();
  }

  void _removeAttachment() {
    setState(() => _attachment = null);
    _showRecordButton.value = _textController.text.trim().isEmpty;
  }

  Future<void> _sendTextOrAttachment() async {
    if (_textController.text.trim().isEmpty && _attachment == null) return;
    // Send to server using SendMessageCubit
    await context.read<SendMessageCubit>().send(
      proeprtyId: widget.propertyId,
      recieverId: widget.receiverId,
      senderId: HiveUtils.getUserId().toString(),
      message: _textController.text.trim(),
      attachment: _attachment?.path,
    );

    _textController.clear();
    _removeAttachment();
    widget.scrollController.jumpTo(widget.scrollController.offset - 10);
  }

  Future<void> _sendAudio(String? path) async {
    final model = MessageRenderUtils.createChatMessage(
      message: _textController.text.trim(),
      audio: path,
      receiverId: widget.receiverId,
      propertyId: widget.propertyId,
      audioPath: path,
    );

    // Add to local message handler for immediate display
    await ChatMessageHandler.add(model);

    // Send to server using SendMessageCubit
    await context.read<SendMessageCubit>().send(
      proeprtyId: widget.propertyId,
      recieverId: widget.receiverId,
      senderId: HiveUtils.getUserId().toString(),
      message: _textController.text.trim(),
      attachment: _attachment?.path,
      audio: path,
    );

    _textController.clear();
    widget.scrollController.jumpTo(widget.scrollController.offset - 10);
  }

  Future<void> _showAttachmentOptions(BuildContext context) async {
    await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: context.color.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: .min,
          children: [
            CustomText(
              'selectAttachment'.translate(context),
              fontSize: context.font.lg,
              fontWeight: .bold,
              color: context.color.textColorDark,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context,
                  Icons.image,
                  'gallery'.translate(context),
                  () async {
                    Navigator.pop(context);
                    await ChatHelpers.pickGalleryAttachment((file) {
                      setState(() {
                        _attachment = file;
                      });
                      _showRecordButton.value = false;
                    });
                  },
                ),
                _buildAttachmentOption(
                  context,
                  Icons.insert_drive_file,
                  'Documents'.translate(context),
                  () async {
                    Navigator.pop(context);
                    await ChatHelpers.pickDocumentAttachment((file) {
                      setState(() {
                        _attachment = file;
                      });
                      _showRecordButton.value = false;
                    });
                  },
                ),
                _buildAttachmentOption(
                  context,
                  Icons.audiotrack,
                  'audio'.translate(context),
                  () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'ogg'],
                      );

                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
                        await _sendAudio(file.path);
                        Navigator.pop(context);
                      }
                    } on Exception catch (e) {
                      Navigator.pop(context);
                      HelperUtils.showSnackBarMessage(
                        context,
                        e.toString(),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: .min,
        children: [
          CircleAvatar(
            radius: 24.rh(context),
            backgroundColor: context.color.tertiaryColor.withValues(alpha: .2),
            child: Icon(
              icon,
              color: context.color.tertiaryColor,
              size: 22.rh(context),
            ),
          ),
          const SizedBox(height: 8),
          CustomText(
            label,
            fontSize: context.font.sm,
            color: context.color.textColorDark,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attachmentExt =
        _attachment?.path?.split('.').last.toLowerCase() ?? '';

    return Column(
      mainAxisSize: .min,
      children: [
        if (_attachment != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AttachmentPreview(
              attachment: _attachment!,
              isImage: ChatHelpers.supportedImageTypes.contains(attachmentExt),
              onRemove: _removeAttachment,
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BottomAppBar(
            padding: const EdgeInsetsDirectional.all(10),
            color: context.color.secondaryColor,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _textController,
                    dense: true,
                    borderColor: context.color.borderColor,
                    hintText: 'writeHere'.translate(context),
                    suffix: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomImage(
                          imageUrl: AppIcons.paperClip,
                          color: context.color.textColorDark,
                        ),
                      ),
                      onTap: () async {
                        if (_attachment != null) {
                          _removeAttachment();
                        } else {
                          await _showAttachmentOptions(context);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<bool>(
                  valueListenable: _showRecordButton,
                  builder: (_, showRecord, _) {
                    return Container(
                      width: 46.rw(context),
                      height: 46.rh(context),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.color.tertiaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                        child: showRecord
                            ? RecordButton(
                                controller: _recordAnimation,
                                callback: (val) => _sendAudio(val as String?),
                                isSending: false,
                              )
                            : GestureDetector(
                                onTap: _sendTextOrAttachment,
                                child: CustomImage(
                                  width: 24.rw(context),
                                  height: 24.rh(context),
                                  imageUrl: AppIcons.send,
                                  color: context.color.buttonColor,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    required this.attachment,
    required this.isImage,
    required this.onRemove,
    super.key,
  });

  final PlatformFile attachment;
  final bool isImage;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return isImage
        ? GestureDetector(
            onTap: () async {
              await UiUtils.showFullScreenImage(
                context,
                provider: FileImage(File(attachment.path!)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
              ),
              child: Image.file(
                File(attachment.path!),
                height: 100,
                width: 100,
                fit: .cover,
              ),
            ),
          )
        : ColoredBox(
            color: context.color.secondaryColor,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AttachmentMessage(
                url: attachment.path!,
                isSentByMe: true,
              ),
            ),
          );
  }
}
