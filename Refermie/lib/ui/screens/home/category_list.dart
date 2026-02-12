import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/banner_ad_load_widget.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, this.from});

  final String? from;

  @override
  State<CategoryList> createState() => _CategoryListState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => CategoryList(from: args?['from']?.toString() ?? ''),
    );
  }
}

class _CategoryListState extends State<CategoryList>
    with TickerProviderStateMixin {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    unawaited(context.read<FetchCategoryCubit>().fetchCategories());
    _pageScrollController.addListener(() async {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchCategoryCubit>().hasMoreData()) {
          await context.read<FetchCategoryCubit>().fetchCategoriesMore();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: CustomAppBar(
        title: 'categoriesLbl'.translate(context),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
        builder: (context, state) {
          final isTablet =
              ResponsiveHelper.isTablet(context) ||
              ResponsiveHelper.isLargeTablet(context);
          if (state is FetchCategoryInProgress) {
            return GridView.builder(
              controller: _pageScrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              itemCount: 27,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 5 : 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio:
                    MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 2.5),
              ),
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.all(1.5),
                  child: CustomShimmer(
                    borderRadius: 8,
                  ),
                );
              },
            );
          }
          if (state is FetchCategorySuccess) {
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _pageScrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: state.categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 5 : 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return GestureDetector(
                        onTap: () async {
                          if (widget.from == Routes.filterScreen) {
                            Navigator.pop(context, category);
                          } else {
                            Constant.propertyFilter = null;
                            await HelperUtils.goToNextPage(
                              Routes.propertiesList,
                              context,
                              false,
                              args: {
                                'catID': category.id,
                                'catName':
                                    category.translatedName ??
                                    category.category,
                              },
                            ); //pass current index category id & name here
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.color.borderColor,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: .center,
                            mainAxisSize: .min,
                            children: <Widget>[
                              Container(
                                width: 48.rw(context),
                                height: 48.rh(context),
                                alignment: Alignment.center,
                                child: CustomImage(
                                  imageUrl: category.image ?? '',
                                  width: 48.rw(context),
                                  height: 48.rh(context),
                                  color: context.color.textColorDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CustomText(
                                category.translatedName ??
                                    category.category ??
                                    '',
                                textAlign: .center,
                                maxLines: 2,
                                fontSize: context.font.xs,
                                fontWeight: .w500,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
