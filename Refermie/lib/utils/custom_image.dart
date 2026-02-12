import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebroker/app/app.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fit = .cover,
    this.color,
    super.key,
    this.cacheHeight,
    this.cacheWidth,
    this.isCircular = false,
    this.matchTextDirection = false,
    this.showFullScreenImage = false,
    this.loadingImageHash,
  });

  const CustomImage.circular({
    required this.imageUrl,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fit = .cover,
    this.color,
    super.key,
    this.cacheHeight,
    this.cacheWidth,
    this.isCircular = true,
    this.matchTextDirection = false,
    this.showFullScreenImage = false,
    this.loadingImageHash,
  });

  final String imageUrl;

  final bool isCircular;
  final Alignment alignment;
  final BoxFit fit;
  final Color? color;
  final double? height;
  final double? width;
  final double? cacheHeight;
  final double? cacheWidth;
  final bool matchTextDirection;
  final bool showFullScreenImage;
  final String? loadingImageHash;
  @override
  Widget build(BuildContext context) {
    final errorImg = appSettings.placeholderLogo ?? '';
    final image = imageUrl.isEmpty ? errorImg : imageUrl;

    final isNetworked = image.startsWith('http');
    final isSvg = image.endsWith('.svg');

    final colorFilter = color != null
        ? ColorFilter.mode(color!, .srcIn)
        : null;

    final errorWidget = Image.network(
      errorImg,
      width: width,
      height: height,
      fit: fit,
      matchTextDirection: matchTextDirection,
    );

    return GestureDetector(
      onTap: showFullScreenImage
          ? () async {
              await UiUtils.showFullScreenImage(
                context,
                provider: NetworkImage(image),
              );
            }
          : null,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: isCircular
              ? BorderRadius.circular(99999)
              : BorderRadius.zero,
          child: switch ((isNetworked, isSvg)) {
            // asset image
            (false, false) => Image.asset(
              image,
              fit: fit,
              alignment: alignment,
              errorBuilder: (_, o, s) => errorWidget,
              matchTextDirection: matchTextDirection,
              cacheHeight: 500,
              cacheWidth: 500,
            ),
            // svg image
            (false, true) => SvgPicture.asset(
              image,
              fit: fit,
              width: width,
              height: height,
              colorFilter: colorFilter,
              alignment: alignment,
              matchTextDirection: matchTextDirection,
            ),
            // network image
            (true, false) => CachedNetworkImage(
              fit: fit,
              alignment: alignment,
              imageUrl: image,
              placeholder: loadingImageHash != null &&
                      loadingImageHash!.isNotEmpty
                  ? (context, url) => Image.network(
                      loadingImageHash!,
                      width: width,
                      height: height,
                      fit: fit,
                      alignment: alignment,
                      matchTextDirection: matchTextDirection,
                    )
                  : null,
              errorWidget: (_, s, o) => errorWidget,
              matchTextDirection: matchTextDirection,
              memCacheHeight: 500,
              memCacheWidth: 500,
            ),
            //
            (true, true) => SvgPicture.network(
              image,
              colorFilter: colorFilter,
              fit: fit,
              alignment: alignment,
              matchTextDirection: matchTextDirection,
            ),
          },
        ),
      ),
    );
  }
}
