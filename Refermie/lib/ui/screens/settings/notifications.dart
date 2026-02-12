import 'package:ebroker/data/model/notification_data.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

late NotificationData selectedNotification;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  NotificationsState createState() => NotificationsState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const Notifications(),
    );
  }
}

class NotificationsState extends State<Notifications> {
  bool isNotificationsEnabled = true;

  late final ScrollController _pageScrollController = ScrollController();
  List<PropertyModel> propertyData = [];
  @override
  void initState() {
    super.initState();
    _pageScrollController.addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchNotificationsCubit>().hasMoreData()) {
          unawaited(
            context.read<FetchNotificationsCubit>().fetchNotificationsMore(),
          );
        }
      }
    });
    unawaited(context.read<FetchNotificationsCubit>().fetchNotifications());
  }

  @override
  void dispose() {
    Routes.currentRoute = Routes.previousCustomerRoute;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: CustomAppBar(
        title: 'notifications'.translate(context),
      ),
      body: BlocBuilder<FetchNotificationsCubit, FetchNotificationsState>(
        builder: (context, state) {
          if (state is FetchNotificationsInProgress) {
            return buildNotificationShimmer();
          }
          if (state is FetchNotificationsFailure) {
            if (state.errorMessage is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () async {
                  await context
                      .read<FetchNotificationsCubit>()
                      .fetchNotifications();
                },
              );
            }
            return SomethingWentWrong(
              errorMessage: state.errorMessage.toString(),
            );
          }

          if (state is FetchNotificationsSuccess) {
            if (state.notificationdata.isEmpty) {
              return NoDataFound(
                title: 'noNotificationsFound'.translate(context),
                description: 'noNotificationsFoundDescription'.translate(
                  context,
                ),
                onTapRetry: () async {
                  await context
                      .read<FetchNotificationsCubit>()
                      .fetchNotifications();
                },
              );
            }
            if (state.notificationdata.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _pageScrollController,
                      physics: Constant.scrollPhysics,
                      padding: const EdgeInsets.all(10),
                      itemCount: state.notificationdata.length,
                      itemBuilder: (context, index) {
                        final notificationData = state.notificationdata[index];
                        return GestureDetector(
                          onTap: () async {
                            selectedNotification = notificationData;
                            if (notificationData.type ==
                                Constant.enquiryNotification) {
                            } else {
                              await HelperUtils.goToNextPage(
                                Routes.notificationDetailPage,
                                context,
                                false,
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryColor,
                              border: Border.all(
                                color: context.color.borderColor,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: <Widget>[
                                if (notificationData.image != null)
                                  GestureDetector(
                                    onTap: () async {
                                      await UiUtils.showFullScreenImage(
                                        context,
                                        provider: CachedNetworkImageProvider(
                                          notificationData.image!,
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                      child: CustomImage(
                                        imageUrl: notificationData.image!,
                                        height: 48.rh(context),
                                        width: 48.rw(context),
                                        fit: .fill,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        .start,
                                    children: <Widget>[
                                      CustomText(
                                        notificationData.title!
                                            .firstUpperCase(),
                                        maxLines: 1,
                                        color: context.color.textColorDark,
                                        fontSize: context.font.lg,
                                      ),
                                      CustomText(
                                        notificationData.message!
                                            .firstUpperCase(),
                                        maxLines: 2,
                                        fontSize: context.font.xs,
                                        color: context.color.textColorDark,
                                      ),
                                      CustomText(
                                        notificationData.createdAt!
                                            .formatDate(),
                                        fontSize: context.font.xs,
                                        color: context.color.textLightColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if ((context.read<FetchNotificationsCubit>().state
                          as FetchNotificationsSuccess)
                      .isLoadingMore) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: UiUtils.progress(
                        height: 24.rh(context),
                        width: 24.rw(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildNotificationShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: 20,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 56.rh(context),
          child: Row(
            children: <Widget>[
              CustomShimmer(
                width: 48.rw(context),
                height: 48.rh(context),
                borderRadius: 11,
              ),
              SizedBox(
                width: 8.rw(context),
              ),
              Column(
                mainAxisAlignment: .spaceEvenly,
                crossAxisAlignment: .start,
                children: <Widget>[
                  CustomShimmer(
                    height: 7.rh(context),
                    width: 200.rw(context),
                  ),
                  SizedBox(height: 4.rh(context)),
                  CustomShimmer(
                    height: 7.rh(context),
                    width: 100.rw(context),
                  ),
                  SizedBox(height: 4.rh(context)),
                  CustomShimmer(
                    height: 7.rh(context),
                    width: 150.rw(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
