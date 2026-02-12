import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class NotificationDetail extends StatefulWidget {
  const NotificationDetail({super.key});

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const NotificationDetail(),
    );
  }
}

class _NotificationDetailState extends State<NotificationDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'notifications'.translate(context),
      ),
      body: ListView(
        children: <Widget>[
          if (selectedNotification.image!.isNotEmpty)
            CustomImage(
              imageUrl: selectedNotification.image ?? '',
              width: double.maxFinite,
              fit: .fill,
              height: 224.rh(context),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: detailWidget(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Routes.currentRoute = Routes.previousCustomerRoute;
    super.dispose();
  }

  Column detailWidget() {
    return Column(
      crossAxisAlignment: .start,
      children: <Widget>[
        CustomText(
          selectedNotification.title!,
        ),
        const SizedBox(height: 5),
        CustomText(
          selectedNotification.message!,
        ),
      ],
    );
  }
}
