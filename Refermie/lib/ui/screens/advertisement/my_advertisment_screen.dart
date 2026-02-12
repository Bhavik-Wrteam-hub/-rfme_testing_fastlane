import 'package:ebroker/data/cubits/delete_advertisment_cubit.dart';
import 'package:ebroker/data/cubits/project/fetch_my_promoted_projects.dart';
import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/advertisement_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/advertisement_horizontal_card.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:ebroker/utils/custom_tabbar.dart';
import 'package:flutter/material.dart';

class MyAdvertisementScreen extends StatefulWidget {
  const MyAdvertisementScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const MyAdvertisementScreen(),
    );
  }

  @override
  State<MyAdvertisementScreen> createState() => _MyAdvertisementScreenState();
}

class _MyAdvertisementScreenState extends State<MyAdvertisementScreen>
    with TickerProviderStateMixin {
  final ScrollController _propertiesScrollController = ScrollController();
  final ScrollController _projectsScrollController = ScrollController();
  late TabController _tabController;
  Map<String, String>? statusMap;
  String advertisementType = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    unawaited(
      context.read<FetchMyPromotedPropertysCubit>().fetchMyPromotedPropertys(),
    );
    unawaited(
      context.read<FetchMyPromotedProjectsCubit>().fetchMyPromotedProjects(),
    );

    Future.delayed(
      Duration.zero,
      () {
        statusMap = {
          '0': 'approved'.translate(context),
          '1': 'pending'.translate(context),
          '2': 'rejected'.translate(context),
          '3': 'expired'.translate(context),
        };
      },
    );

    _propertiesScrollController.addListener(_propertiesScroll);
    _projectsScrollController.addListener(_projectsScroll);
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _propertiesScrollController.dispose();
    _projectsScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _propertiesScroll() {
    if (_propertiesScrollController.isEndReached()) {
      if (context.read<FetchMyPromotedPropertysCubit>().hasMoreData()) {
        unawaited(
          context
              .read<FetchMyPromotedPropertysCubit>()
              .fetchMyPromotedPropertysMore(),
        );
      }
    }
  }

  void _projectsScroll() {
    if (_projectsScrollController.isEndReached()) {
      if (context.read<FetchMyPromotedProjectsCubit>().hasMoreData()) {
        unawaited(
          context
              .read<FetchMyPromotedProjectsCubit>()
              .fetchMyPromotedProjectsMore(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: CustomAppBar(
        title: 'myAds'.translate(context),
      ),
      body: Column(
        children: [
          CustomTabBar(
            margin: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
            ),
            tabController: _tabController,
            isScrollable: false,
            tabs: [
              Tab(text: 'properties'.translate(context)),
              Tab(text: 'projects'.translate(context)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPropertiesTab(),
                _buildProjectsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        await context
            .read<FetchMyPromotedPropertysCubit>()
            .fetchMyPromotedPropertys();
      },
      child:
          BlocBuilder<
            FetchMyPromotedPropertysCubit,
            FetchMyPromotedPropertysState
          >(
            builder: (context, state) {
              if (state is FetchMyPromotedPropertysInProgress) {
                return UiUtils.buildHorizontalShimmer(context);
              }
              if (state is FetchMyPromotedPropertysFailure) {
                return SomethingWentWrong(
                  errorMessage: state.errorMessage.toString(),
                );
              }
              if (state is FetchMyPromotedPropertysSuccess) {
                if (state.advertisement.isEmpty) {
                  return NoDataFound(
                    title: 'noFeaturedAdsYet'.translate(context),
                    description: 'noFeaturedDescription'.translate(context),
                    onTapRetry: () {
                      unawaited(
                        context
                            .read<FetchMyPromotedPropertysCubit>()
                            .fetchMyPromotedPropertys(),
                      );
                      setState(() {});
                    },
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ColoredBox(
                        color: context.color.primaryColor,
                        child: ListView.builder(
                          physics: Constant.scrollPhysics,
                          controller: _propertiesScrollController,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final model = state.advertisement[index];
                            return _buildAdvertisementPropertyCard(
                              context,
                              model,
                              isProperty: true,
                            );
                          },
                          itemCount: state.advertisement.length,
                        ),
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

  Widget _buildProjectsTab() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        await context
            .read<FetchMyPromotedProjectsCubit>()
            .fetchMyPromotedProjects();
      },
      child:
          BlocBuilder<
            FetchMyPromotedProjectsCubit,
            FetchMyPromotedProjectsState
          >(
            builder: (context, state) {
              if (state is FetchMyPromotedProjectsInProgress) {
                return UiUtils.buildHorizontalShimmer(context);
              }
              if (state is FetchMyPromotedProjectsFailure) {
                return SingleChildScrollView(
                  physics: Constant.scrollPhysics,
                  child: SomethingWentWrong(
                    errorMessage: state.errorMessage.toString(),
                  ),
                );
              }
              if (state is FetchMyPromotedProjectsSuccess) {
                if (state.advertisement.isEmpty) {
                  return NoDataFound(
                    title: 'noFeaturedAdsYet'.translate(context),
                    description: 'noFeaturedProjectsDescription'.translate(
                      context,
                    ),
                    onTapRetry: () {
                      unawaited(
                        context
                            .read<FetchMyPromotedProjectsCubit>()
                            .fetchMyPromotedProjects(),
                      );
                      setState(() {});
                    },
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: Constant.scrollPhysics,
                        controller: _projectsScrollController,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final model = state.advertisement[index];
                          return _buildAdvertisementProjectCard(
                            context,
                            model,
                            isProperty: false,
                          );
                        },
                        itemCount: state.advertisement.length,
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

  Widget _buildAdvertisementPropertyCard(
    BuildContext context,
    AdvertisementProperty advertisement, {
    required bool isProperty,
  }) {
    return BlocProvider(
      create: (context) => DeleteAdvertismentCubit(AdvertisementRepository()),
      child: MyAdvertisementPropertyHorizontalCard(
        advertisement: advertisement,
        showLikeButton: false,
        isPropertyPromoted: advertisement.status == '0',
        isPropertyPremium: advertisement.property.isPremium ?? false,
        statusButton: StatusButton(
          lable: statusMap![advertisement.status].toString().firstUpperCase(),
          color: statusColor(advertisement.status),
          textColor: context.color.buttonColor,
        ),
        showDeleteButton: true,
        // isProperty: isProperty,
      ),
    );
  }

  Widget _buildAdvertisementProjectCard(
    BuildContext context,
    AdvertisementProject advertisement, {
    required bool isProperty,
  }) {
    return BlocProvider(
      create: (context) => DeleteAdvertismentCubit(AdvertisementRepository()),
      child: MyAdvertisementProjectHorizontalCard(
        advertisement: advertisement,
        showLikeButton: false,
        isProjectPromoted: advertisement.project.isPromoted ?? false,
        isProjectPremium: true,
        statusButton: StatusButton(
          lable: statusMap![advertisement.status].toString().firstUpperCase(),
          color: statusColor(advertisement.status),
          textColor: context.color.buttonColor,
        ),
        showDeleteButton: true,
      ),
    );
  }

  Color statusColor(String status) {
    if (status == '0') {
      return Colors.green;
    } else if (status == '1') {
      return Colors.orangeAccent;
    } else if (status == '2') {
      return Colors.red;
    } else if (status == '3') {
      return Colors.redAccent;
    }
    return Colors.transparent;
  }
}
