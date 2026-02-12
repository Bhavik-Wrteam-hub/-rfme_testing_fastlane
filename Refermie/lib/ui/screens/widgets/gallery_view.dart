import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebroker/utils/admob/interstitial_ad_manager.dart';
import 'package:ebroker/utils/custom_appbar.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class GalleryViewWidget extends StatefulWidget {
  const GalleryViewWidget({
    required this.images,
    required this.initalIndex,
    super.key,
  });
  final List<dynamic> images;
  final int initalIndex;

  @override
  State<GalleryViewWidget> createState() => _GalleryViewWidgetState();
}

class _GalleryViewWidgetState extends State<GalleryViewWidget> {
  List<dynamic> images = [];
  late PageController controller = PageController(
    initialPage: widget.initalIndex,
  );
  late int page = widget.initalIndex;
  InterstitialAdManager admanager = InterstitialAdManager();

  @override
  void initState() {
    images = List.from(widget.images);
    unawaited(admanager.load());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      backgroundColor: context.color.backgroundColor,
      body: PageView.builder(
        controller: controller,
        onPageChanged: (value) async {
          page = value;
          if (page.isEven) {
            await admanager.show();
          }
          setState(() {});
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            maxScale: 5,
            child: CachedNetworkImage(
              imageUrl: images[index]?.toString() ?? '',
            ),
          );
        },
        itemCount: (images..removeWhere((element) => (element == ''))).length,
      ),
    );
  }
}
