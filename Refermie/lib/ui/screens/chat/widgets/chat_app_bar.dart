import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/helpers/chat_helpers.dart';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    required this.profilePicture,
    required this.userName,
    required this.propertyTitle,
    required this.propertyImage,
    required this.isBlockedByMe,
    required this.isBlockedByUser,
    required this.isNotificationPermissionGranted,
    required this.userId,
    required this.propertyId,
    required this.onMenuSelected,
    required this.isFrom,
    super.key,
  });

  final String profilePicture;
  final String userName;
  final String propertyTitle;
  final String propertyImage;
  final bool isBlockedByMe;
  final bool isBlockedByUser;
  final bool isNotificationPermissionGranted;
  final String userId;
  final String propertyId;
  final Future<void> Function(String action) onMenuSelected;
  final String isFrom;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    final color = context.color;

    return CustomAppBar(
      onTapBackButton: () async {
        await context.read<GetChatListCubit>().fetch(forceRefresh: true);
      },
      titleWidget: Row(
        mainAxisSize: .min,
        children: [
          CustomImageHeroAnimation(
            type: CImageType.network,
            image: profilePicture.isEmpty
                ? appSettings.placeholderLogo!
                : profilePicture,
            child: CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(profilePicture),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: context.screenWidth * 0.45,
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              mainAxisAlignment: .center,
              children: [
                CustomText(
                  userName,
                  fontSize: context.font.sm,
                  fontWeight: .w500,
                  maxLines: 1,
                  color: context.color.textColorDark,
                ),
                CustomText(
                  propertyTitle,
                  maxLines: 1,
                  fontSize: context.font.xs,
                  color: context.color.textColorDark,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (propertyImage.isNotEmpty)
          GestureDetector(
            onTap: () async {
              if (isFrom == 'property') {
                Navigator.pop(context);
              } else {
                await ChatHelpers.onTapPropertyDetails(
                  context,
                  userId,
                  propertyId,
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomImage(
                imageUrl: propertyImage,
                height: 46.rh(context),
                width: 46.rw(context),
              ),
            ),
          ),
        PopupMenuButton<String>(
          onSelected: onMenuSelected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: color.primaryColor,
          icon: Icon(
            Icons.more_vert,
            color: context.color.tertiaryColor,
          ),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'agentDetails',
              child: CustomText('agentDetails'.translate(context)),
            ),
            if (!(isBlockedByUser || isBlockedByMe))
              PopupMenuItem(
                value: 'deleteAllMessages',
                child: CustomText('deleteAllMessages'.translate(context)),
              ),
            if (!isBlockedByMe)
              PopupMenuItem(
                value: 'blockUser',
                child: CustomText('blockUser'.translate(context)),
              ),
            if (isBlockedByMe)
              PopupMenuItem(
                value: 'unblockUser',
                child: CustomText('unblockUser'.translate(context)),
              ),
          ],
        ),
      ],
    );
  }
}
