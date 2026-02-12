import 'dart:developer';

import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:flutter/material.dart';

class ProjectHorizontalCard extends StatelessWidget {
  const ProjectHorizontalCard({
    required this.project,
    required this.isRejected,
    super.key,
    this.statusButton,
    this.disableTap,
    this.showFeatured,
  });

  final ProjectModel project;
  final bool isRejected;

  final StatusButton? statusButton;

  final bool? disableTap;
  final bool? showFeatured;

  @override
  Widget build(BuildContext context) {
    final isMyProject = project.addedBy.toString() == HiveUtils.getUserId();
    return GestureDetector(
      onTap: () async {
        // if (disableTap ?? false) return;
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
        } on Exception catch (e) {
          log(e.toString());
          // Error handled in the finally block
        } finally {
          Widgets.hideLoder(context);
        }
      },
      child: Container(
        height: 130.rh(context),
        width: MediaQuery.sizeOf(context).width,
        margin: EdgeInsets.only(bottom: 12.rh(context)),
        padding: EdgeInsets.all(8.rw(context)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.color.borderColor),
          color: context.color.secondaryColor,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 114.rh(context),
                  width: 127.rw(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CustomImage(
                      imageUrl: project.image ?? '',
                      width: MediaQuery.of(context).size.width,
                      fit: .fill,
                      loadingImageHash: project.lowQualityImage,
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 4.rh(context),
                  top: 4.rh(context),
                  child: CustomImage(
                    imageUrl: AppIcons.premium,
                    width: 18.rw(context),
                    height: 18.rh(context),
                  ),
                ),
                if ((project.isPromoted ?? false) || (showFeatured ?? false))
                  PositionedDirectional(
                    bottom: 4.rh(context),
                    start: 4.rw(context),
                    child: const PromotedCard(),
                  ),
              ],
            ),
            SizedBox(width: 12.rw(context)),
            Expanded(
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
                      const SizedBox(width: 4),
                      Expanded(
                        child: CustomText(
                          project.category?.translatedName ??
                              project.category?.category ??
                              '',
                          fontWeight: .w600,
                          fontSize: context.font.xxs,
                          color: context.color.textLightColor,
                          maxLines: 1,
                        ),
                      ),
                      if (statusButton != null) ...[
                        GestureDetector(
                          onTap: () async {
                            if (isRejected) {
                              await UiUtils.showBlurredDialoge(
                                context,
                                dialog: BlurredDialogBox(
                                  acceptTextColor: context.color.buttonColor,
                                  showCancleButton: false,
                                  title: statusButton!.lable,
                                  content: CustomText(
                                    project.rejectReason?.reason.toString() ??
                                        '',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusButton!.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                CustomText(
                                  statusButton!.lable,
                                  fontWeight: .bold,
                                  fontSize: context.font.xxs,
                                  color:
                                      statusButton?.textColor ?? Colors.black,
                                ),
                                if (isRejected) ...[
                                  const SizedBox(width: 2),
                                  CustomImage(
                                    imageUrl: AppIcons.info,
                                    width: 16,
                                    height: 16,
                                    color: statusButton!.textColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    project.translatedTitle ?? project.title ?? '',
                    maxLines: 1,
                    fontSize: context.font.sm,
                    fontWeight: .w400,
                    color: context.color.textColorDark,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    '${project.city}, ${project.state}, ${project.country}',
                    maxLines: 1,
                    fontSize: context.font.xs,
                    fontWeight: .w400,
                    color: context.color.textColorDark,
                  ),
                  const SizedBox(height: 8),
                  UiUtils.getDivider(context),
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.rw(context)),
                    alignment: AlignmentDirectional.centerEnd,
                    child: CustomText(
                      project.type?.toLowerCase().translate(context) ?? '',
                      maxLines: 1,
                      fontSize: context.font.xxs,
                      fontWeight: .w600,
                      color: context.color.tertiaryColor,
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
}
