import 'package:dio/dio.dart';
import 'package:ebroker/data/cubits/subscription/fetch_subscription_packages_cubit.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/subscription/widget/document_upload.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// A widget that handles bank transfer functionality for subscription packages
class BankTransfer extends StatefulWidget {
  const BankTransfer({
    required this.subscriptionPackage,
    required this.parentContext,
    super.key,
  });
  final SubscriptionPackageModel subscriptionPackage;
  final BuildContext parentContext;

  /// Shows the bank transfer bottom sheet
  static Future<void> show({
    required BuildContext context,
    required SubscriptionPackageModel subscriptionPackage,
  }) async {
    await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.color.secondaryColor,
      builder: (context) {
        return BankTransfer(
          subscriptionPackage: subscriptionPackage,
          parentContext: context,
        );
      },
    );
  }

  @override
  State<BankTransfer> createState() => _BankTransferState();
}

class _BankTransferState extends State<BankTransfer> {
  MultipartFile? _bankReceiptFile;

  // Map to track copied states for clipboard buttons
  final Map<String, ValueNotifier<bool>> _copiedStates = {};

  @override
  void dispose() {
    // Dispose all ValueNotifiers in the map
    for (final notifier in _copiedStates.values) {
      notifier.dispose();
    }
    _copiedStates.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBankTransferBottomSheet();
  }

  // Build the bank transfer bottom sheet
  Widget _buildBankTransferBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          _buildBottomSheetHeader(),
          const SizedBox(height: 6),
          _buildBankDetailsList(),
          const SizedBox(height: 18),
          _buildUploadReceiptButton(
            packageId: widget.subscriptionPackage.id.toString(),
          ),
          const SizedBox(height: 18),
          _buildContinueButton(),
        ],
      ),
    );
  }

  // Bottom sheet header
  Widget _buildBottomSheetHeader() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Container(
          height: 4,
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.4,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        CustomText(
          'bankDetails'.translate(context),
          fontSize: context.font.lg,
          fontWeight: .w700,
          color: context.color.textColorDark,
        ),
      ],
    );
  }

  // List of bank details
  Widget _buildBankDetailsList() {
    return Column(
      children: AppSettings.bankTransferDetails
          .map(
            (e) => _buildCopyToClipboardButton(
              title:
                  e['translated_title']?.toString() ??
                  e['title']?.toString() ??
                  '',
              value: e['value']?.toString() ?? '',
            ),
          )
          .toList(),
    );
  }

  // Continue button for bank transfer
  Widget _buildContinueButton() {
    return UiUtils.buildButton(
      context,
      buttonTitle: 'completePayment'.translate(context),
      onPressed: () async {
        await _handleReceiptUpload(widget.subscriptionPackage.id.toString());
      },
    );
  }

  // Upload receipt button
  Widget _buildUploadReceiptButton({
    required String packageId,
  }) {
    return DocumentUpload(
      onDocumentSelected: (file) async {
        if (file != null) {
          _bankReceiptFile = await MultipartFile.fromFile(
            file.file ?? '',
            filename: file.name,
          );
        }
      },
    );
  }

  // Handle receipt upload logic
  Future<void> _handleReceiptUpload(String packageId) async {
    if (Constant.isDemoModeOn &&
        (HiveUtils.getUserDetails().isDemoUser ?? false)) {
      Navigator.pop(context); // Close the bottom sheet
      HelperUtils.showSnackBarMessage(
        context,
        'thisActionNotValidDemo',
      );
      return;
    }

    await _initiateBankTransfer(
      packageId: packageId,
      file: _bankReceiptFile ?? MultipartFile.fromString(''),
    );
  }

  // Initiate bank transfer API call
  Future<void> _initiateBankTransfer({
    required String packageId,
    required MultipartFile file,
  }) async {
    try {
      final response = await SubscriptionRepository().initiateBankTransfer(
        packageId: packageId,
        file: file,
      );
      if (response['error'] == false) {
        await context.read<FetchSubscriptionPackagesCubit>().fetchPackages();
        await Fluttertoast.showToast(
          msg: response['message'].toString(),
          fontSize: context.font.md,
          backgroundColor: context.color.tertiaryColor,
          textColor: context.color.buttonColor,
        );
        Navigator.pop(context); // Close the bottom sheet
      } else {
        if (mounted) {
          await Fluttertoast.showToast(
            msg: response['message'].toString(),
          );
        }
      }
    } on Exception catch (e) {
      await Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }

  // Copy to clipboard button for bank details
  Widget _buildCopyToClipboardButton({
    required String title,
    required String value,
  }) {
    // Initialize a ValueNotifier for this specific item if it doesn't exist
    if (!_copiedStates.containsKey(title)) {
      _copiedStates[title] = ValueNotifier<bool>(false);
    }
    return Column(
      crossAxisAlignment: .start,
      children: [
        const SizedBox(height: 12),
        CustomText(
          title,
          fontSize: context.font.xs,
          fontWeight: .w500,
          color: context.color.textColorDark,
        ),
        Row(
          children: [
            Expanded(
              child: CustomText(
                value,
                fontSize: context.font.md,
                fontWeight: .w500,
                color: context.color.textColorDark,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: value));
                _copiedStates[title]!.value = true;
                await Future<dynamic>.delayed(const Duration(seconds: 2));
                _copiedStates[title]!.value = false;
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: _copiedStates[title]!,
                builder: (context, isCopied, child) {
                  return Icon(
                    isCopied ? Icons.check : Icons.copy,
                    color: isCopied
                        ? Colors.green
                        : context.color.textColorDark.withValues(alpha: 0.5),
                    size: 24,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Using BankTransferResponseModel from subscription_pacakage_model.dart
