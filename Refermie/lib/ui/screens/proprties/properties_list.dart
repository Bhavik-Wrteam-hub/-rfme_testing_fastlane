import 'dart:developer';

import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/banner_ad_load_widget.dart';
import 'package:ebroker/utils/admob/interstitial_ad_manager.dart';
import 'package:flutter/material.dart';

class PropertiesList extends StatefulWidget {
  const PropertiesList({super.key, this.categoryId, this.categoryName});
  final String? categoryId;
  final String? categoryName;

  @override
  PropertiesListState createState() => PropertiesListState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => PropertiesList(
        categoryId: arguments?['catID'].toString(),
        categoryName: arguments?['catName'].toString() ?? '',
      ),
    );
  }
}

class PropertiesListState extends State<PropertiesList> {
  int offset = 0;
  int total = 0;

  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  int adPosition = 9;
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  FilterApply? selectedFilter;
  @override
  void initState() {
    super.initState();
    searchbody = {};
    loadAd();
    unawaited(interstitialAdManager.load());
    Constant.propertyFilter = null;
    controller = ScrollController()..addListener(_loadMore);
    unawaited(
      context.read<FetchPropertyFromCategoryCubit>().fetchPropertyFromCategory(
        int.parse(widget.categoryId!),
        showPropertyType: false,
      ),
    );

    Future.delayed(Duration.zero, () {
      selectedcategoryId = widget.categoryId!;
      selectedcategoryName = widget.categoryName!;
      searchbody[Api.categoryId] = widget.categoryId;
      setState(() {});
    });
  }

  void loadAd() {}

  @override
  void dispose() {
    controller
      ..removeListener(_loadMore)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (controller.isEndReached()) {
      if (context.read<FetchPropertyFromCategoryCubit>().hasMoreData()) {
        await context
            .read<FetchPropertyFromCategoryCubit>()
            .fetchPropertyFromCategoryMore();
      }
    }
  }

  Widget? noInternetCheck(dynamic error) {
    if (error is NoInternetConnectionError) {
      return NoInternet(
        onRetry: () async {
          await context
              .read<FetchPropertyFromCategoryCubit>()
              .fetchPropertyFromCategory(
                int.parse(widget.categoryId!),
                showPropertyType: false,
              );
        },
      );
    }

    return null;
  }

  int itemIndex = 0;
  @override
  Widget build(BuildContext context) {
    return bodyWidget();
  }

  Widget bodyWidget() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await interstitialAdManager.show();
        Constant.propertyFilter = null;
        Future.delayed(
          Duration.zero,
          () {
            Navigator.pop(context);
          },
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: CustomAppBar(
          title: selectedcategoryName == ''
              ? widget.categoryName ?? ''
              : selectedcategoryName,
          actions: [
            filterOptionsBtn(),
          ],
        ),
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: BannerAdWidget(bannerSize: AdSize.banner),
        ),
        body:
            BlocBuilder<
              FetchPropertyFromCategoryCubit,
              FetchPropertyFromCategoryState
            >(
              builder: (context, state) {
                if (state is FetchPropertyFromCategoryInProgress) {
                  return UiUtils.buildHorizontalShimmer(context);
                }

                if (state is FetchPropertyFromCategoryFailure) {
                  log('state--- ${state.errorMessage}');
                  final error = noInternetCheck(state.errorMessage);
                  if (error != null) {
                    return error;
                  }
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    width: MediaQuery.sizeOf(context).width,
                    child: Center(
                      child: SomethingWentWrong(
                        errorMessage: state.errorMessage.toString(),
                      ),
                    ),
                  );
                }
                if (state is FetchPropertyFromCategorySuccess) {
                  if (state.propertymodel.isEmpty) {
                    return Center(
                      child: NoDataFound(
                        title: 'noPropertiesFound'.translate(context),
                        description: 'noPropertiesFoundDescription'.translate(
                          context,
                        ),
                        onTapRetry: () async {
                          await context
                              .read<FetchPropertyFromCategoryCubit>()
                              .fetchPropertyFromCategory(
                                int.parse(widget.categoryId!),
                                showPropertyType: false,
                              );
                        },
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 8.rh(context));
                          },
                          shrinkWrap: true,
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.propertymodel.length,
                          physics: Constant.scrollPhysics,
                          itemBuilder: (context, index) {
                            final dynamic property = state.propertymodel[index];
                            if (property is PropertyModel) {
                              return PropertyHorizontalCard(
                                property: property,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      if (state.isLoadingMore)
                        UiUtils.progress(
                          height: 24.rh(context),
                          width: 24.rw(context),
                        ),
                    ],
                  );
                }
                return Container();
              },
            ),
      ),
    );
  }

  Widget filterOptionsBtn() {
    return GestureDetector(
      onTap: () async {
        // show filter screen
        await Navigator.pushNamed(
          context,
          Routes.filterScreen,
          arguments: {
            'showPropertyType': false,
            'filter': selectedFilter,
          },
        ).then((value) async {
          if (value == null) return;
          selectedFilter = value as FilterApply;
          await context
              .read<FetchPropertyFromCategoryCubit>()
              .fetchPropertyFromCategory(
                int.parse(widget.categoryId!),
                filter: value,
                showPropertyType: false,
              );
          setState(() {});
        });
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsetsDirectional.only(end: 12),
        child: CustomImage(
          imageUrl: AppIcons.filter,
          color: context.color.textColorDark,
          width: 24.rw(context),
          height: 24.rh(context),
        ),
      ),
    );
  }
}
