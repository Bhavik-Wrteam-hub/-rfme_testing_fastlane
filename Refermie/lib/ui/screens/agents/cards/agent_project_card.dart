import 'dart:async';

import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/project_data.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/guest_checker.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class AgentProjectCardBig extends StatelessWidget {
  const AgentProjectCardBig({
    required this.project,
    this.color,
    super.key,
  });

  final ProjectData project;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isMyProject = project.addedBy == HiveUtils.getUserId();
    return Container(
      height: 258.rh(context),
      width: 264.rw(context),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color ?? context.color.secondaryColor,
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
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
                        id: project.id,
                        isMyProject: isMyProject,
                      );

                  Widgets.hideLoder(context);
                  await HelperUtils.goToNextPage(
                    Routes.projectDetailsScreen,
                    context,
                    false,
                    args: {
                      'project': projectDetails,
                    },
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
        child: Column(
          children: [
            Flexible(
              child: Stack(
                children: [
                  SizedBox(
                    height: 138.rh(context),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: CustomImage(
                        imageUrl: project.image,
                        width: MediaQuery.of(context).size.width,
                        fit: .fill,
                        loadingImageHash: project.lowQualityImage,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 8,
                    top: 8,
                    child: CustomImage(
                      imageUrl: AppIcons.premium,
                      width: 24.rw(context),
                      height: 24.rh(context),
                    ),
                  ),
                  if (project.isFeatured)
                    const PositionedDirectional(
                      bottom: 8,
                      end: 8,
                      child: PromotedCard(),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: .start,
                children: <Widget>[
                  Row(
                    children: [
                      CustomImage(
                        imageUrl: project.category.image ?? '',
                        width: 18.rw(context),
                        height: 18.rh(context),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: CustomText(
                          project.category.translatedName ??
                              project.category.category ??
                              '',
                          fontWeight: .w400,
                          fontSize: context.font.xs,
                          color: context.color.textLightColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomText(
                    project.translatedTitle ?? project.title,
                    maxLines: 1,
                    fontSize: context.font.lg,
                    fontWeight: .w500,
                    color: context.color.textColorDark,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  CustomText(
                    '${project.city}, ${project.state}, ${project.country}',
                    maxLines: 1,
                    fontSize: context.font.xs,
                    fontWeight: .w400,
                    color: context.color.textColorDark,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: context.color.textLightColor.withValues(alpha: .1),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomText(
                    project.type.translate(context),
                    maxLines: 1,
                    fontSize: context.font.sm,
                    fontWeight: .w600,
                    color: context.color.tertiaryColor,
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
