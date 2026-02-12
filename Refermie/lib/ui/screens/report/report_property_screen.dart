import 'package:ebroker/data/cubits/property/report/fetch_property_report_reason_list.dart';
import 'package:ebroker/data/cubits/property/report/property_report_cubit.dart';
import 'package:ebroker/data/model/report_property/reason_model.dart';
import 'package:ebroker/ui/screens/widgets/custom_text_form_field.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReportPropertyScreen extends StatefulWidget {
  const ReportPropertyScreen({required this.propertyId, super.key});
  final int propertyId;

  @override
  State<ReportPropertyScreen> createState() => _ReportPropertyScreenState();
}

class _ReportPropertyScreenState extends State<ReportPropertyScreen> {
  List<ReportReason>? reasons = [];
  late int selectedId;
  final TextEditingController _reportmessageController =
      TextEditingController();
  @override
  void initState() {
    reasons =
        context.read<FetchPropertyReportReasonsListCubit>().getList() ?? [];

    if (reasons?.isEmpty ?? true) {
      selectedId = -10;
    } else {
      selectedId = reasons!.first.id;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom - 50;
    final isBottomPaddingNagative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            CustomText(
              'reportProperty'.translate(context),
              fontSize: context.font.md,
              fontWeight: .w500,
            ),
            const SizedBox(height: 12),
            UiUtils.getDivider(context),
            const SizedBox(height: 12),
            ...List.generate(
              reasons?.length ?? 0,
              (index) {
                return GestureDetector(
                  onTap: () {
                    if (selectedId == reasons![index].id) {
                      // selectedId = -10;
                    } else {
                      selectedId = reasons![index].id;
                    }
                    setState(() {});
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: context.color.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: selectedId == reasons?[index].id
                            ? context.color.textColorDark
                            : context.color.textLightColor,
                      ),
                    ),
                    child: CustomText(
                      (reasons?[index].translatedReason ??
                              reasons?[index].reason.firstUpperCase() ??
                              '')
                          .translate(context),
                      color: selectedId == reasons?[index].id
                          ? context.color.textColorDark
                          : context.color.textLightColor,
                    ),
                  ),
                );
              },
            ),
            if (selectedId.isNegative)
              Padding(
                padding: EdgeInsets.only(
                  bottom: isBottomPaddingNagative ? 0 : bottomPadding,
                ),
                child: CustomTextFormField(
                  controller: _reportmessageController,
                  hintText: 'writeReasonHere'.translate(context),
                  borderColor: context.color.textColorDark,
                  borderRadius: 4,
                  maxLine: 4,
                  validator: CustomTextFieldValidator.nullCheck,
                ),
              ),
            const SizedBox(
              height: 14,
            ),
            BlocConsumer<PropertyReportCubit, PropertyReportState>(
              listener: (context, state) {
                if (state is PropertyReportInSuccess) {
                  HelperUtils.showSnackBarMessage(
                    context,
                    state.responseMessage,
                  );

                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                return Row(
                  mainAxisSize: .min,
                  children: [
                    Expanded(
                      child: UiUtils.buildButton(
                        context,
                        height: 40,
                        showElevation: false,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        buttonTitle: 'cancelLbl'.translate(context),
                        buttonColor: context.color.secondaryColor,
                        textColor: context.color.tertiaryColor,
                        fontSize: context.font.sm,
                        border: BorderSide(color: context.color.tertiaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: UiUtils.buildButton(
                        context,
                        height: 40,
                        showElevation: false,
                        buttonTitle: 'report'.translate(context),
                        buttonColor: context.color.tertiaryColor,
                        textColor: context.color.buttonColor,
                        fontSize: context.font.sm,
                        border: BorderSide(color: context.color.borderColor),
                        onPressed: () async {
                          if (selectedId.isNegative) {
                            if (_reportmessageController.text.isEmpty) {
                              await Fluttertoast.showToast(
                                msg: 'fieldMustNotBeEmpty'.translate(context),
                              );
                              return;
                            }
                            await context.read<PropertyReportCubit>().report(
                              propertyId: widget.propertyId,
                              reasonId: selectedId,
                              message: _reportmessageController.text,
                            );
                          } else {
                            await context.read<PropertyReportCubit>().report(
                              propertyId: widget.propertyId,
                              reasonId: selectedId,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
