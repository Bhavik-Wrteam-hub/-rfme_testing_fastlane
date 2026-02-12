import 'dart:async';

import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/project/change_project_status_cubit.dart';
import 'package:ebroker/data/cubits/project/delete_project_cubit.dart';
import 'package:ebroker/data/cubits/project/fetch_my_projects_list_cubit.dart';
import 'package:ebroker/data/cubits/subscription/get_subsctiption_package_limits_cubit.dart';
import 'package:ebroker/data/cubits/system/get_api_keys_cubit.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/ui/screens/advertisement/create_advertisement_popup.dart';
import 'package:ebroker/ui/screens/project/widgets/project_helpers.dart';
import 'package:ebroker/ui/screens/proprties/widgets/agent_profile.dart';
import 'package:ebroker/ui/screens/proprties/widgets/google_map_screen.dart';
import 'package:ebroker/ui/screens/proprties/widgets/property_gallery.dart';
import 'package:ebroker/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/ui/screens/widgets/read_more_text.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/cloud_state/cloud_state.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/custom_appbar.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({
    required this.project,
    super.key,
  });

  final ProjectModel project;

  static CupertinoPageRoute<dynamic> route(RouteSettings settings) {
    final arguement = settings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => DeleteProjectCubit(),
          child: ProjectDetailsScreen(
            project: arguement?['project'] as ProjectModel? ?? ProjectModel(),
          ),
        );
      },
    );
  }

  @override
  CloudState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends CloudState<ProjectDetailsScreen> {
  static const detailsPageSizedBoxHeight = 8.0;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final ValueNotifier<bool> _isEnabled = ValueNotifier(false);

  late final ProjectModel _project;
  late final bool _isMyProject;
  String? youtubeVideoThumbnail;
  FlickManager? flickManager;
  bool showGoogleMap = false;
  late final FetchMyProjectsListCubit _myProjectsCubit;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _myProjectsCubit = context.read<FetchMyProjectsListCubit>();

    _isEnabled.value = _project.status.toString() == '1';
    _isMyProject = _checkIsProjectMine();
    if (widget.project.videoLink != '' &&
        widget.project.videoLink != null &&
        HelperUtils.isYoutubeVideo(widget.project.videoLink ?? '')) {
      final videoId = YoutubePlayer.convertUrlToId(widget.project.videoLink!);
      final thumbnail = YoutubePlayer.getThumbnail(videoId: videoId!);
      youtubeVideoThumbnail = thumbnail;
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(widget.project.videoLink!),
        ),
      );
      flickManager?.onVideoEnd = () {};
      setState(() {});
    }
    Future.delayed(
      const Duration(seconds: 3),
      () {
        showGoogleMap = true;
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _isEnabled.dispose();

    flickManager?.dispose();
    super.dispose();
  }

  bool _checkIsProjectMine() {
    return _project.addedBy.toString() == HiveUtils.getUserId();
  }

  bool get _hasFloors => _project.plans?.isNotEmpty ?? false;
  bool get _hasDocuments => _project.documents?.isNotEmpty ?? false;

  Future<void> _onBackPress() async {
    if (!mounted) return;

    if (_isMyProject) {
      // Ensure context is still mounted
      await _myProjectsCubit.fetchMyProjects();
    }

    setState(() {
      showGoogleMap = false;
    });
  }

  Future<void> _handleStatusChange(bool newValue) async {
    final cubit = context.read<ChangeProjectStatusCubit>();
    final currentState = cubit.state;

    if (currentState is ChangeProjectStatusInProgress) return;

    final status = _isEnabled.value ? 0 : 1;
    _isEnabled.value = newValue;

    try {
      await cubit.enableProject(
        projectId: _project.id!,
        status: status,
      );

      final newState = cubit.state;
      if (newState is ChangeProjectStatusFailure) {
        _isEnabled.value = !newValue;
        final errorMessage = newState.error.contains('429')
            ? 'tooManyRequestsPleaseWait'.translate(context)
            : newState.error;

        HelperUtils.showSnackBarMessage(
          context,
          errorMessage,
          type: .error,
        );
      }
    } on Exception catch (_) {
      _isEnabled.value = !newValue;
      HelperUtils.showSnackBarMessage(
        context,
        'somethingWentWrng',
        type: .error,
      );
    }
  }

  Widget _buildEnableDisableSwitch() {
    return Container(
      height: 48.rh(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Row(
        children: [
          CustomText(
            'updateProjectStatus'.translate(context),
            fontSize: context.font.md,
            color: context.color.textColorDark,
            fontWeight: .w600,
          ),
          const Spacer(),
          ValueListenableBuilder<bool>(
            valueListenable: _isEnabled,
            builder: (context, value, child) {
              return Switch(
                thumbColor: const WidgetStatePropertyAll(
                  Colors.white,
                ),
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                thumbIcon: const WidgetStatePropertyAll(
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                  ),
                ),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey,
                activeTrackColor: context.color.tertiaryColor,
                trackColor: .resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return context.color.textColorDark.withValues(alpha: 0.1);
                    }
                    if (states.contains(WidgetState.selected)) {
                      return context.color.tertiaryColor;
                    }
                    return Colors.grey;
                  },
                ),
                value: value,
                onChanged:
                    _project.requestStatus.toString().toLowerCase() !=
                        'approved'
                    ? null
                    : _handleStatusChange,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            categoryCard(context, _project),
            const Spacer(),
            Container(
              height: 36.rh(context),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: context.color.textColorDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(48),
              ),
              child: CustomText(
                _project.type?.translate(context) ?? '',
                fontWeight: .w600,
                fontSize: context.font.sm,
                color: context.color.textColorDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomText(
          _project.translatedTitle ?? _project.title?.firstUpperCase() ?? '',
          fontWeight: .w700,
          fontSize: context.font.md,
          color: context.color.textColorDark,
        ),
        const SizedBox(height: 4),
        CustomText(
          'Project ID: ${_project.id ?? ''}',
          fontWeight: .w500,
          fontSize: context.font.xs,
          color: context.color.textLightColor,
        ),
      ],
    );
  }

  Widget _buildProjectDescription() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'aboutThisProjectLbl'.translate(context),
            fontWeight: .w500,
            fontSize: context.font.md,
          ),
          const SizedBox(height: 8),
          UiUtils.getDivider(context),
          const SizedBox(height: 8),
          ReadMoreText(
            text:
                _project.translatedDescription ??
                _project.description?.trim() ??
                '',
            style: TextStyle(
              fontWeight: .w400,
              fontSize: context.font.xs,
              color: context.color.textColorDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    if (!_hasDocuments) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'Documents'.translate(context),
            fontWeight: .w500,
            fontSize: context.font.md,
          ),
          const SizedBox(height: 8),
          UiUtils.getDivider(context),
          const SizedBox(height: 8),
          ListView.separated(
            separatorBuilder: (context, index) => UiUtils.getDivider(context),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final document = _project.documents![index];
              return DownloadableDocument(url: document.name!);
            },
            itemCount: _project.documents!.length,
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlansSection() {
    if (!_hasFloors) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'floorPlans'.translate(context),
            fontWeight: .w500,
            fontSize: context.font.md,
          ),
          const SizedBox(height: 8),
          UiUtils.getDivider(context),
          const SizedBox(height: 8),
          ListView.separated(
            separatorBuilder: (context, index) => UiUtils.getDivider(context),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _project.plans!.length,
            itemBuilder: (context, index) {
              final floor = _project.plans![index];
              return CustomFloorPlanTile(
                title: floor.title!,
                children: [Image.network(floor.document!)],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'projectLocation'.translate(context),
            fontWeight: .w500,
            fontSize: context.font.md,
          ),
          const SizedBox(height: 8),
          UiUtils.getDivider(context),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: .start,
            children: [
              _buildLocation(
                address: _project.location!,
              ),
              const SizedBox(height: 8),
              _buildMapPreview(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocation({required String address}) {
    return CustomText(
      '${'addressLbl'.translate(context)}: $address',
      fontWeight: .w500,
      fontSize: context.font.sm,
      color: context.color.textColorDark.withValues(alpha: 0.89),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      alignment: Alignment.center,
      height: 167.rh(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: .expand,
          children: [
            Image.asset('assets/map.png', fit: .cover),
            Center(
              child: UiUtils.buildButton(
                context,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                height: 24.rh(context),
                autoWidth: true,
                fontSize: context.font.xs,
                onPressed: _navigateToMap,
                buttonTitle: 'viewMap'.translate(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToMap() async {
    await Navigator.push(
      context,
      CupertinoPageRoute<dynamic>(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(color: context.color.tertiaryColor),
            backgroundColor: Colors.transparent,
          ),
          body: GoogleMapScreen(
            latitude: double.parse(_project.latitude!),
            longitude: double.parse(_project.longitude!),
            controller: _controller,
          ),
        ),
      ),
    );
  }

  Future<void> _handleFeaturePress() async {
    await context.read<GetSubsctiptionPackageLimitsCubit>().getLimits(
      packageType: 'project_feature',
    );

    final state = context.read<GetSubsctiptionPackageLimitsCubit>().state;

    if (state is GetSubsctiptionPackageLimitsFailure) {
      await UiUtils.showBlurredDialoge(
        context,
        dialog: const BlurredSubscriptionDialogBox(
          packageType: SubscriptionPackageType.projectFeature,
          isAcceptContainesPush: true,
        ),
      );
    } else if (state is GetSubscriptionPackageLimitsSuccess) {
      if (state.error) {
        await _showPackageLimitDialog(state.message.translate(context));
      } else {
        await _showCreateAdvertisementDialog();
      }
    }
  }

  Future<void> _showPackageLimitDialog(String message) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: message.firstUpperCase(),
        isAcceptContainesPush: true,
        onAccept: () async {
          await Navigator.popAndPushNamed(
            context,
            Routes.subscriptionPackageListRoute,
            arguments: {
              'from': 'propertyDetails',
              'isBankTransferEnabled':
                  (context.read<GetApiKeysCubit>().state as GetApiKeysSuccess)
                      .bankTransferStatus ==
                  '1',
            },
          );
        },
        content: CustomText('yourPackageLimitOver'.translate(context)),
      ),
    );
  }

  Future<void> _showCreateAdvertisementDialog() async {
    try {
      await showDialog<dynamic>(
        context: context,
        builder: (context) => CreateAdvertisementPopup(
          property: PropertyModel(),
          isProject: true,
          project: _project,
        ),
      );
    } on Exception catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  Future<void> _handleEditPress() async {
    if (Constant.isDemoModeOn &&
        (HiveUtils.getUserDetails().isDemoUser ?? false)) {
      HelperUtils.showSnackBarMessage(
        context,
        'thisActionNotValidDemo',
      );
      return;
    }

    try {
      unawaited(Widgets.showLoader(context));
      await Navigator.pushNamed(
        context,
        Routes.addProjectDetails,
        arguments: {
          'id': _project.id,
          'meta_title': _project.metaTitle,
          'meta_description': _project.metaDescription,
          'meta_image': _project.metaImage,
          'slug_id': _project.slugId,
          'category_id': _project.category!.id,
          'translations': _project.translations,
          'project': _project,
        },
      );
    } on Exception catch (_) {
      HelperUtils.showSnackBarMessage(
        context,
        'somethingWentWrng',
      );
    } finally {
      if (mounted) Widgets.hideLoder(context);
    }
  }

  Future<void> _handleDeletePress() async {
    if (Constant.isDemoModeOn &&
        (HiveUtils.getUserDetails().isDemoUser ?? false)) {
      HelperUtils.showSnackBarMessage(
        context,
        'thisActionNotValidDemo',
      );
      return;
    }

    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'areYouSure'.translate(context),
        onAccept: () async {
          await context.read<DeleteProjectCubit>().delete(_project.id!);
        },
        content: CustomText('projectWillNotRecover'.translate(context)),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    if (!_isMyProject) return const SizedBox.shrink();

    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0,
      height: 72.rh(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          boxShadow: [
            BoxShadow(
              color: context.color.textColorDark.withValues(alpha: 0.12),
              offset: const Offset(0, -1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            if (!HiveUtils.isGuest() && !Constant.isDemoModeOn) ...[
              if (_project.isFeatureAvailable ?? false) ...[
                Expanded(
                  child:
                      BlocBuilder<
                        GetSubsctiptionPackageLimitsCubit,
                        GetSubscriptionPackageLimitsState
                      >(
                        builder: (context, state) {
                          return UiUtils.buildButton(
                            context,
                            height: 48.rh(context),
                            disabled: _project.status.toString() == '0',
                            onPressed: _handleFeaturePress,
                            prefixWidget: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 4),
                              child: CustomImage(
                                imageUrl: AppIcons.promoted,
                                color: context.color.buttonColor,
                                width: 18.rw(context),
                                height: 18.rh(context),
                              ),
                            ),
                            fontSize: context.font.md,
                            buttonTitle: 'feature'.translate(context),
                          );
                        },
                      ),
                ),
                const SizedBox(width: 16),
              ],
            ],
            if (_project.requestStatus != 'pending') ...[
              Expanded(
                child: UiUtils.buildButton(
                  context,
                  height: 48.rh(context),
                  onPressed: _handleEditPress,
                  fontSize: context.font.md,
                  prefixWidget: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 4),
                    child: CustomImage(
                      imageUrl: AppIcons.edit,
                      color: context.color.buttonColor,
                      height: 18.rh(context),
                      width: 18.rw(context),
                    ),
                  ),
                  buttonTitle: 'edit'.translate(context),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: UiUtils.buildButton(
                context,
                height: 48.rh(context),
                padding: const EdgeInsets.symmetric(horizontal: 1),
                prefixWidget: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 4),
                  child: CustomImage(
                    imageUrl: AppIcons.delete,
                    color: context.color.buttonColor,
                    width: 18.rw(context),
                    height: 18.rh(context),
                  ),
                ),
                onPressed: _handleDeletePress,
                fontSize: context.font.md,
                buttonTitle: 'deleteBtnLbl'.translate(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!mounted) return;

        Navigator.pop(context);
        await _onBackPress();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          onTapBackButton: _onBackPress,
          actions: [
            GestureDetector(
              onTap: () async {
                await HelperUtils.shareProject(
                  context,
                  _project.slugId ?? '',
                );
              },
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 16),
                alignment: Alignment.center,
                child: CustomImage(
                  imageUrl: AppIcons.shareIcon,
                  height: 24.rh(context),
                  color: context.color.textColorDark,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.color.primaryColor,
        bottomNavigationBar: _buildBottomNavigation(),
        body: BlocListener<DeleteProjectCubit, DeleteProjectState>(
          listener: (context, state) async {
            if (state is DeleteProjectInProgress) {
              unawaited(Widgets.showLoader(context));
            }
            if (state is DeleteProjectSuccess) {
              Widgets.hideLoder(context);
              await context.read<FetchMyProjectsListCubit>().delete(state.id);
              Navigator.pop(context);
            }
          },
          child: SingleChildScrollView(
            physics: Constant.scrollPhysics,
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 219.rs(context),
                      width: double.infinity,
                      child: CustomImage(
                        imageUrl: _project.image ?? '',
                        loadingImageHash: _project.lowQualityImage,
                      ),
                    ),
                    if (widget.project.isPromoted ?? false)
                      PositionedDirectional(
                        bottom: 16.rh(context),
                        start: 16.rw(context),
                        child: const PromotedCard(),
                      ),
                    PositionedDirectional(
                      top: 16.rh(context),
                      start: 10.rw(context),
                      child: Container(
                        alignment: Alignment.center,
                        width: 24.rw(context),
                        height: 24.rh(context),
                        child: CustomImage(
                          imageUrl: AppIcons.premium,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      _buildProjectHeader(),
                      const SizedBox(height: detailsPageSizedBoxHeight),
                      if (_isMyProject) ...[
                        _buildEnableDisableSwitch(),
                        const SizedBox(height: detailsPageSizedBoxHeight),
                      ],
                      _buildProjectDescription(),
                      const SizedBox(height: detailsPageSizedBoxHeight),
                      _buildAddressSection(),
                      const SizedBox(height: detailsPageSizedBoxHeight),
                      buildAgentProfileAndGallery(),
                      const SizedBox(height: detailsPageSizedBoxHeight),
                      _buildDocumentsSection(),
                      const SizedBox(height: detailsPageSizedBoxHeight),
                      _buildFloorPlansSection(),
                      const SizedBox(height: detailsPageSizedBoxHeight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAgentProfileAndGallery() {
    if ((widget.project.addedBy.toString() == HiveUtils.getUserId()) &&
        (widget.project.gallaryImages?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        children: [
          if (widget.project.addedBy.toString() != HiveUtils.getUserId())
            AgentProfileWidget(
              addedBy: widget.project.addedBy ?? '',
              name: widget.project.customer?.name ?? '',
              email: widget.project.customer?.email ?? '',
              profileImage: widget.project.customer?.profile ?? '',
              isVerified: widget.project.customer?.isVerified ?? false,
              propertiesCount: widget.project.customer?.propertiesCount ?? '',
              projectsCount: widget.project.customer?.projectsCount ?? '',
            ),
          if (widget.project.gallaryImages?.isNotEmpty ?? false) ...[
            if (widget.project.addedBy.toString() != HiveUtils.getUserId()) ...[
              const SizedBox(height: 8),
              UiUtils.getDivider(context),
              const SizedBox(height: 8),
            ],
            ProjectGallery(
              gallary: widget.project.gallaryImages,
              onShowGoogleMap: () {
                setState(() {
                  showGoogleMap = !showGoogleMap;
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
