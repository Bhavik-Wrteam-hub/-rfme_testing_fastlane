import 'dart:developer';

import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/banner_ad_load_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.autoFocus,
    super.key,
  });
  final bool autoFocus;
  static Route<dynamic> route(RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (context) {
        return SearchScreen(
          autoFocus: arguments?['autoFocus'] as bool? ?? false,
        );
      },
    );
  }

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;
  bool isFocused = false;
  String previouseSearchQuery = '';
  static TextEditingController searchController = TextEditingController();
  int offset = 0;
  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  List<dynamic> idlist = [];
  Timer? _searchDelay;
  FilterApply? selectedFilter;
  bool showContent = true;
  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<SearchPropertyCubit>().searchProperty(
        '',
        offset: 0,
        filter: selectedFilter,
      ),
    );
    searchController = TextEditingController();
    searchController.addListener(searchPropertyListener);
    controller = ScrollController()..addListener(pageScrollListen);
  }

  Future<void> pageScrollListen() async {
    if (controller.isEndReached()) {
      if (context.read<SearchPropertyCubit>().hasMoreData()) {
        await context.read<SearchPropertyCubit>().fetchMoreSearchData();
      }
    }
  }

  //this will listen and manage search
  void searchPropertyListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

  //This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), propertySearch);
  }

  ///This will call api after some delay
  Future<void> propertySearch() async {
    // if (searchController.text.isNotEmpty) {
    if (previouseSearchQuery != searchController.text) {
      await context.read<SearchPropertyCubit>().searchProperty(
        searchController.text,
        offset: 0,
        filter: selectedFilter,
      );
      previouseSearchQuery = searchController.text;
    }
    // } else {
    // context.read<SearchPropertyCubit>().clearSearch();
    // }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'search'.translate(context),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: Column(
        children: [
          searchTextField(),
          Expanded(
            child: BlocBuilder<SearchPropertyCubit, SearchPropertyState>(
              builder: (context, state) {
                return listWidget(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget listWidget(SearchPropertyState state) {
    if (state is SearchPropertyFetchProgress) {
      return UiUtils.buildHorizontalShimmer(context);
    }
    if (state is SearchPropertyFailure) {
      if (state.errorMessage is NoInternetConnectionError) {
        return NoInternet(
          onRetry: () async {
            await context.read<SearchPropertyCubit>().searchProperty(
              '',
              offset: 0,
              filter: selectedFilter,
            );
          },
        );
      }

      return SomethingWentWrong(
        errorMessage: state.errorMessage.toString(),
      );
    }

    if (state is SearchPropertySuccess) {
      if (state.searchedroperties.isEmpty) {
        return NoDataFound(
          onTapRetry: () async {
            await context.read<SearchPropertyCubit>().searchProperty(
              '',
              offset: 0,
              filter: selectedFilter,
            );
          },
          title: 'noPropertiesFound'.translate(context),
          description: 'noPropertyAdded'.translate(context),
        );
      }
      return SingleChildScrollView(
        controller: controller,
        physics: Constant.scrollPhysics,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              if (ResponsiveHelper.isLargeTablet(context) ||
                  ResponsiveHelper.isLargeTablet(context))
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 130.rh(context),
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.searchedroperties.length,
                  itemBuilder: (context, index) {
                    final property = state.searchedroperties[index];
                    final propertiesList = state.searchedroperties;
                    return PropertyHorizontalCard(
                      property: property,
                      properties: propertiesList,
                      isFromSearch: true,
                    );
                  },
                )
              else
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.searchedroperties.length,
                  itemBuilder: (context, index) {
                    final property = state.searchedroperties[index];
                    final propertiesList = state.searchedroperties;
                    return PropertyHorizontalCard(
                      property: property,
                      properties: propertiesList,
                      isFromSearch: true,
                    );
                  },
                ),
              if (state.isLoadingMore)
                UiUtils.progress(
                  height: 24.rh(context),
                  width: 24.rw(context),
                ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget setSearchIcon() {
    return Container(
      margin: EdgeInsets.only(
        right: 8,
        left: 8,
        top: 8.rs(context),
        bottom: 8.rs(context),
      ),
      child: CustomImage(
        imageUrl: AppIcons.search,
        color: context.color.tertiaryColor,
        width: 22.rw(context),
        height: 22.rh(context),
      ),
    );
  }

  Widget searchTextField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 48.rh(context),
      child: Row(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: SizedBox(
              height: 48.rh(context),
              child: CustomTextFormField(
                borderColor: context.color.borderColor,
                controller: searchController,
                fillColor: Theme.of(context).colorScheme.secondaryColor,
                hintText: 'searchHintLbl'.translate(context),
                prefix: setSearchIcon(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              try {
                await Navigator.pushNamed(
                  context,
                  Routes.filterScreen,
                  arguments: {
                    'showPropertyType': true,
                    'filter': selectedFilter,
                  },
                ).then((value) async {
                  if (value != null) {
                    selectedFilter = value as FilterApply;
                    await context.read<SearchPropertyCubit>().searchProperty(
                      searchController.text,
                      offset: 0,
                      filter: value,
                    );
                    setState(() {});
                  }
                });
              } on Exception catch (e, st) {
                log('error is $e stack is $st');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                border: Border.all(color: context.color.borderColor),
                borderRadius: BorderRadius.circular(4),
              ),
              width: 48.rh(context),
              height: 48.rh(context),
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                child: CustomImage(
                  imageUrl: AppIcons.filter,
                  width: 22.rw(context),
                  height: 22.rh(context),
                  color: context.color.tertiaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
