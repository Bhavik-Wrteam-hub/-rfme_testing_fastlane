import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static Route<dynamic> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) {
        return const ChatListScreen();
      },
    );
  }

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    chatScreenController.addListener(() async {
      if (chatScreenController.isEndReached() && mounted) {
        if (context.read<GetChatListCubit>().hasMoreData()) {
          await context.read<GetChatListCubit>().loadMore();
        }
      }
    });
    if (context.read<GetChatListCubit>().state is! GetChatListSuccess) {
      unawaited(context.read<GetChatListCubit>().fetch(forceRefresh: false));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: CustomAppBar(
          title: 'message'.translate(context),
          isFromHome: true,
          showBackButton: false,
        ),
        body: CustomRefreshIndicator(
          onRefresh: () async {
            await context.read<GetChatListCubit>().fetch(forceRefresh: true);
          },
          child: BlocBuilder<GetChatListCubit, GetChatListState>(
            builder: (context, state) {
              if (state is GetChatListFailed) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  width: MediaQuery.sizeOf(context).width,
                  child: Center(
                    child: SomethingWentWrong(
                      errorMessage: state.error.toString(),
                    ),
                  ),
                );
              }
              if (state is GetChatListInProgress) {
                return buildChatListShimmer();
              }
              if (state is GetChatListSuccess) {
                if (state.chatedUserList.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        CustomImage(
                          imageUrl: AppIcons.noChatFound,
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          'noChats'.translate(context),
                          fontWeight: .w600,
                          fontSize: context.font.xl,
                          color: context.color.tertiaryColor,
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          'startConversation'.translate(context),
                          textAlign: .center,
                          fontSize: context.font.md,
                        ),
                        const SizedBox(height: 48),
                        UiUtils.buildButton(
                          context,
                          outerPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              Routes.searchScreenRoute,
                            );
                          },
                          buttonTitle: 'allProperties'.translate(context),
                          height: 48.rh(context),
                          showElevation: false,
                        ),
                        const SizedBox(height: 8),
                        UiUtils.buildButton(
                          context,
                          outerPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          onPressed: () async {
                            await context.read<GetChatListCubit>().fetch(
                              forceRefresh: true,
                            );
                          },
                          buttonTitle: 'retry'.translate(context),
                          buttonColor: Colors.transparent,
                          height: 48.rh(context),
                          textColor: context.color.tertiaryColor,
                          showElevation: false,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  physics: Constant.scrollPhysics,
                  controller: chatScreenController,
                  itemCount: state.chatedUserList.length,
                  padding: const EdgeInsetsDirectional.all(16),
                  itemBuilder: (context, index) {
                    final chatedUser = state.chatedUserList[index];

                    return ChatTile(
                      id: chatedUser.userId.toString(),
                      propertyId: chatedUser.propertyId.toString(),
                      profilePicture: chatedUser.profile ?? '',
                      userName: chatedUser.name ?? '',
                      propertyPicture: chatedUser.titleImage ?? '',
                      propertyName:
                          chatedUser.translatedTitle ?? chatedUser.title ?? '',
                      pendingMessageCount:
                          chatedUser.unreadCount?.toString() ?? '',
                      isBlockedByMe: chatedUser.isBlockedByMe ?? false,
                      isBlockedByUser: chatedUser.isBlockedByUser ?? false,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget buildChatListShimmer() {
    return ListView.builder(
      itemCount: 10,
      physics: Constant.scrollPhysics,
      padding: const EdgeInsetsDirectional.all(16),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 74.rh(context),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
                highlightColor: Theme.of(
                  context,
                ).colorScheme.shimmerHighlightColor,
                child: Stack(
                  children: [
                    SizedBox(width: 58.rw(context), height: 58.rh(context)),
                    Container(
                      width: 42.rw(context),
                      height: 42.rh(context),
                      clipBehavior: .antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(
                          color: context.color.secondaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    PositionedDirectional(
                      end: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: .circle,
                          color: Colors.grey,
                        ),
                        height: 32.rh(context),
                        width: 32.rw(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .center,
                children: [
                  CustomShimmer(
                    height: 10,
                    borderRadius: 4,
                    width: 220.rw(context),
                  ),
                  const SizedBox(height: 10),
                  CustomShimmer(
                    height: 10,
                    borderRadius: 4,
                    width: 180.rw(context),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => false;
}

class ChatTile extends StatelessWidget {
  const ChatTile({
    required this.profilePicture,
    required this.userName,
    required this.propertyPicture,
    required this.propertyName,
    required this.pendingMessageCount,
    required this.id,
    required this.propertyId,
    required this.isBlockedByMe,
    required this.isBlockedByUser,
    super.key,
  });

  final String profilePicture;
  final String userName;
  final String propertyPicture;
  final String propertyName;
  final String propertyId;
  final String pendingMessageCount;
  final String id;
  final bool isBlockedByMe;
  final bool isBlockedByUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          CupertinoPageRoute<dynamic>(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => LoadChatMessagesCubit()),
                  BlocProvider(create: (context) => DeleteMessageCubit()),
                ],
                child: Builder(
                  builder: (context) {
                    return ChatScreenNew(
                      profilePicture: profilePicture,
                      proeprtyTitle: propertyName,
                      userId: id,
                      propertyImage: propertyPicture,
                      userName: userName,
                      propertyId: propertyId,
                      isBlockedByMe: isBlockedByMe,
                      isBlockedByUser: isBlockedByUser,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      child: AbsorbPointer(
        child: Container(
          margin: const EdgeInsetsDirectional.only(bottom: 8),
          height: 74.rh(context),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.color.borderColor, width: 1.5),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Stack(
                  children: [
                    SizedBox(width: 62.rw(context), height: 62.rh(context)),
                    Container(
                      width: 52.rw(context),
                      height: 52.rh(context),
                      clipBehavior: .antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CustomImage(
                        imageUrl: propertyPicture,
                      ),
                    ),
                    PositionedDirectional(
                      end: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: .circle,
                          border: Border.all(
                            color: context.color.secondaryColor,
                            width: 2,
                          ),
                        ),
                        child: profilePicture == ''
                            ? CircleAvatar(
                                radius: 16,
                                backgroundColor: context.color.tertiaryColor,
                                child: CustomImage(
                                  imageUrl: appSettings.placeholderLogo!,
                                ),
                              )
                            : CircleAvatar(
                                radius: 16,
                                backgroundColor: context.color.tertiaryColor,
                                backgroundImage: NetworkImage(profilePicture),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        child: CustomText(
                          userName,
                          maxLines: 1,
                          fontWeight: .bold,
                          color: context.color.textColorDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: CustomText(
                          propertyName,
                          maxLines: 1,
                          color: context.color.textColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pendingMessageCount != '0')
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.color.tertiaryColor,
                      shape: .circle,
                    ),
                    child: CustomText(
                      pendingMessageCount,
                      color: context.color.buttonColor,
                      fontWeight: .bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
