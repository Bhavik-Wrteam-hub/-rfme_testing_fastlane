import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/report_user_dialog.dart';
import 'package:ebroker/ui/screens/home/widgets/sell_rent_label.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/price_format.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class AppointmentDetailsBottomSheet extends StatelessWidget {
  const AppointmentDetailsBottomSheet({
    required this.appointment,
    required this.isFromAgentAppointments,
    required this.isFromPreviousAppointments,
    super.key,
  });

  final AppointmentModel appointment;
  final bool isFromAgentAppointments;
  final bool isFromPreviousAppointments;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          // Title
          CustomText(
            'appointmentDetails'.translate(context),
            fontSize: context.font.lg,
            fontWeight: .w600,
            color: context.color.textColorDark,
          ),
          const SizedBox(height: 16),
          UiUtils.getDivider(context),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.color.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Property Details Card
                _buildPropertyDetailsCard(context),

                // User/Contact Details
                _buildUserDetailsSection(context),

                // User Message Section
                _buildUserMessageSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailsCard(BuildContext context) {
    final property = appointment.property;
    if (property == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: .start,
      children: [
        // Property Details Card
        _buildPropertyCard(context, property),
        const SizedBox(height: 10),
        // Facilites
        _buildFacilitesSection(context, property),
        const SizedBox(height: 10),
        // Price
        _buildPriceSection(context, property),
        const SizedBox(height: 10),
        UiUtils.getDivider(context),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, PropertyModel property) {
    final price =
        property.propertyType?.toLowerCase() == 'sell' ||
            property.propertyType?.toLowerCase() == 'sold'
        ? property.price
        : '${property.price} / ${property.rentduration}';
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          'price'.translate(context),
          fontWeight: .w500,
          color: context.color.textLightColor,
        ),
        CustomText(
          price?.priceFormat(context: context) ?? '',
          fontSize: context.font.md,
          fontWeight: .w500,
          color: context.color.tertiaryColor,
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.color.borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CustomImage(
              imageUrl: property.titleImage ?? '',
              height: 82.rh(context),
              width: 120.rw(context),
              loadingImageHash: property.lowQualityTitleImage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    CustomImage(
                      imageUrl: property.category?.image ?? '',
                      height: 18.rh(context),
                      fit: .contain,
                      width: 18.rw(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomText(
                        property.category?.translatedName ??
                            property.category?.category ??
                            '',
                        fontSize: context.font.xxs,
                        fontWeight: .w500,
                      ),
                    ),
                    SellRentLabel(
                      propertyType: property.propertyType ?? '',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomText(
                  property.translatedTitle ?? property.title ?? '',
                  fontSize: context.font.md,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CustomImage(
                      imageUrl: AppIcons.location,
                      height: 18.rh(context),
                      fit: .contain,
                      width: 18.rw(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomText(
                        property.address ?? '',
                        fontSize: context.font.xxs,
                        color: context.color.textLightColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitesSection(BuildContext context, PropertyModel property) {
    final parameters = property.parameters;
    if (parameters == null || parameters.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.color.borderColor),
      ),
      child: Row(
        mainAxisAlignment: .spaceEvenly,
        children: List.generate(
          (parameters.length) < 4 ? parameters.length : 4,
          (index) {
            final translatedValue =
                (parameters[index].translatedValue ??
                        parameters[index].value as List? ??
                        [])
                    .join(', ');
            return Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: (index != (parameters.length) - 1)
                      ? BorderDirectional(
                          end: BorderSide(
                            color: context.color.borderColor,
                            width: 2,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  children: [
                    CustomImage(
                      imageUrl: parameters[index].image ?? '',
                      height: 18.rh(context),
                      width: 18.rw(context),
                      color: context.color.textColorDark,
                      fit: .contain,
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: CustomText(
                        translatedValue,
                        fontSize: context.font.xxs,
                        color: context.color.textColorDark,
                        maxLines: 3,
                        fontWeight: .w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserDetailsSection(BuildContext context) {
    final user = isFromAgentAppointments ? appointment.user : appointment.agent;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    isFromAgentAppointments
                        ? 'userName'.translate(context)
                        : 'agentName'.translate(context),
                    fontSize: context.font.xs,
                    fontWeight: .w500,
                    color: context.color.textLightColor,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    user.name ?? '',
                    fontWeight: .w500,
                    maxLines: 2,
                    color: context.color.textColorDark,
                  ),
                ],
              ),
            ),
            if (!isFromAgentAppointments && (user.isUserVerified ?? false)) ...[
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsetsDirectional.only(start: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    CustomImage(
                      imageUrl: AppIcons.verified,
                      color: Colors.blue,
                      height: 16.rh(context),
                      width: 16.rw(context),
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      'verified'.translate(context),
                      fontSize: context.font.xs,
                      fontWeight: .w500,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ] else if (isFromAgentAppointments) ...[
              UiUtils.buildButton(
                context,
                onPressed: () => _showReportUserDialog(context),
                buttonColor: context.color.secondaryColor,
                border: BorderSide(color: context.color.textColorDark),
                height: 36.rh(context),
                autoWidth: true,
                showElevation: false,
                fontSize: context.font.md,
                textColor: context.color.textColorDark,
                buttonTitle: 'reportUser'.translate(context),
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),
        UiUtils.getDivider(context),
        const SizedBox(height: 10),

        // Phone
        _buildDetailRow(
          context,
          AppIcons.call,
          'phone'.translate(context),
          user.mobile ?? '',
        ),
        const SizedBox(height: 12),

        // Email
        _buildDetailRow(
          context,
          AppIcons.email,
          'email'.translate(context),
          user.email ?? '',
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _showReportUserDialog(BuildContext context) async {
    final user = appointment.user;
    if (user?.id == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) => ReportUserDialog(
        userId: user!.id!,
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String icon,
    String label,
    String value,
  ) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: .start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.color.textColorDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomImage(
            imageUrl: icon,
            height: 16.rh(context),
            width: 16.rw(context),
            color: context.color.textColorDark,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: .start,
          children: [
            CustomText(
              label,
              color: context.color.textColorDark,
            ),
            const SizedBox(height: 4),
            CustomText(
              value,
              fontSize: context.font.xs,
              fontWeight: .w500,
              color: context.color.textLightColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserMessageSection(BuildContext context) {
    final note = appointment.notes;
    if (note.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: .start,
      children: [
        UiUtils.getDivider(context),
        const SizedBox(height: 10),
        CustomText(
          'userMessage'.translate(context),
          fontWeight: .w500,
          color: context.color.textColorDark,
        ),
        const SizedBox(height: 8),
        CustomText(
          note,
          fontSize: context.font.xs,
          color: context.color.textLightColor,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
