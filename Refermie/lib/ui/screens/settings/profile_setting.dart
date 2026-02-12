import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key, this.title, this.param});
  final String? title;
  final String? param;

  @override
  ProfileSettingsState createState() => ProfileSettingsState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => ProfileSettings(
        title: arguments?['title'] as String,
        param: arguments?['param'] as String,
      ),
    );
  }
}

class ProfileSettingsState extends State<ProfileSettings> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await context.read<ProfileSettingCubit>().fetchProfileSetting(
        widget.param!,
        forceRefresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: CustomAppBar(
        title: widget.title ?? '',
      ),
      body: BlocBuilder<ProfileSettingCubit, ProfileSettingState>(
        builder: (context, state) {
          if (state is ProfileSettingFetchProgress) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.tertiaryColor,
              ),
            );
          } else if (state is ProfileSettingFetchSuccess) {
            return contentWidget(state, context);
          } else if (state is ProfileSettingFetchFailure) {
            if (state.errmsg is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () async {
                  await context.read<ProfileSettingCubit>().fetchProfileSetting(
                    widget.param!,
                    forceRefresh: true,
                  );
                },
              );
            }

            return Center(
              child: SomethingWentWrong(
                errorMessage: state.errmsg?.toString() ?? '',
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

Widget contentWidget(ProfileSettingFetchSuccess state, BuildContext context) {
  return SingleChildScrollView(
    physics: Constant.scrollPhysics,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Html(
      data: state.data,
      onAnchorTap:
          (
            url,
            context,
            attributes,
          ) async {
            await launchUrl(
              Uri.parse(url!),
              mode: LaunchMode.externalApplication,
            );
          },
      style: {
        'table': Style(backgroundColor: context.color.secondaryColor),
        'p': Style(color: context.color.textColorDark),
        'p strong': Style(color: context.color.tertiaryColor),
        'th': Style(backgroundColor: context.color.textColorDark),
        'td': Style(border: Border.all(color: context.color.borderColor)),
        'h5': Style(color: context.color.textColorDark),
        'h6': Style(color: context.color.textColorDark),
        'h4': Style(color: context.color.textColorDark),
        'h1': Style(color: context.color.textColorDark),
        'h2': Style(color: context.color.textColorDark),
        'h3': Style(color: context.color.textColorDark),
        'li': Style(color: context.color.textColorDark),
        'ul': Style(color: context.color.textColorDark),
        'ol': Style(color: context.color.textColorDark),
      },
    ),
  );
}
