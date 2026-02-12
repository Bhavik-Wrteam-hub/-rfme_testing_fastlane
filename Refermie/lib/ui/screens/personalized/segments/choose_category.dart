part of '../personalized_property_screen.dart';

class CategoryInterestChoose extends StatefulWidget {
  const CategoryInterestChoose({
    required this.controller,
    required this.onInteraction,
    required this.type,
    required this.onClearFilter,
    super.key,
  });

  final PageController controller;
  final VoidCallback onClearFilter;
  final PersonalizedVisitType type;
  final dynamic Function(List<int> selectedCategoryId) onInteraction;

  @override
  State<CategoryInterestChoose> createState() => _CategoryInterestChooseState();
}

class _CategoryInterestChooseState extends State<CategoryInterestChoose>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedCategoryId = personalizedInterestSettings.categoryIds;

  @override
  Widget build(BuildContext context) {
    final isFirstTime = widget.type == PersonalizedVisitType.firstTime;
    final isFetchCategoryLoading =
        context.watch<FetchCategoryCubit>().state is FetchCategoryInProgress;
    final categories = context.watch<FetchCategoryCubit>().getCategories();
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'personalizedFeed'.translate(context),
        actions: [
          if (!isFirstTime && selectedCategoryId.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.onClearFilter.call();
              },
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 18),
                child: CustomText(
                  'clear'.translate(context),
                  fontWeight: .bold,
                  showUnderline: true,
                  color: context.color.textColorDark,
                  fontSize: context.font.md,
                ),
              ),
            ),
          if (isFirstTime)
            GestureDetector(
              onTap: () async {
                await HelperUtils.killPreviousPages(
                  context,
                  Routes.main,
                  {'from': 'login'},
                );
              },
              child: CustomText(
                'skip'.translate(context),
                color: context.color.buttonColor,
              ),
            ),
        ],
      ),
      body: categories.isEmpty
          ? Center(
              child: NoDataFound(
                title: 'noCategoryFound'.translate(context),
                description: 'noCategoryFoundDescription'.translate(context),
                onTapRetry: () async {
                  await context.read<FetchCategoryCubit>().fetchCategories();
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    'chooseYourInterest'.translate(context),
                    fontSize: context.font.md,
                    color: context.color.textColorDark,
                    fontWeight: .w500,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (isFetchCategoryLoading)
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        return CustomShimmer(
                          borderRadius: 4,
                          height: 85.rh(context),
                          width: 108.rw(context),
                        );
                      },
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        physics: Constant.scrollPhysics,
                        itemBuilder: (BuildContext context, int index) {
                          final category = categories[index];
                          final isSelected = selectedCategoryId.contains(
                            int.parse(category.id!.toString()),
                          );
                          return GestureDetector(
                            onTap: () {
                              selectedCategoryId.addOrRemove(
                                int.parse(category.id!.toString()),
                              );
                              widget.onInteraction.call(selectedCategoryId);
                              setState(() {});
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.color.tertiaryColor
                                    : context.color.secondaryColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: context.color.borderColor,
                                ),
                              ),
                              height: 85.rh(context),
                              width: 108.rw(context),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: .center,
                                children: [
                                  SizedBox(
                                    height: 24.rh(context),
                                    width: 24.rw(context),
                                    child: CustomImage(
                                      imageUrl: category.image ?? '',
                                      color: isSelected
                                          ? context.color.buttonColor
                                          : context.color.textColorDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  CustomText(
                                    category.translatedName ??
                                        category.category ??
                                        '',
                                    textAlign: .center,
                                    maxLines: 2,
                                    fontSize: context.font.xs,
                                    color: isSelected
                                        ? context.color.buttonColor
                                        : context.color.textColorDark,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
