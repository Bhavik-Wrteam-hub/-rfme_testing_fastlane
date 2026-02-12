import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/system/user_details.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/guest_checker.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointmentDropdownTile extends StatefulWidget {
  const AppointmentDropdownTile({super.key});

  @override
  State<AppointmentDropdownTile> createState() =>
      AppointmentDropdownTileState();
}

class AppointmentDropdownTileState extends State<AppointmentDropdownTile> {
  bool isExpanded = false;
  // isAgent is derived from UserDetailsCubit (with Hive fallback) during build

  @override
  Widget build(BuildContext context) {
    final isAgent =
        context.watch<UserDetailsCubit>().state.user?.isAgent ??
        (HiveUtils.getUserDetails().isAgent ?? false);

    if (isAgent) {
      return ExpansionTile(
        dense: true,
        shape: const Border(),
        visualDensity: VisualDensity.compact,
        minTileHeight: 38.rh(context),
        childrenPadding: EdgeInsets.zero,
        tilePadding: EdgeInsets.zero,
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
          });
        },
        trailing: Container(
          width: 24.rw(context),
          height: 24.rh(context),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.color.borderColor,
            ),
            color: context.color.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomImage(
            imageUrl: isExpanded ? AppIcons.downArrow : AppIcons.arrowRight,
            matchTextDirection: true,
            color: context.color.textColorDark,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.color.textColorDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FittedBox(
                fit: .none,
                child: CustomImage(
                  imageUrl: AppIcons.appointment,
                  height: 24.rh(context),
                  width: 24.rw(context),
                  color: context.color.textColorDark,
                ),
              ),
            ),
            SizedBox(
              width: 8.rw(context),
            ),
            Expanded(
              flex: 3,
              child: CustomText(
                'myAppointments'.translate(context),
                fontSize: context.font.md,
                fontWeight: .w700,
                color: context.color.textColorDark,
              ),
            ),
          ],
        ),
        children: [
          // Booking List sub-item
          _buildTileItem(
            context: context,
            title: 'bookingList'.translate(context),
            svgImagePath: AppIcons.bookings,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                Routes.myAppointmentsScreen,
                arguments: {'isAgent': true},
              );
            },
          ),
          _buildTileItem(
            context: context,
            title: 'myRequests'.translate(context),
            svgImagePath: AppIcons.myAppointments,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                Routes.myAppointmentsScreen,
                arguments: {'isAgent': false},
              );
            },
          ),
          _buildTileItem(
            context: context,
            title: 'configurations'.translate(context),
            svgImagePath: AppIcons.configuration,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                Routes.appointmentConfiguration,
              );
            },
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () async {
          await GuestChecker.check(
            onNotGuest: () async {
              await Navigator.pushNamed(
                context,
                Routes.myAppointmentsScreen,
                arguments: {
                  'isAgent': false,
                },
              );
            },
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.color.textColorDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FittedBox(
                fit: .none,
                child: CustomImage(
                  imageUrl: AppIcons.appointment,
                  height: 24.rh(context),
                  width: 24.rw(context),
                  color: context.color.textColorDark,
                ),
              ),
            ),
            SizedBox(
              width: 8.rw(context),
            ),
            Expanded(
              child: CustomText(
                'myAppointments'.translate(context),
                fontSize: context.font.md,
                fontWeight: .w700,
                color: context.color.textColorDark,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTileItem({
    required BuildContext context,
    required String title,
    required String svgImagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.color.textColorDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FittedBox(
                fit: .none,
                child: CustomImage(
                  imageUrl: svgImagePath,
                  height: 24.rh(context),
                  width: 24.rw(context),
                  color: context.color.textColorDark,
                ),
              ),
            ),
            SizedBox(
              width: 8.rw(context),
            ),
            Expanded(
              child: CustomText(
                title,
                fontSize: context.font.md,
                fontWeight: .w700,
                color: context.color.textColorDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
