import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class DownloadableDocuments extends StatefulWidget {
  const DownloadableDocuments({required this.url, super.key});
  final String url;

  @override
  State<DownloadableDocuments> createState() => _DownloadableDocumentsState();
}

class _DownloadableDocumentsState extends State<DownloadableDocuments> {
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
      horizontalTitleGap: 0,
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      minTileHeight: 24.rh(context),
      title: CustomText(
        name,
        fontSize: context.font.sm,
        color: context.color.textColorDark,
      ),
      trailing: ValueListenableBuilder(
        valueListenable: percentage,
        builder: (context, value, child) {
          if (value != 0.0 && value != 1.0) {
            return Container(
              padding: const EdgeInsets.all(4),
              alignment: Alignment.center,
              width: 24.rw(context),
              height: 24.rh(context),
              decoration: BoxDecoration(
                color: context.color.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: UiUtils.progress(
                width: 16.rw(context),
                height: 16.rh(context),
                normalProgressColor: context.color.tertiaryColor,
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
                alignment: Alignment.center,
                width: 24.rw(context),
                height: 24.rh(context),
                decoration: BoxDecoration(
                  color: context.color.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomImage(
                  imageUrl: AppIcons.arrowRight,
                  color: context.color.tertiaryColor,
                ),
              ),
            );
          }
          return GestureDetector(
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
              decoration: BoxDecoration(
                color: context.color.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              width: 24.rw(context),
              height: 24.rh(context),
              child: CustomImage(
                imageUrl: AppIcons.documentDownload,
                color: context.color.textColorDark,
              ),
            ),
          );
        },
      ),
    );
  }
}
