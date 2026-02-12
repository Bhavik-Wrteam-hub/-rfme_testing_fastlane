import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebroker/app/app.dart';
import 'package:ebroker/utils/custom_appbar.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenImageView extends StatefulWidget {
  const FullScreenImageView({
    required this.provider,
    super.key,
    this.showDownloadButton,
    this.onTapDownload,
  });
  final ImageProvider provider;
  final bool? showDownloadButton;
  final VoidCallback? onTapDownload;

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  String getExtentionOfFile() {
    if (widget.provider is NetworkImage) {
      return (widget.provider as NetworkImage).getURL().split('.').last;
    }
    return '';
  }

  String getFileName() {
    if (widget.provider is NetworkImage) {
      return (widget.provider as NetworkImage).getURL().split('.').last;
    }
    return (widget.provider as NetworkImage).getURL().split('/').last;
  }

  Future<void> downloadFile() async {
    try {
      final downloadPath = await getDownloadPath();
      if (widget.provider is! NetworkImage) {
        return;
      }

      await Dio().download(
        (widget.provider as NetworkImage).getURL(),
        '${downloadPath!}/${getFileName()}',
        onReceiveProgress: (int count, int total) async {
          final persontage = count / total;

          if (persontage == 1) {
            HelperUtils.showSnackBarMessage(
              context,
              'fileSavedIn',
              type: .success,
            );

            await OpenFilex.open('$downloadPath/${getFileName()}');
          }
          setState(() {});
        },
      );
    } on Exception catch (e) {
      log('Download Error is: $e');
      HelperUtils.showSnackBarMessage(
        context,
        'errorFileSave',
        type: .success,
      );
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } on Exception catch (_) {
      if (kDebugMode) {
        HelperUtils.showSnackBarMessage(
          context,
          'fileNotSaved',
          type: .success,
        );
      }
    }
    return directory?.path;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          actions: [
            if ((widget.showDownloadButton ?? false) &&
                widget.provider is NetworkImage)
              IconButton(
                onPressed: () async {
                  await downloadFile();
                  widget.onTapDownload?.call();
                },
                icon: const Icon(Icons.download),
              ),
          ],
        ),
        backgroundColor: context.color.secondaryColor,
        body: InteractiveViewer(
          maxScale: 4,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: GestureDetector(
                onTap: () {},
                child: Image(
                  image: widget.provider,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: context.color.tertiaryColor.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomImage(
                        imageUrl: appSettings.placeholderLogo!,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return FittedBox(
                      fit: .none,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: UiUtils.progress(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension S on NetworkImage {
  String getURL() {
    return url;
  }
}
