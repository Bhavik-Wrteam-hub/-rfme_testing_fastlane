import 'package:ebroker/data/cubits/agents/fetch_project_by_agents_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_by_agent_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/create_appointment_request_cubit.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agent_properties.dart';
import 'package:ebroker/ui/screens/agents/agents_projects.dart';
import 'package:ebroker/ui/screens/agents/subscription_button.dart';
import 'package:ebroker/ui/screens/widgets/read_more_text.dart';
import 'package:ebroker/utils/custom_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentDetailsScreen extends StatefulWidget {
  const AgentDetailsScreen({
    required this.isAdmin,
    required this.agentID,
    super.key,
  });

  final bool isAdmin;
  final String agentID;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final argument = routeSettings.arguments! as Map;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => FetchAgentsProjectCubit(),
          ),
          BlocProvider(
            create: (_) => FetchProjectByAgentCubit(),
          ),
          BlocProvider(
            create: (_) => FetchPropertyByAgentCubit(),
          ),
        ],
        child: AgentDetailsScreen(
          isAdmin: argument['isAdmin'] as bool,
          agentID: argument['agentID'] as String,
        ),
      ),
    );
  }

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen>
    with TickerProviderStateMixin {
  bool showProjects = false;
  bool isProjectAllowed = false;
  TabController? _tabController;
  late ScrollController _scrollController;
  final GlobalKey _detailsContentKey = GlobalKey();
  final GlobalKey _tabViewKey = GlobalKey();
  bool _detailsRequiresScroll = false;
  int _currentTabIndex = 0;
  bool _isShowingSubscriptionDialog = false;

  void _initTabController(int length) {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _tabController = TabController(length: length, vsync: this);
    _currentTabIndex = _tabController?.index ?? 0;
    _tabController?.addListener(_handleTabChange);
    if (_currentTabIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _evaluateDetailsScrollability();
      });
    }
  }

  void _handleTabChange() {
    if (!mounted || _tabController == null) {
      return;
    }
    final newIndex = _tabController!.index;
    if (newIndex == _currentTabIndex) {
      return;
    }

    // Check if user is trying to access Projects tab without permission
    if (newIndex == 2 &&
        showProjects &&
        !isProjectAllowed &&
        !_isShowingSubscriptionDialog) {
      _isShowingSubscriptionDialog = true;
      // Prevent tab change by reverting to previous index
      _tabController!.index = _currentTabIndex;

      // Show subscription dialog
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          _isShowingSubscriptionDialog = false;
          return;
        }
        await GuestChecker.check(
          onNotGuest: () async {
            if (!mounted) {
              _isShowingSubscriptionDialog = false;
              return;
            }
            final result = await UiUtils.showBlurredDialoge(
              context,
              dialog: const BlurredSubscriptionDialogBox(
                packageType: SubscriptionPackageType.projectAccess,
                isAcceptContainesPush: true,
              ),
            );
            _isShowingSubscriptionDialog = false;

            if (result != true && mounted) {
              // User declined or closed dialog, switch to Properties tab
              _tabController?.animateTo(1);
            }
          },
        );
        _isShowingSubscriptionDialog = false;
      });
      return;
    }

    _currentTabIndex = newIndex;
    if (newIndex == 0) {
      // add scroll to top when details tab is selected

      Future.delayed(Duration.zero, () async {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _evaluateDetailsScrollability();
      });
    }
    setState(() {});
  }

  void _evaluateDetailsScrollability() {
    if (!mounted) {
      return;
    }
    final detailsContext = _detailsContentKey.currentContext;
    final tabViewContext = _tabViewKey.currentContext;

    if (detailsContext == null || tabViewContext == null) {
      return;
    }

    final detailsRenderBox = detailsContext.findRenderObject();
    final tabViewRenderBox = tabViewContext.findRenderObject();

    if (detailsRenderBox is RenderBox && tabViewRenderBox is RenderBox) {
      final needsScroll =
          detailsRenderBox.size.height > tabViewRenderBox.size.height;
      if (_detailsRequiresScroll != needsScroll) {
        setState(() {
          _detailsRequiresScroll = needsScroll;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initTabController(2);
    unawaited(getAgentProjectsAndProperties());

    _scrollController.addListener(_scrollListener);
  }

  Future<void> _scrollListener() async {
    // A small buffer (e.g., 20 pixels) for reaching the end to account for floating point inaccuracies
    // or slight overscrolls.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 20) {
      if (_tabController?.index == 1) {
        // Properties Tab
        if (context.read<FetchAgentsPropertyCubit>().hasMoreData()) {
          await context.read<FetchAgentsPropertyCubit>().fetchMore(
            isAdmin: widget.isAdmin,
          );
        }
      } else if (_tabController?.index == 2) {
        // Projects Tab
        if (context.read<FetchAgentsProjectCubit>().hasMoreData()) {
          await context.read<FetchAgentsProjectCubit>().fetchMore(
            isAdmin: widget.isAdmin,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _scrollController
      ..removeListener(_scrollListener)
      ..dispose();
    super.dispose();
  }

  Future<void> getAgentProjectsAndProperties() async {
    // Ensure initial fetches are complete before potentially updating tab controller length
    await context.read<FetchAgentsProjectCubit>().fetchAgentsProject(
      forceRefresh: true,
      agentId: widget.agentID,
      isAdmin: widget.isAdmin,
    );

    final projectState = context.read<FetchAgentsProjectCubit>().state;
    if (projectState is FetchAgentsProjectSuccess) {
      final hasProjects =
          projectState.agentsProperty.customerData.projectCount != '0';
      final needsProjectsTab = hasProjects;

      // Only update state if tab count needs to change to prevent unnecessary rebuilds
      if (showProjects != needsProjectsTab) {
        setState(() {
          showProjects = needsProjectsTab;
          isProjectAllowed = projectState.agentsProperty.isFeatureAvailable;
          // Re-initialize tab controller if the number of tabs changes
          _initTabController(showProjects ? 3 : 2);
        });
      }
    }

    await context.read<FetchAgentsPropertyCubit>().fetchAgentsProperty(
      forceRefresh: true,
      agentId: widget.agentID,
      isAdmin: widget.isAdmin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      CreateAppointmentRequestCubit,
      CreateAppointmentRequestState
    >(
      listener: (context, state) {
        if (state is CreateAppointmentRequestSuccess) {
          HelperUtils.showSnackBarMessage(
            context,
            'appointmentScheduledSuccessfully',
            type: .success,
          );
        }
        if (state is CreateAppointmentRequestFailure) {
          HelperUtils.showSnackBarMessage(
            context,
            state.errorMessage,
            type: .error,
          );
        }
      },
      child: BlocBuilder<FetchAgentsProjectCubit, FetchAgentsProjectState>(
        builder: (context, projectState) {
          return BlocBuilder<
            FetchAgentsPropertyCubit,
            FetchAgentsPropertyState
          >(
            builder: (context, propertyState) {
              return Scaffold(
                backgroundColor: context.color.backgroundColor,
                appBar: CustomAppBar(
                  title: 'agentDetails'.translate(context),
                  actions: [
                    if (propertyState is FetchAgentsPropertySuccess &&
                        propertyState.agentsProperty.premiumPropertyCount !=
                            '0' &&
                        !propertyState.agentsProperty.isPackageAvailable &&
                        !propertyState.agentsProperty.isFeatureAvailable)
                      _buildPremiumButton(
                        premiumPropertyCount: int.parse(
                          propertyState.agentsProperty.premiumPropertyCount,
                        ),
                      ),
                  ],
                ),
                body:
                    propertyState is FetchAgentsPropertyLoading ||
                        propertyState is FetchAgentsPropertyInitial ||
                        projectState is FetchAgentsProjectLoading ||
                        projectState is FetchAgentsProjectInitial
                    ? _buildShimmerView()
                    : propertyState is FetchAgentsPropertyFailure
                    ? Center(
                        child: SomethingWentWrong(
                          errorMessage: propertyState.errorMessage.toString(),
                        ),
                      )
                    : propertyState is FetchAgentsPropertySuccess
                    ? _buildNestedScrollView(
                        propertyState.agentsProperty.customerData,
                        propertyState,
                      )
                    : const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPremiumButton({required int premiumPropertyCount}) {
    return CustomPremiumButton(
      premiumPropertyCount: premiumPropertyCount,
      onPressed: () async {
        await GuestChecker.check(
          onNotGuest: () async {
            await Navigator.pushNamed(
              context,
              Routes.subscriptionPackageListRoute,
              arguments: {
                'from': 'agentDetails',
                'isBankTransferEnabled':
                    (context.read<GetApiKeysCubit>().state as GetApiKeysSuccess)
                        .bankTransferStatus ==
                    '1',
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerView() {
    return Column(
      // Changed from CustomScrollView for shimmer as it's a fixed view
      children: [
        Container(
          height: 224.rh(context),
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
          ),
          child: const CustomShimmer(),
        ),
        Container(
          height: 40.rh(context),
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
          ),
          child: const CustomShimmer(),
        ),
        // If this part needs to scroll for shimmer, wrap in Expanded + ListView
        // For a shimmer, a simple container is often fine unless it's very tall
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: const CustomShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildNestedScrollView(
    CustomerData agent,
    FetchAgentsPropertySuccess propertyState,
  ) {
    return BlocConsumer<FetchProjectByAgentCubit, FetchProjectByAgentState>(
      listener: (context, state) async {
        if (state is FetchProjectByAgentSuccess) {
          await HelperUtils.goToNextPage(
            Routes.projectDetailsScreen,
            context,
            false,
            args: {
              'project': state.project,
            },
          );
        }
      },
      builder: (context, projectState) {
        return BlocConsumer<
          FetchPropertyByAgentCubit,
          FetchPropertyByAgentState
        >(
          listener: (context, state) async {
            if (state is FetchPropertyByAgentSuccess) {
              await HelperUtils.goToNextPage(
                Routes.propertyDetails,
                context,
                false,
                args: {
                  'propertyData': state.property,
                },
              );
            }
          },
          builder: (context, state) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification) {
                  unawaited(_scrollListener());
                }
                return true;
              },
              child: NestedScrollView(
                controller: _scrollController,
                physics: _currentTabIndex == 0 && !_detailsRequiresScroll
                    ? const NeverScrollableScrollPhysics()
                    : null,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverToBoxAdapter(
                          child: buildAgentProfileCard(agent: agent),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickyTabBarDelegate(
                            tabBar: CustomTabBar(
                              tabController: _tabController!,
                              isScrollable: false,
                              tabs: [
                                Tab(text: 'details'.translate(context)),
                                Tab(text: 'properties'.translate(context)),
                                if (showProjects)
                                  Tab(text: 'projects'.translate(context)),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                body: Column(
                  children: [
                    Expanded(
                      child: Container(
                        key: _tabViewKey,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Builder(
                              builder: (context) {
                                if (_tabController?.index == 0) {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _evaluateDetailsScrollability(),
                                  );
                                }
                                return SingleChildScrollView(
                                  physics: _detailsRequiresScroll
                                      ? null
                                      : const NeverScrollableScrollPhysics(),
                                  child: KeyedSubtree(
                                    key: _detailsContentKey,
                                    child: detailsTab(
                                      context,
                                      propertyState.agentsProperty.customerData,
                                    ),
                                  ),
                                );
                              },
                            ),
                            AgentProperties(
                              agentId: propertyState
                                  .agentsProperty
                                  .customerData
                                  .id
                                  .toString(),
                              isAdmin: widget.isAdmin,
                            ),
                            if (showProjects)
                              isProjectAllowed
                                  ? AgentProjects(
                                      agentId: propertyState
                                          .agentsProperty
                                          .customerData
                                          .id
                                          .toString(),
                                      isAdmin: widget.isAdmin,
                                    )
                                  : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    if (agent.isAppointmentAvailable ?? false) bottomButton(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildAgentProfileCard({
    required CustomerData agent,
  }) {
    final showSocialAccounts =
        (agent.facebookId != null && agent.facebookId != '') ||
        (agent.twitterId != null && agent.twitterId != '') ||
        (agent.instagramId != null && agent.instagramId != '') ||
        (agent.youtubeId != null && agent.youtubeId != '');
    final showSoldRentedCount =
        agent.propertiesSoldCount != '0' || agent.propertiesRentedCount != '0';

    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        border: Border.all(
          color: context.color.borderColor,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Container(
                width: 115.rw(context),
                height: 128.rh(context),
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(4),
                          bottom: Radius.circular(
                            agent.isVerified ?? false ? 0 : 4,
                          ),
                        ),
                        child: CustomImage(
                          width: 115.rw(context),
                          imageUrl: agent.profile,
                        ),
                      ),
                    ),
                    if (agent.isVerified ?? false) buildVerifiedContainer(),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            agent.name.firstUpperCase(),
                            maxLines: 2,
                            fontWeight: .w500,
                            fontSize: context.font.sm,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await HelperUtils.shareAgent(
                              context,
                              agent.slugId,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.color.borderColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsetsDirectional.only(end: 8),
                            alignment: Alignment.center,
                            child: CustomImage(
                              imageUrl: AppIcons.shareIcon,
                              height: 16.rh(context),
                              color: context.color.textColorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      'Agent ID: ${agent.id}',
                      fontSize: context.font.xs,
                      fontWeight: .w500,
                      color: context.color.textLightColor,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    UiUtils.getDivider(context),
                    const SizedBox(height: 8),
                    Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        buildCallEmailContainer(
                          title: 'call'.translate(context),
                          icon: AppIcons.call,
                          value: agent.mobile,
                          onTap: () async {
                            await _onTapCall(contactNumber: agent.mobile);
                          },
                        ),
                        const SizedBox(height: 8),
                        buildCallEmailContainer(
                          title: 'email'.translate(context),
                          icon: AppIcons.email,
                          value: agent.email,
                          onTap: () async {
                            await _onTapEmail(email: agent.email);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showSoldRentedCount || showSocialAccounts) ...[
            const SizedBox(height: 8),
            UiUtils.getDivider(context),
            const SizedBox(height: 8),
          ],
          if (showSoldRentedCount) ...[
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.color.textColorDark.withValues(alpha: .1),
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceEvenly,
                    children: [
                      if (agent.propertiesSoldCount != '0')
                        CustomText(
                          '${'soldProperties'.translate(context)}: ${agent.propertiesSoldCount}',
                          fontSize: context.font.xxs,
                          fontWeight: .w500,
                          maxLines: 1,
                          color: context.color.textLightColor,
                        ),
                      if (agent.propertiesSoldCount != '0' &&
                          agent.propertiesRentedCount != '0')
                        Container(
                          margin: const EdgeInsetsDirectional.only(
                            start: 4,
                            end: 4,
                          ),
                          height: 8,
                          width: 1,
                          color: context.color.textLightColor.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      if (agent.propertiesRentedCount != '0')
                        CustomText(
                          '${'rentedProperties'.translate(context)}: ${agent.propertiesRentedCount}',
                          fontSize: context.font.xxs,
                          fontWeight: .w500,
                          color: context.color.textLightColor,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                if (showSocialAccounts) const SizedBox(height: 8),
              ],
            ),
          ],
          if (showSocialAccounts) ...[
            Row(
              children: [
                CustomText(
                  'followMe'.translate(context),
                  fontSize: context.font.sm,
                  fontWeight: .w500,
                ),
                const SizedBox(width: 8),
                if (agent.facebookId != null && agent.facebookId != '')
                  socialButton(
                    context: context,
                    name: 'facebook',
                    url: agent.facebookId ?? '',
                  ),
                if (agent.twitterId != null && agent.twitterId != '')
                  socialButton(
                    context: context,
                    name: 'twitter',
                    url: agent.twitterId ?? '',
                  ),
                if (agent.instagramId != null && agent.instagramId != '')
                  socialButton(
                    context: context,
                    name: 'instagram',
                    url: agent.instagramId ?? '',
                  ),
                if (agent.youtubeId != null && agent.youtubeId != '')
                  socialButton(
                    context: context,
                    name: 'youtube',
                    url: agent.youtubeId ?? '',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildVerifiedContainer() {
    return Container(
      padding: EdgeInsets.only(
        left: 8.rw(context),
        right: 8.rw(context),
        top: 4.rh(context),
        bottom: 4.rh(context),
      ),
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          CustomImage(
            imageUrl: AppIcons.verified,
            fit: .contain,
            height: 18.rh(context),
            width: 18.rw(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: CustomText(
              'verified'.translate(context),
              fontSize: context.font.xs,
              maxLines: 1,
              fontWeight: .w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget socialButton({
    required BuildContext context,
    required String name,
    required String url,
  }) {
    final String iconName;
    switch (name) {
      case 'facebook':
        iconName = AppIcons.facebook;
      case 'twitter':
        iconName = AppIcons.twitter;
      case 'instagram':
        iconName = AppIcons.instagram;
      case 'youtube':
        iconName = AppIcons.youtube;
      default:
        iconName = '';
    }
    if (iconName == '') {
      return const SizedBox.shrink();
    }
    final uri = Uri.parse(url);
    return GestureDetector(
      onTap: () async {
        await _launchUrl(uri);
      },
      child: Container(
        height: 24.rh(context),
        width: 24.rw(context),
        alignment: Alignment.center,
        margin: const EdgeInsetsDirectional.only(end: 8),
        decoration: BoxDecoration(
          color: context.color.textLightColor.withValues(alpha: .1),
          shape: .circle,
        ),
        child: CustomImage(
          height: 24.rh(context),
          width: 24.rw(context),
          imageUrl: iconName,
          color: context.color.textColorDark,
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget bottomButton() {
    if (widget.agentID == HiveUtils.getUserId()) {
      return const SizedBox.shrink();
    }

    return Container(
      color: context.color.secondaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      child: UiUtils.buildButton(
        context,
        onPressed: () async {
          await GuestChecker.check(
            onNotGuest: () async {
              final propertyState = context
                  .read<FetchAgentsPropertyCubit>()
                  .state;
              if (propertyState is FetchAgentsPropertySuccess) {
                await Navigator.pushNamed(
                  context,
                  Routes.appointmentFlow,
                  arguments: {
                    'isAdmin': widget.isAdmin,
                    'agentDetails': propertyState.agentsProperty.customerData,
                  },
                );
              } else {
                // Show error or loading state
                HelperUtils.showSnackBarMessage(
                  context,
                  'Please wait for properties to load',
                );
              }
            },
          );
        },
        height: 48.rh(context),
        fontSize: context.font.md,
        buttonTitle: 'scheduleAppointment'.translate(context),
      ),
    );
  }

  Widget detailsTab(BuildContext context, CustomerData customerData) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        border: Border.all(
          color: context.color.borderColor,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'addressLbl'.translate(context),
            fontSize: context.font.sm,
            fontWeight: .w600,
          ),
          const SizedBox(height: 8),
          ReadMoreText(
            text: customerData.address ?? '',
            style: TextStyle(
              fontSize: context.font.xs,
              fontWeight: .w500,
              color: context.color.textLightColor,
            ),
          ),
          const SizedBox(height: 8),
          UiUtils.getDivider(context),
          const SizedBox(height: 8),
          if (customerData.aboutMe!.isNotEmpty) ...[
            CustomText(
              'aboutAgent'.translate(context),
              fontSize: context.font.sm,
              fontWeight: .w600,
            ),
            const SizedBox(height: 8),
            CustomText(
              customerData.aboutMe ?? '',
              fontSize: context.font.xs,
              fontWeight: .w500,
              color: context.color.textLightColor,
              maxLines: 100,
            ),
          ],
        ],
      ),
    );
  }

  List<String> locationName({
    required BuildContext context,
    required CustomerData customerData,
  }) {
    final location = <String>[
      if (customerData.city!.isNotEmpty) '${customerData.city}',
      if (customerData.state!.isNotEmpty) ...[
        if (customerData.city!.isNotEmpty) ', ',
        '${customerData.state}',
      ],
      if (customerData.country!.isNotEmpty) ...[
        if (customerData.state!.isNotEmpty || customerData.city!.isNotEmpty)
          ',',
        '${customerData.country}',
      ],
    ];

    if (location.isEmpty) {
      return [];
    } else {
      return location;
    }
  }

  Widget buildCallEmailContainer({
    required String title,
    required String icon,
    required String value,
    required VoidCallback onTap,
  }) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 40.rh(context),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            Container(
              alignment: Alignment.center,
              width: 28.rw(context),
              height: 28.rh(context),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.color.textLightColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomImage(
                imageUrl: icon,
                color: context.color.textColorDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    title,
                    fontSize: context.font.sm,
                    fontWeight: .w600,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: CustomText(
                      value,
                      fontWeight: .w500,
                      fontSize: context.font.xxs,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapCall({
    required String contactNumber,
  }) async {
    await GuestChecker.check(
      onNotGuest: () async {
        final url = Uri.parse('tel: +$contactNumber');
        try {
          await launchUrl(url);
        } on Exception catch (e) {
          throw Exception('Error calling $e');
        }
      },
    );
  }

  Future<void> _onTapEmail({
    required String email,
  }) async {
    await GuestChecker.check(
      onNotGuest: () async {
        final url = Uri.parse('mailto: $email');
        try {
          await launchUrl(url);
        } on Exception catch (e) {
          throw Exception('Error mail $e');
        }
      },
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate({required this.tabBar});
  final Widget tabBar;

  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 80;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: context.color.backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
