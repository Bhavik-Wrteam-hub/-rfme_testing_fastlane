import 'dart:io';

import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class PanaromaImageScreen extends StatelessWidget {
  const PanaromaImageScreen({
    required this.imageUrl,
    super.key,
    this.isFileImage,
  });
  final String imageUrl;
  final bool? isFileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsetsDirectional.only(start: 8),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            shape: .circle,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CustomImage(
              imageUrl: AppIcons.arrowLeft,
              matchTextDirection: true,
              fit: .none,
              color: context.color.tertiaryColor,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: PanoramaViewer(
        child: (isFileImage ?? false)
            ? Image.file(File(imageUrl))
            : Image.network(
                imageUrl,
              ),
      ),
    );
  }
}
