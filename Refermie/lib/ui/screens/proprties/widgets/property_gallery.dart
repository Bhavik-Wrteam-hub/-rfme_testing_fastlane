import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/all_gallary_image.dart';
import 'package:ebroker/ui/screens/widgets/video_view_screen.dart';
import 'package:flutter/material.dart';

class PropertyGallery extends StatelessWidget {
  const PropertyGallery({
    required this.gallary,
    required this.youtubeVideoThumbnail,
    required this.flickManager,
    required this.onShowGoogleMap,
    super.key,
  });
  final List<Gallery>? gallary;
  final String youtubeVideoThumbnail;
  final FlickManager? flickManager;
  final VoidCallback onShowGoogleMap;

  @override
  Widget build(BuildContext context) {
    if (gallary?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          'gallery'.translate(context),
          fontWeight: .w600,
          color: context.color.textColorDark,
          fontSize: context.font.md,
        ),
        SizedBox(height: 8.rh(context)),
        SizedBox(
          height: 90.rh(context),
          width: double.infinity,
          child: ListView.separated(
            scrollDirection: .horizontal,
            itemCount: gallary?.length.clamp(0, 5) ?? 0,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (gallary?[index].isVideo ?? false) {
                        return;
                      }

                      // Hide Google map before showing image gallery
                      onShowGoogleMap();

                      final images = gallary?.map((e) => e.imageUrl).toList();

                      await UiUtils.imageGallaryView(
                        context,
                        images: images!,
                        initalIndex: index,
                        then: onShowGoogleMap,
                      );
                    },
                    child: SizedBox(
                      width: 90.rw(context),
                      height: 90.rh(context),
                      child: gallary?[index].isVideo ?? false
                          ? CustomImage(imageUrl: youtubeVideoThumbnail)
                          : CustomImage(
                              imageUrl: gallary?[index].imageUrl ?? '',
                            ),
                    ),
                  ),
                  _buildVideoOverlay(context, index),
                  _buildMoreImagesOverlay(context, index),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoOverlay(BuildContext context, int index) {
    if (!(gallary?[index].isVideo ?? false)) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute<dynamic>(
              builder: (context) {
                return VideoViewScreen(
                  videoUrl: gallary?[index].image ?? '',
                  flickManager: flickManager,
                );
              },
            ),
          );
        },
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.3),
          child: FittedBox(
            fit: .none,
            child: Container(
              decoration: BoxDecoration(
                shape: .circle,
                color: context.color.tertiaryColor.withValues(alpha: 0.8),
              ),
              width: 30,
              height: 30,
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreImagesOverlay(BuildContext context, int index) {
    if (index != 4 || (gallary?.length ?? 0) <= 5) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute<dynamic>(
              builder: (context) {
                return AllGallaryImages(
                  youtubeThumbnail: youtubeVideoThumbnail,
                  images: gallary ?? [],
                );
              },
            ),
          );
        },
        child: Container(
          alignment: Alignment.center,
          color: Colors.black.withValues(alpha: 0.3),
          child: CustomText(
            '+${(gallary?.length ?? 0) - 3}',
            fontWeight: .bold,
            fontSize: context.font.md,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ProjectGallery extends StatelessWidget {
  const ProjectGallery({
    required this.gallary,
    required this.onShowGoogleMap,
    super.key,
  });
  final List<ProjectGalleryModel>? gallary;
  final VoidCallback onShowGoogleMap;

  @override
  Widget build(BuildContext context) {
    if (gallary?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          'gallery'.translate(context),
          fontWeight: .w600,
          color: context.color.textColorDark,
          fontSize: context.font.md,
        ),
        SizedBox(height: 8.rh(context)),
        SizedBox(
          height: 90.rh(context),
          width: double.infinity,
          child: ListView.separated(
            scrollDirection: .horizontal,
            itemCount: gallary?.length.clamp(0, 5) ?? 0,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Hide Google map before showing image gallery
                      onShowGoogleMap();

                      final images = gallary?.map((e) => e.imageUrl).toList();

                      await UiUtils.imageGallaryView(
                        context,
                        images: images!,
                        initalIndex: index,
                        then: onShowGoogleMap,
                      );
                    },
                    child: SizedBox(
                      width: 90.rw(context),
                      height: 90.rh(context),
                      child: CustomImage(
                        imageUrl: gallary?[index].imageUrl ?? '',
                      ),
                    ),
                  ),
                  _buildMoreImagesOverlay(context, index),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreImagesOverlay(BuildContext context, int index) {
    if (index != 4 || (gallary?.length ?? 0) <= 5) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute<dynamic>(
              builder: (context) {
                return AllGallaryImages(
                  youtubeThumbnail: '',
                  images: gallary ?? [],
                );
              },
            ),
          );
        },
        child: Container(
          alignment: Alignment.center,
          color: Colors.black.withValues(alpha: 0.3),
          child: CustomText(
            '+${(gallary?.length ?? 0) - 3}',
            fontWeight: .bold,
            fontSize: context.font.md,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
