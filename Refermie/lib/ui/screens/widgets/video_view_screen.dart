import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/youtube_player_widget.dart';
import 'package:flutter/material.dart';

class VideoViewScreen extends StatefulWidget {
  const VideoViewScreen({
    required this.videoUrl,
    super.key,
    this.flickManager,
  });
  final String videoUrl;
  final FlickManager? flickManager;

  @override
  State<VideoViewScreen> createState() => _VideoViewScreenState();
}

class _VideoViewScreenState extends State<VideoViewScreen> {
  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      await SystemChrome.setPreferredOrientations([
        .portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        .manual,
        overlays: [.top, .bottom],
      );
    });

    super.dispose();
  }

  Future<void> _handleBackNavigation() async {
    await SystemChrome.setPreferredOrientations([
      .portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      .manual,
      overlays: [.top, .bottom],
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          backgroundColor: Colors.transparent,
          showBackButton: false,
          titleWidget: GestureDetector(
            onTap: _handleBackNavigation,
            child: SizedBox(
              width: 24.rh(context),
              height: 24.rh(context),
              child: CustomImage(
                imageUrl: AppIcons.arrowLeft,
                width: 24.rh(context),
                height: 24.rh(context),
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Center(
          child: HelperUtils.checkVideoType(
            widget.videoUrl,
            onYoutubeVideo: () {
              return YoutubePlayerWidget(
                videoUrl: widget.videoUrl,
                onLandscape: () {},
                onPortrate: () {},
              );
            },
            onOtherVideo: () {
              if (widget.flickManager != null) {
                return FlickVideoPlayer(
                  flickManager: widget.flickManager!,
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
