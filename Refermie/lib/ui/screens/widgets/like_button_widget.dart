import 'package:ebroker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:ebroker/data/cubits/favorite/fetch_favorites_cubit.dart';
import 'package:ebroker/data/cubits/utility/like_properties.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/guest_checker.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LikeButtonWidget extends StatefulWidget {
  const LikeButtonWidget({
    required this.propertyId,
    required this.isFavourite,
    super.key,
    this.isFromDetailsPage = false,
  });

  final int propertyId;
  final bool isFavourite;
  final bool isFromDetailsPage;

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1, end: 1.4),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.4, end: 1),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget setFavorite(int propertyId, BuildContext context) {
    return BlocListener<AddToFavoriteCubitCubit, AddToFavoriteCubitState>(
      listener: (BuildContext context, AddToFavoriteCubitState state) {
        if (state is AddToFavoriteCubitFailure &&
            state.id == widget.propertyId) {
          context.read<LikedPropertiesCubit>().toggleLike(widget.propertyId);
        }
      },
      child: BlocBuilder<LikedPropertiesCubit, LikedPropertiesState>(
        builder: (BuildContext context, likedState) {
          final isLiked =
              likedState.likedProperties.contains(widget.propertyId) ||
              widget.isFavourite;
          return GestureDetector(
            onTap: () async {
              await GuestChecker.check(
                onNotGuest: () async {
                  await _controller.forward(from: 0);

                  context.read<LikedPropertiesCubit>().toggleLike(
                    widget.propertyId,
                  );

                  final type = isLiked ? FavoriteType.remove : FavoriteType.add;
                  await context.read<AddToFavoriteCubitCubit>().setFavorite(
                    propertyId: widget.propertyId,
                    type: type,
                  );
                  if (type == FavoriteType.remove) {
                    context.read<FetchFavoritesCubit>().remove(
                      widget.propertyId,
                    );
                  }
                },
              );
            },
            child: Container(
              alignment: Alignment.center,
              width: widget.isFromDetailsPage ? 36.rw(context) : 24.rw(context),
              height: widget.isFromDetailsPage
                  ? 36.rw(context)
                  : 24.rw(context),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                shape: .circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 1),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: BlocBuilder<LikedPropertiesCubit, LikedPropertiesState>(
                builder: (context, state) {
                  return ScaleTransition(
                    scale: _scaleAnimation,
                    child: CustomImage(
                      width: widget.isFromDetailsPage
                          ? 24.rw(context)
                          : 18.rw(context),
                      height: widget.isFromDetailsPage
                          ? 24.rw(context)
                          : 18.rw(context),
                      imageUrl: isLiked ? AppIcons.heartFilled : AppIcons.heart,
                      color: context.color.tertiaryColor,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return setFavorite(widget.propertyId, context);
  }
}
