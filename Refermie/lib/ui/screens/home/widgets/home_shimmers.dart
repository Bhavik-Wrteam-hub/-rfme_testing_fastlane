import 'package:ebroker/ui/screens/widgets/custom_shimmer.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class HomeShimmer extends StatefulWidget {
  const HomeShimmer({super.key});

  @override
  State<HomeShimmer> createState() => _HomeShimmerState();
}

ScrollController _scrollController = ScrollController();

void initState() {
  _scrollController.addListener(() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  });
}

class _HomeShimmerState extends State<HomeShimmer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        controller: _scrollController,
        physics: Constant.scrollPhysics,
        children: [
          CustomShimmer(
            height: 170,
            width: context.screenWidth,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48.rh(context),
            child: ListView.builder(
              scrollDirection: .horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return CustomShimmer(
                  margin: const EdgeInsetsDirectional.only(end: 12),
                  height: 48.rh(context),
                  width: 84.rw(context),
                );
              },
              itemCount: 5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 274.rh(context),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: .horizontal,
              itemBuilder: (context, index) {
                return CustomShimmer(
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  height: 274.rh(context),
                  width: 290.rw(context),
                );
              },
              itemCount: 5,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return CustomShimmer(
                  height: 130.rh(context),
                  margin: const EdgeInsetsDirectional.only(bottom: 12),
                );
              },
              itemCount: 3,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class PromotedPropertiesShimmer extends StatelessWidget {
  const PromotedPropertiesShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: SizedBox(
        height: 261,
        child: ListView.builder(
          itemCount: 5,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          scrollDirection: .horizontal,
          physics: Constant.scrollPhysics,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
              child: const CustomShimmer(
                height: 272,
                width: 250,
              ),
            );
          },
        ),
      ),
    );
  }
}

class NearbyPropertiesShimmer extends StatelessWidget {
  const NearbyPropertiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: 5,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          scrollDirection: .horizontal,
          physics: Constant.scrollPhysics,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
              child: const CustomShimmer(
                height: 200,
                width: 300,
              ),
            );
          },
        ),
      ),
    );
  }
}

class HorizontalCardsShimmer extends StatelessWidget {
  const HorizontalCardsShimmer({
    super.key,
    this.height = 240,
    this.cardWidth = 260,
    this.count = 5,
  });

  final double height;
  final double cardWidth;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: SizedBox(
        height: height.rh(context),
        child: ListView.builder(
          itemCount: count,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: .horizontal,
          physics: Constant.scrollPhysics,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsetsDirectional.only(
                end: index == count - 1 ? 0 : 10,
              ),
              child: CustomShimmer(
                height: height.rh(context),
                width: cardWidth.rw(context),
              ),
            );
          },
        ),
      ),
    );
  }
}
