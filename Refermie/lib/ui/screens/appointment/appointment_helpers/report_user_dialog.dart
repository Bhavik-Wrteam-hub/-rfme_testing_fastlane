import 'dart:async';

import 'package:ebroker/data/cubits/appointment/post/report_user_cubit.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportUserDialog extends StatefulWidget {
  const ReportUserDialog({
    required this.userId,
    super.key,
  });

  final int userId;

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportUserCubit, ReportUserState>(
      listener: (BuildContext context, ReportUserState state) {
        if (state is ReportUserSuccess) {
          HelperUtils.showSnackBarMessage(
            context,
            'userReportedSuccessfully',
            type: .success,
          );
          Navigator.pop(context);
          Navigator.pop(context);
        } else if (state is ReportUserFailure) {
          HelperUtils.showSnackBarMessage(
            context,
            state.errorMessage,
            type: .error,
          );
        }
      },
      child: Builder(
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 22.rw(context)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: context.color.secondaryColor,
            child: Container(
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  UiUtils.getDivider(context),
                  const SizedBox(height: 16),
                  _buildReasonField(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomText(
            'reportUser'.translate(context),
            color: context.color.textColorDark,
            fontSize: context.font.lg,
            fontWeight: .w600,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CustomImage(
            imageUrl: AppIcons.closeCircle,
            color: context.color.textColorDark,
            fit: .contain,
            width: 24.rw(context),
            height: 24.rh(context),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CustomText(
                'reason'.translate(context),
                color: context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w500,
              ),
              CustomText(
                ' *',
                color: Colors.red,
                fontSize: context.font.sm,
                fontWeight: .w500,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.color.primaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.color.borderColor),
            ),
            child: TextFormField(
              controller: _reasonController,
              maxLines: 4,
              style: TextStyle(
                color: context.color.textColorDark,
                fontSize: context.font.sm,
              ),
              decoration: InputDecoration(
                hintText: 'Write a Reason',
                hintStyle: TextStyle(
                  color: context.color.textLightColor,
                  fontSize: context.font.sm,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'reasonRequired'.translate(context);
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<ReportUserCubit, ReportUserState>(
      builder: (BuildContext context, ReportUserState state) {
        final isLoading = state is ReportUserInProgress;

        return Row(
          children: [
            Expanded(
              child: UiUtils.buildButton(
                context,
                onPressed: isLoading ? () {} : () => Navigator.pop(context),
                buttonTitle: 'cancel'.translate(context),
                fontSize: context.font.sm,
                height: 40.rh(context),
                buttonColor: context.color.secondaryColor,
                textColor: context.color.tertiaryColor,
                border: BorderSide(color: context.color.tertiaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UiUtils.buildButton(
                context,
                onPressed: isLoading ? () {} : _submitReport,
                buttonTitle: 'submit'.translate(context),
                fontSize: context.font.sm,
                height: 40.rh(context),
                isInProgress: isLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<ReportUserCubit>().reportUser(
        userId: widget.userId.toString(),
        reason: _reasonController.text.trim(),
      );
    }
  }
}
