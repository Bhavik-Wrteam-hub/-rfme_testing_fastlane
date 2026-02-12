import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/city_properties_screen.dart';
import 'package:ebroker/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({
    required this.isWithImage,
    super.key,
    this.from,
    this.title,
  });

  final String? from;
  final bool isWithImage;
  final String? title;

  @override
  State<CityListScreen> createState() => _CityListScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return CupertinoPageRoute(
      builder: (_) => CityListScreen(
        from: args?['from'] as String? ?? '',
        title: args?['title'] as String? ?? '',
        isWithImage: args?['isWithImage'] as bool? ?? false,
      ),
    );
  }
}

class _CityListScreenState extends State<CityListScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    unawaited(
      context.read<FetchCityCategoryCubit>().fetchCityCategory(
        forceRefresh: false,
      ),
    );
    addPageScrollListener();
    super.initState();
  }

  void addPageScrollListener() {
    cityScreenController.addListener(pageScrollListener);
  }

  Future<void> pageScrollListener() async {
    ///This will load data on page end
    if (cityScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<FetchCityCategoryCubit>().hasMoreData()) {
          await context.read<FetchCityCategoryCubit>().fetchMore();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: widget.title ?? 'allCities'.translate(context),
      ),
      body: BlocBuilder<FetchCityCategoryCubit, FetchCityCategoryState>(
        builder: (context, state) {
          if (state is FetchCityCategoryInProgress) {
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.only(
                left: 18,
                right: 18,
                top: 8,
                bottom: 25,
              ),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    crossAxisCount: widget.isWithImage ? 2 : 3,
                    height: (widget.isWithImage ? 260 : 126).rh(
                      context,
                    ),
                  ),
              itemCount: 25,
              itemBuilder: (context, index) {
                return const CustomShimmer();
              },
            );
          }
          if (state is FetchCityCategoryFail) {
            return SomethingWentWrong(
              errorMessage: state.error.toString(),
            );
          }
          if (state is FetchCityCategorySuccess && state.cities.isEmpty) {
            return NoDataFound(
              title: 'noCityFound'.translate(context),
              description: 'noCityFoundDescription'.translate(
                context,
              ),
              onTapRetry: () async {
                await context.read<FetchCityCategoryCubit>().fetchCityCategory(
                  forceRefresh: true,
                );
              },
            );
          }
          if (state is FetchCityCategorySuccess && state.cities.isNotEmpty) {
            return SingleChildScrollView(
              controller: cityScreenController,
              physics: Constant.scrollPhysics,
              child: Column(
                children: <Widget>[
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 8,
                      bottom: 25,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          crossAxisCount: widget.isWithImage ? 2 : 3,
                          height: (widget.isWithImage ? 260 : 126).rh(
                            context,
                          ),
                        ),
                    itemCount: state.cities.length,
                    itemBuilder: (context, index) {
                      final city = state.cities[index];
                      if (widget.isWithImage) {
                        return CityCard(
                          count: city.count,
                          name: city.name,
                          city: city,
                        );
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            await context.read<FetchCityPropertyList>().fetch(
                              cityName: city.name,
                              forceRefresh: true,
                            );
                            await Navigator.push(
                              context,
                              CupertinoPageRoute<dynamic>(
                                builder: (context) {
                                  return CityPropertiesScreen(
                                    cityName: city.name,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.color.borderColor,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            width: 126.rw(context),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Container(
                                  width: 34.rw(context),
                                  height: 34.rh(context),
                                  decoration: BoxDecoration(
                                    color: context.color.tertiaryColor
                                        .withValues(
                                          alpha: 0.2,
                                        ),
                                    shape: .circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomImage(
                                    imageUrl: AppIcons.location,
                                    color: context.color.tertiaryColor,
                                    width: 24.rw(context),
                                    height: 24.rh(context),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Expanded(child: CustomText(city.name)),
                                const SizedBox(height: 8),
                                CustomText(
                                  '${city.count} ${'properties'.translate(context)}',
                                  fontSize: context.font.xs,
                                  color: context.color.tertiaryColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  if (context
                      .watch<FetchCityCategoryCubit>()
                      .isLoadingMore()) ...[
                    Center(child: UiUtils.progress()),
                  ],
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class CityCard extends StatelessWidget {
  const CityCard({
    required this.city,
    required this.name,
    required this.count,
    super.key,
    this.isFirst,
    this.showEndPadding,
  });

  final City city;
  final String count;
  final bool? isFirst;
  final bool? showEndPadding;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.read<FetchCityPropertyList>().fetch(
          cityName: city.name,
          forceRefresh: true,
        );
        await Navigator.push(
          context,
          CupertinoPageRoute<dynamic>(
            builder: (context) {
              return CityPropertiesScreen(
                cityName: city.name,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: context.color.secondaryColor,
        ),
        clipBehavior: .antiAlias,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: .antiAlias,
                child: CustomImage(
                  imageUrl: city.image,
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    CustomText(
                      city.name.firstUpperCase(),
                      fontWeight: .bold,
                      fontSize: context.font.md,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomText(
                      '${'properties'.translate(context)} (${city.count})',
                      fontSize: context.font.sm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
