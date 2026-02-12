import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:ebroker/ui/screens/home/widgets/project_card_horizontal.dart';
import 'package:flutter/material.dart';

class MyProjects extends StatefulWidget {
  const MyProjects({super.key});

  static Route<dynamic> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) {
        return const MyProjects();
      },
    );
  }

  @override
  State<MyProjects> createState() => _MyProjectsState();
}

class _MyProjectsState extends State<MyProjects> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    unawaited(context.read<FetchMyProjectsListCubit>().fetchMyProjects());

    _scrollController.addListener(() async {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchMyProjectsListCubit>().hasMoreData()) {
          await context.read<FetchMyProjectsListCubit>().fetchMore(
            isPromoted: false,
          );
        }
      }
    });
    super.initState();
  }

  String statusText(String text) {
    if (text == '1') {
      return 'active'.translate(context);
    } else if (text == '0') {
      return 'inactive'.translate(context);
    } else if (text == 'rejected') {
      return 'rejected'.translate(context);
    } else if (text == 'pending') {
      return 'pending'.translate(context);
    }
    return '';
  }

  Color statusColor(String text) {
    if (text == '1') {
      return Colors.green;
    } else if (text == '0') {
      return Colors.orangeAccent;
    } else if (text == 'rejected') {
      return Colors.redAccent;
    } else if (text == 'pending') {
      return Colors.blue;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'myProjects'.translate(context),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await context.read<FetchMyProjectsListCubit>().fetchMyProjects();
        },
        child: BlocBuilder<FetchMyProjectsListCubit, FetchMyProjectsListState>(
          builder: (context, state) {
            if (state is FetchMyProjectsListInProgress) {
              return UiUtils.buildHorizontalShimmer(context);
            }
            if (state is FetchMyProjectsListFail) {
              if (state.error is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () async {
                    await context
                        .read<FetchMyProjectsListCubit>()
                        .fetchMyProjects();
                  },
                );
              }
              return SomethingWentWrong(
                errorMessage: state.error.toString(),
              );
            }
            if (state is FetchMyProjectsListSuccess) {
              if (state.projects.isEmpty) {
                return NoDataFound(
                  title: 'noProjectAdded'.translate(context),
                  description: 'noProjectAddedDescription'.translate(context),
                  showMainButton: true,
                  mainButtonTitle: 'addProject'.translate(context),
                  onTapMainButton: _navigateToAddProject,
                  onTapRetry: () async {
                    await context
                        .read<FetchMyProjectsListCubit>()
                        .fetchMyProjects();
                  },
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: Constant.scrollPhysics,
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: state.projects.length,
                      padding: const EdgeInsets.all(14),
                      itemBuilder: (context, index) {
                        final project = state.projects[index];
                        final requestStatus =
                            project.requestStatus == 'approved'
                            ? project.status.toString()
                            : project.requestStatus.toString();
                        return ProjectHorizontalCard(
                          project: project,
                          isRejected: project.requestStatus == 'rejected',
                          statusButton: StatusButton(
                            lable: statusText(requestStatus),
                            color: statusColor(
                              requestStatus,
                            ).withValues(alpha: 0.2),
                            textColor: statusColor(requestStatus),
                          ),
                        );
                      },
                    ),
                  ),
                  if (context
                      .watch<FetchMyProjectsListCubit>()
                      .hasMoreData()) ...[
                    Center(child: UiUtils.progress()),
                  ],
                ],
              );
              // return ProjectCard(title: "Hello",categoryIcon: ,);
            }
            if (state is FetchMyProjectsListFail) {
              return Center(
                child: CustomText(state.error.toString()),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  Future<void> _navigateToAddProject() async {
    await GuestChecker.check(
      onNotGuest: () async {
        unawaited(Widgets.showLoader(context));
        final checkPackage = CheckPackage();

        final packageAvailable = await checkPackage.checkPackageAvailable(
          packageType: PackageType.projectList,
        );

        if (packageAvailable) {
          try {
            final isProfileCompleted =
                HiveUtils.getUserDetails().email != '' &&
                HiveUtils.getUserDetails().email != null &&
                (HiveUtils.getUserDetails().email?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().mobile != '' &&
                HiveUtils.getUserDetails().mobile != null &&
                (HiveUtils.getUserDetails().mobile?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().name != '' &&
                HiveUtils.getUserDetails().name != null &&
                (HiveUtils.getUserDetails().name?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().address != '' &&
                (HiveUtils.getUserDetails().address?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().address != null &&
                HiveUtils.getUserDetails().profile != '' &&
                (HiveUtils.getUserDetails().profile?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().profile != null;

            if (!isProfileCompleted) {
              await _showCompleteProfileDialog();
            } else if (AppSettings.isVerificationRequired &&
                context.read<FetchSystemSettingsCubit>().getSetting(
                      SystemSetting.verificationStatus,
                    ) !=
                    'success') {
              await _showVerificationRequiredDialog();
            } else {
              await _navigateToAddScreen();
            }
          } on Exception catch (e) {
            Widgets.hideLoder(context);
            HelperUtils.showSnackBarMessage(
              context,
              e.toString(),
              type: .error,
            );
          }
        } else {
          Widgets.hideLoder(context);
          await UiUtils.showBlurredDialoge(
            context,
            dialog: const BlurredSubscriptionDialogBox(
              packageType: SubscriptionPackageType.projectList,
              isAcceptContainesPush: true,
            ),
          );
        }
      },
    );
  }

  /// Navigates to add property/project screen
  Future<void> _navigateToAddScreen() async {
    if (context.read<FetchCategoryCubit>().state is! FetchCategorySuccess) {
      await context.read<FetchCategoryCubit>().fetchCategories(
        loadWithoutDelay: true,
        forceRefresh: false,
      );
    }
    Widgets.hideLoder(context);

    await Navigator.pushNamed(
      context,
      Routes.selectPropertyTypeScreen,
      arguments: {'type': PropertyAddType.project},
    );

    Widgets.hideLoder(context);
  }

  /// Shows dialog for agent verification requirement
  Future<void> _showVerificationRequiredDialog() async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        content: CustomText(
          'completeAgentVerificationToContinue'.translate(context),
        ),
        title: 'agentVerificationRequired'.translate(context),
        isAcceptContainesPush: true,
        onAccept: () async {
          await HelperUtils.goToNextPage(
            Routes.agentVerificationForm,
            context,
            false,
          );
        },
      ),
    );
  }

  /// Shows dialog to complete profile
  Future<void> _showCompleteProfileDialog() async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'completeProfile'.translate(context),
        isAcceptContainesPush: true,
        onAccept: () async {
          await Navigator.popAndPushNamed(
            context,
            Routes.editProfile,
            arguments: {
              'from': 'home',
              'navigateToHome': true,
            },
          );
        },
        content:
            HiveUtils.getUserDetails().profile == '' &&
                (HiveUtils.getUserDetails().name != '' &&
                    HiveUtils.getUserDetails().email != '' &&
                    HiveUtils.getUserDetails().address != '')
            ? CustomText('uploadProfilePicture'.translate(context))
            : CustomText('completeProfileFirst'.translate(context)),
      ),
    );
  }
}
