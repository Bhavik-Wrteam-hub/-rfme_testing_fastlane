import 'package:dio/dio.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailsWidget extends StatelessWidget {
  const ContactDetailsWidget({
    required this.url,
    required this.name,
    required this.email,
    required this.number,
    super.key,
  });

  final String url;
  final String name;
  final String email;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'contactUS'.translate(context),
            fontWeight: .bold,
            fontSize: context.font.md,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await UiUtils.showFullScreenImage(
                    context,
                    provider: NetworkImage(url),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  clipBehavior: .antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomImage(
                    imageUrl: url,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomText(
                      name,
                      maxLines: 1,
                      fontWeight: .bold,
                      fontSize: context.font.md,
                    ),
                    CustomText(
                      email,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: .end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.color.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: context.color.secondaryColor,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await launchUrl(Uri.parse('mailto:$email'));
                      },
                      icon: Icon(
                        Icons.email,
                        color: context.color.tertiaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.color.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: context.color.secondaryColor,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await launchUrl(Uri.parse('tel:+$number'));
                      },
                      icon: Icon(
                        Icons.call,
                        color: context.color.tertiaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DownloadableDocument extends StatefulWidget {
  const DownloadableDocument({required this.url, super.key});

  final String url;

  @override
  State<DownloadableDocument> createState() => _DownloadableDocumentState();
}

class _DownloadableDocumentState extends State<DownloadableDocument> {
  bool downloaded = false;
  Dio dio = Dio();
  ValueNotifier<double> percentage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  Future<String?>? path() async {
    final downloadPath = await HelperUtils.getDownloadPath();
    return downloadPath;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.url.split('/').last;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      horizontalTitleGap: 0,
      minTileHeight: 48.rh(context),
      title: CustomText(
        name,
        color: context.color.textColorDark.withValues(alpha: 0.9),
        fontSize: context.font.sm,
      ),
      trailing: ValueListenableBuilder(
        valueListenable: percentage,
        builder: (context, value, child) {
          if (value != 0.0 && value != 1.0) {
            return Container(
              padding: const EdgeInsets.all(4),
              height: 24.rh(context),
              width: 24.rw(context),
              child: CircularProgressIndicator(
                value: value,
                color: context.color.tertiaryColor,
              ),
            );
          }
          if (downloaded) {
            return GestureDetector(
              onTap: () async {
                final downloadPath = await path();

                await OpenFilex.open('$downloadPath/$name');
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                height: 24.rh(context),
                width: 24.rw(context),
                decoration: BoxDecoration(
                  color: context.color.textColorDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: context.color.borderColor,
                  ),
                ),
                child: CustomImage(
                  imageUrl: AppIcons.arrowRight,
                  color: context.color.textColorDark,
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: context.color.textColorDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: GestureDetector(
              onTap: () async {
                final downloadPath = await path();
                final storagePermission =
                    await HelperUtils.hasStoragePermissionGiven();
                if (storagePermission) {
                  await dio.download(
                    widget.url,
                    '$downloadPath/$name',
                    onReceiveProgress: (count, total) async {
                      percentage.value = count / total;
                      if (percentage.value == 1.0) {
                        downloaded = true;
                        setState(() {});
                        await OpenFilex.open('$downloadPath/$name');
                      }
                    },
                  );
                } else {
                  HelperUtils.showSnackBarMessage(
                    context,
                    'Storage Permission denied!',
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                width: 24.rw(context),
                height: 24.rh(context),
                child: CustomImage(
                  imageUrl: AppIcons.documentDownload,
                  color: context.color.textColorDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomFloorPlanTile extends StatefulWidget {
  const CustomFloorPlanTile({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;
  @override
  State<CustomFloorPlanTile> createState() => _CustomFloorPlanTileState();
}

class _CustomFloorPlanTileState extends State<CustomFloorPlanTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: ExpansionTile(
        minTileHeight: 48.rh(context),
        dense: true,
        childrenPadding: EdgeInsets.zero,
        tilePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        backgroundColor: Colors.transparent,
        title: CustomText(
          widget.title,
          color: context.color.textColorDark,
          fontSize: context.font.md,
        ),
        collapsedTextColor: context.color.textColorDark,
        textColor: context.color.textColorDark,
        trailing: Container(
          width: 24.rw(context),
          height: 24.rh(context),
          decoration: BoxDecoration(
            color: context.color.textColorDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: AnimatedCrossFade(
              firstChild: Icon(
                Icons.add,
                color: context.color.textColorDark,
                size: 20.rh(context),
              ),
              secondChild: Icon(
                Icons.remove,
                size: 20.rh(context),
                color: context.color.textColorDark,
              ),
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              excludeBottomFocus: false,
            ),
          ),
        ),
        onExpansionChanged: (value) {
          isExpanded = value;
          setState(() {});
        },
        children: widget.children,
      ),
    );
  }
}

Widget categoryCard(BuildContext context, ProjectModel project) {
  return Row(
    mainAxisAlignment: .center,
    mainAxisSize: .min,
    children: [
      Container(
        width: 24.rw(context),
        height: 24.rh(context),
        alignment: Alignment.center,
        child: CustomImage(
          imageUrl: project.category?.image ?? '',
          color: context.color.textColorDark,
        ),
      ),
      const SizedBox(width: 4),
      CustomText(
        project.category?.translatedName ?? project.category?.category ?? '',
        color: context.color.textColorDark,
        fontSize: context.font.sm,
      ),
    ],
  );
}
