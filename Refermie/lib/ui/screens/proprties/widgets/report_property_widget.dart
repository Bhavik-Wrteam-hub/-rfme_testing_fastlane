import 'package:ebroker/data/cubits/property/report/property_report_cubit.dart';
import 'package:ebroker/ui/screens/report/report_property_screen.dart';
import 'package:ebroker/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/guest_checker.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportPropertyButton extends StatefulWidget {
  const ReportPropertyButton({
    required this.propertyId,
    required this.onSuccess,
    super.key,
  });
  final int propertyId;
  final dynamic Function() onSuccess;

  @override
  State<ReportPropertyButton> createState() => _ReportPropertyButtonState();
}

class _ReportPropertyButtonState extends State<ReportPropertyButton> {
  bool shouldReport = true;
  Future<void> _onTapYes(int propertyId) async {
    await _showReportPropertyDialoge(propertyId);
  }

  Future<void> _onTapNo() async {
    await GuestChecker.check(
      onNotGuest: () {
        shouldReport = false;
        setState(() {});
      },
    );
  }

  Future<void> _showReportPropertyDialoge(int propertyId) async {
    final cubit = BlocProvider.of<PropertyReportCubit>(context);
    await UiUtils.showBlurredDialoge(
      context,
      dialog: EmptyDialogBox(
        child: AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          content: BlocProvider.value(
            value: cubit,
            child: ReportPropertyScreen(propertyId: propertyId),
          ),
        ),
      ),
    ).then((value) {
      widget.onSuccess.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldReport) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.only(
        left: 8.rw(context),
        right: 8.rw(context),
        top: 8.rh(context),
      ),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            height: 50.rh(context),
            width: 44.rw(context),
            child: CustomImage(
              imageUrl: Theme.of(context).brightness == .dark
                  ? AppIcons.reportDark
                  : AppIcons.report,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              mainAxisAlignment: .spaceBetween,
              children: [
                Flexible(
                  child: CustomText(
                    'didYoufindProblem'.translate(context),
                    maxLines: 2,
                    fontWeight: .w500,
                    fontSize: context.font.sm,
                  ),
                ),
                const SizedBox(height: 8),
                UiUtils.getDivider(context),
                Row(
                  children: [
                    UiUtils.buildButton(
                      context,
                      padding: EdgeInsets.zero,
                      outerPadding: EdgeInsets.zero,
                      height: 24.rh(context),
                      showElevation: false,
                      autoWidth: true,
                      onPressed: () async {
                        await GuestChecker.check(
                          onNotGuest: () async {
                            await _onTapYes.call(widget.propertyId);
                          },
                        );
                      },
                      textColor: context.color.textColorDark,
                      buttonTitle: 'yes'.translate(context),
                      buttonColor: context.color.secondaryColor,
                      fontSize: context.font.sm,
                      radius: 4,
                      border: BorderSide(color: context.color.borderColor),
                    ),
                    const SizedBox(width: 8),
                    UiUtils.buildButton(
                      context,
                      height: 24.rh(context),
                      padding: EdgeInsets.zero,
                      outerPadding: EdgeInsets.zero,
                      showElevation: false,
                      autoWidth: true,
                      onPressed: _onTapNo,
                      textColor: context.color.textColorDark,
                      buttonTitle: 'notReally'.translate(context),
                      buttonColor: context.color.secondaryColor,
                      fontSize: context.font.sm,
                      radius: 4,
                      border: BorderSide(color: context.color.borderColor),
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
}
