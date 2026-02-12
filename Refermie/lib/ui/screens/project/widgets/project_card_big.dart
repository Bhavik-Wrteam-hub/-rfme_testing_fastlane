import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';

class ProjectCardBig extends StatelessWidget {
  const ProjectCardBig({
    required this.project,
    this.color,
    this.disableTap,
    this.showFeatured,
    super.key,
  });

  final ProjectModel project;
  final Color? color;
  final bool? disableTap;
  final bool? showFeatured;

  @override
  Widget build(BuildContext context) {
    final isMyProject = project.addedBy.toString() == HiveUtils.getUserId();
    return GestureDetector(
      onTap: () async {
        if (disableTap ?? false) return;
        final hasInternet = await HelperUtils.checkInternet();

        if (!hasInternet) {
          return HelperUtils.showSnackBarMessage(
            context,
            'noInternet',
            type: .error,
          );
        }

        try {
          await GuestChecker.check(
            onNotGuest: () async {
              if (!isMyProject) {
                unawaited(Widgets.showLoader(context));

                // Check package availability for non-owner users
                final checkPackage = CheckPackage();
                final packageAvailable = await checkPackage
                    .checkPackageAvailable(
                      packageType: PackageType.projectAccess,
                    );

                if (!packageAvailable) {
                  Widgets.hideLoder(context);
                  await UiUtils.showBlurredDialoge(
                    context,
                    dialog: const BlurredSubscriptionDialogBox(
                      packageType: SubscriptionPackageType.projectAccess,
                      isAcceptContainesPush: true,
                    ),
                  );
                  return;
                }
              }

              try {
                final projectRepository = ProjectRepository();
                final projectDetails = await projectRepository
                    .getProjectDetails(
                      context,
                      id: project.id!,
                      isMyProject: isMyProject,
                    );

                Widgets.hideLoder(context);
                await HelperUtils.goToNextPage(
                  Routes.projectDetailsScreen,
                  context,
                  false,
                  args: {'project': projectDetails},
                );
              } on Exception catch (_) {
                // Error handled in the finally block
                Widgets.hideLoder(context);
              }
            },
          );
        } on Exception catch (_) {
          // Error handled in the finally block
        } finally {
          Widgets.hideLoder(context);
        }
      },
      child: Container(
        width: 263.rw(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color ?? context.color.secondaryColor,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 138.rh(context),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: CustomImage(
                      imageUrl: project.image ?? '',
                      width: MediaQuery.of(context).size.width,
                      fit: .fill,
                      loadingImageHash: project.lowQualityImage,
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 8.rw(context),
                  top: 8.rh(context),
                  child: CustomImage(
                    imageUrl: AppIcons.premium,
                    width: 24.rw(context),
                    height: 24.rh(context),
                  ),
                ),
                if ((project.isPromoted ?? false) || (showFeatured ?? false))
                  PositionedDirectional(
                    bottom: 8.rh(context),
                    end: 8.rw(context),
                    child: const PromotedCard(),
                  ),
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border(
                    bottom: BorderSide(color: context.color.borderColor),
                    right: BorderSide(color: context.color.borderColor),
                    left: BorderSide(color: context.color.borderColor),
                  ),
                ),
                padding: EdgeInsets.all(8.rh(context)),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    Row(
                      children: [
                        CustomImage(
                          imageUrl: project.category?.image ?? '',
                          color: context.color.textLightColor,
                          width: 18.rw(context),
                          height: 18.rh(context),
                        ),
                        SizedBox(width: 8.rw(context)),
                        Expanded(
                          child: CustomText(
                            project.category?.translatedName ??
                                project.category?.category ??
                                '',
                            fontWeight: .w400,
                            maxLines: 1,
                            fontSize: context.font.xs,
                            color: context.color.textLightColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.rh(context)),
                    CustomText(
                      project.translatedTitle ?? project.title ?? '',
                      maxLines: 1,
                      fontSize: context.font.md,
                      fontWeight: .w500,
                      color: context.color.textColorDark,
                    ),
                    SizedBox(height: 4.rh(context)),
                    CustomText(
                      '${project.city}, ${project.state}, ${project.country}',
                      maxLines: 1,
                      fontSize: context.font.sm,
                      fontWeight: .w400,
                      color: context.color.textColorDark,
                    ),
                    SizedBox(height: 8.rh(context)),
                    UiUtils.getDivider(context),
                    SizedBox(height: 8.rh(context)),
                    CustomText(
                      project.type?.toLowerCase().translate(context) ?? '',
                      maxLines: 1,
                      fontSize: context.font.sm,
                      fontWeight: .w600,
                      color: context.color.tertiaryColor,
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
