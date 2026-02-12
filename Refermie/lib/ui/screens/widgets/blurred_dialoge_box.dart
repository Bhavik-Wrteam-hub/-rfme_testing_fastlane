import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

mixin BlurDialoge {}

/// Base class for common dialog functionality
abstract class _BaseBlurredDialog extends StatelessWidget
    implements BlurDialoge {
  const _BaseBlurredDialog({
    required this.title,
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancleButton,
    this.svgImagePath,
    this.svgImageColor,
    this.barrierDismissable,
    this.isAcceptContainesPush,
    this.titleColor,
    this.titleSize,
    this.titleWeight,
  });

  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancleButton;
  final bool? barrierDismissable;
  final bool? isAcceptContainesPush;
  final Color? titleColor;
  final double? titleSize;
  final FontWeight? titleWeight;

  /// Template method for building dialog content
  Widget buildDialogContent(BuildContext context, BoxConstraints constraints);

  /// Template method for building action buttons
  Widget buildActionButtons(BuildContext context, BoxConstraints constraints);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(context),
        _buildPopScope(context),
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (barrierDismissable ?? false) {
          Navigator.pop(context);
        }
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.14),
      ),
    );
  }

  Widget _buildPopScope(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (backAllowedButton == false) {
          return Future.value(false);
        }
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AlertDialog(
            backgroundColor: context.color.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: _buildTitle(context),
            content: buildDialogContent(context, constraints),
            actionsOverflowAlignment: OverflowBarAlignment.center,
            actionsAlignment: .center,
            actions: [buildActionButtons(context, constraints)],
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        if (svgImagePath != null) ...[
          CircleAvatar(
            radius: 93, // 186 / 2
            backgroundColor: context.color.tertiaryColor.withValues(alpha: 0.1),
            child: CustomImage(
              imageUrl: svgImagePath!,
              color: svgImageColor,
            ),
          ),
          const SizedBox(height: 20),
        ],
        CustomText(
          title.firstUpperCase(),
          fontSize: titleSize ?? context.font.xl,
          color: titleColor ?? context.color.textColorDark,
          fontWeight: titleWeight ?? .w400,
          textAlign: .center,
        ),
      ],
    );
  }

  Widget buildButton(
    BuildContext context, {
    required BoxConstraints constraints,
    required Color buttonColor,
    required String buttonName,
    required Color textColor,
    required VoidCallback onTap,
    double? width,
    EdgeInsetsGeometry? margin,
    BorderSide? borderSide,
  }) {
    return Container(
      margin: margin,
      width: width ?? constraints.maxWidth / 3.1,
      child: MaterialButton(
        elevation: 0,
        height: 39.rh(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: borderSide ?? BorderSide(color: context.color.borderColor),
        ),
        color: buttonColor,
        onPressed: onTap,
        child: CustomText(
          buttonName,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> handleAcceptTap(BuildContext context) async {
    if (!context.mounted) return;
    await onAccept?.call();
    if (isAcceptContainesPush == false || isAcceptContainesPush == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pop(context, true);
      });
    }
  }

  void handleCancelTap(BuildContext context) {
    onCancel?.call();
    Navigator.pop(context, false);
  }
}

/// Blurred dialog box with static content
class BlurredDialogBox extends _BaseBlurredDialog {
  const BlurredDialogBox({
    required super.title,
    required this.content,
    super.key,
    this.showAcceptButton = true,
    super.cancelButtonName,
    super.acceptButtonName,
    super.onCancel,
    super.onAccept,
    super.cancelButtonColor,
    super.cancelTextColor,
    super.acceptButtonColor,
    super.acceptTextColor,
    super.backAllowedButton,
    super.showCancleButton,
    super.svgImagePath,
    super.svgImageColor,
    super.barrierDismissable,
    super.isAcceptContainesPush,
    super.titleSize,
    super.titleColor,
    super.titleWeight,
  });

  final Widget content;
  final bool showAcceptButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(context),
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (backAllowedButton == false) {
              return Future.value(false);
            }
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: context.color.secondaryColor,
                actionsPadding: showAcceptButton
                    ? const EdgeInsets.symmetric(vertical: 8)
                    : EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: _buildTitle(context),
                content: content,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: .center,
                actions: [buildActionButtons(context, constraints)],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget _buildBackground(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (barrierDismissable ?? false) {
          Navigator.pop(context);
        }
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.14),
      ),
    );
  }

  @override
  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        if (svgImagePath != null) ...[
          CircleAvatar(
            radius: 93,
            backgroundColor: Colors.transparent,
            child: CustomImage(
              fit: .contain,
              imageUrl: svgImagePath!,
              color: svgImageColor,
            ),
          ),
          const SizedBox(height: 18),
        ],
        CustomText(
          title.firstUpperCase(),
          fontSize: titleSize ?? context.font.xl,
          color: titleColor ?? context.color.textColorDark,
          fontWeight: titleWeight ?? .w400,
          textAlign: .center,
        ),
      ],
    );
  }

  @override
  Widget buildDialogContent(BuildContext context, BoxConstraints constraints) {
    return content;
  }

  @override
  Widget buildActionButtons(BuildContext context, BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        if (showCancleButton ?? true) ...[
          buildButton(
            context,
            margin: const EdgeInsetsDirectional.only(start: 8, end: 8),
            constraints: constraints,
            buttonColor: cancelButtonColor ?? context.color.primaryColor,
            buttonName: cancelButtonName ?? 'cancelBtnLbl'.translate(context),
            textColor: cancelTextColor ?? context.color.textColorDark,
            onTap: () => handleCancelTap(context),
          ),
        ],
        if (showAcceptButton) ...[
          buildButton(
            context,
            margin: const EdgeInsetsDirectional.only(end: 8),
            constraints: constraints,
            buttonColor: acceptButtonColor ?? context.color.tertiaryColor,
            buttonName: acceptButtonName ?? 'ok'.translate(context),
            textColor:
                acceptTextColor ??
                (showCancleButton == false
                    ? context.color.textColorDark
                    : Colors.white),
            width: showCancleButton == false ? context.screenWidth / 2 : null,
            onTap: () => handleAcceptTap(context),
          ),
        ],
      ],
    );
  }

  @override
  Widget buildButton(
    BuildContext context, {
    required BoxConstraints constraints,
    required Color buttonColor,
    required String buttonName,
    required Color textColor,
    required VoidCallback onTap,
    double? width,
    EdgeInsetsGeometry? margin,
    BorderSide? borderSide,
  }) {
    return Container(
      margin: margin,
      width:
          width ??
          (ResponsiveHelper.isSmallPhone(context)
              ? 96.rw(context)
              : 124.rw(context)),
      child: MaterialButton(
        elevation: 0,
        height: 48.rh(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: borderSide ?? BorderSide(color: context.color.borderColor),
        ),
        color: buttonColor,
        onPressed: onTap,
        child: CustomText(
          buttonName,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Future<void> handleAcceptTap(BuildContext context) async {
    if (!context.mounted) return;
    await onAccept?.call();
    if (isAcceptContainesPush == false || isAcceptContainesPush == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pop(context, true);
      });
    }
  }

  @override
  void handleCancelTap(BuildContext context) {
    onCancel?.call();
    Navigator.pop(context, false);
  }
}

/// Blurred dialog box with builder content
class BlurredDialogBuilderBox extends _BaseBlurredDialog {
  const BlurredDialogBuilderBox({
    required super.title,
    required this.contentBuilder,
    required this.cancelButtonBorderColor,
    super.key,
    super.cancelButtonName,
    super.acceptButtonName,
    super.onCancel,
    super.onAccept,
    super.cancelButtonColor,
    super.cancelTextColor,
    super.acceptButtonColor,
    super.acceptTextColor,
    super.backAllowedButton,
    super.showCancleButton,
    super.svgImagePath,
    super.svgImageColor,
    super.isAcceptContainesPush,
    super.titleSize,
    super.titleColor,
    super.titleWeight,
  });

  final Widget? Function(BuildContext context, BoxConstraints constrains)
  contentBuilder;
  final Color cancelButtonBorderColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black.withValues(alpha: 0.14)),
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (backAllowedButton == false) {
              return Future.value(false);
            }
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: context.color.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                title: _buildTitle(context),
                content: contentBuilder.call(context, constraints),
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: .center,
                actions: [buildActionButtons(context, constraints)],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (svgImagePath != null) ...[
          CircleAvatar(
            radius: 49.rs(context),
            backgroundColor: context.color.tertiaryColor.withValues(alpha: 0.1),
            child: SizedBox(
              width: 48.rw(context),
              height: 48.rh(context),
              child: CustomImage(
                imageUrl: svgImagePath!,
                color: svgImageColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        CustomText(
          title.firstUpperCase(),
          textAlign: .center,
          fontSize: titleSize ?? context.font.xl,
          fontWeight: titleWeight ?? .w400,
          color: titleColor ?? context.color.textColorDark,
        ),
      ],
    );
  }

  @override
  Widget buildDialogContent(BuildContext context, BoxConstraints constraints) {
    return contentBuilder.call(context, constraints) ?? const SizedBox.shrink();
  }

  @override
  Widget buildActionButtons(BuildContext context, BoxConstraints constraints) {
    return Row(
      children: [
        if (showCancleButton ?? true) ...[
          buildButton(
            context,
            constraints: constraints,
            buttonColor:
                cancelButtonColor ??
                context.color.tertiaryColor.withValues(alpha: .1),
            buttonName: cancelButtonName ?? 'cancelBtnLbl'.translate(context),
            textColor: cancelTextColor ?? context.color.textColorDark,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: constraints.maxWidth / 3.2,
            borderSide: BorderSide(color: cancelButtonBorderColor),
            onTap: () => handleCancelTap(context),
          ),
        ],
        buildButton(
          context,
          constraints: constraints,
          buttonColor: acceptButtonColor ?? context.color.tertiaryColor,
          buttonName: acceptButtonName ?? 'ok'.translate(context),
          textColor:
              acceptTextColor ??
              (showCancleButton == false
                  ? context.color.textColorDark
                  : context.color.buttonColor),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: showCancleButton == false
              ? context.screenWidth / 2
              : constraints.maxWidth / 3.2,
          onTap: () => handleAcceptTap(context),
        ),
      ],
    );
  }

  @override
  Future<void> handleAcceptTap(BuildContext context) async {
    await onAccept?.call();
    if (isAcceptContainesPush == false || isAcceptContainesPush == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pop(context, true);
      });
    }
  }

  @override
  void handleCancelTap(BuildContext context) {
    onCancel?.call();
    Navigator.pop(context, false);
  }
}

/// Specialized subscription dialog
class BlurredSubscriptionDialogBox extends StatelessWidget
    implements BlurDialoge {
  const BlurredSubscriptionDialogBox({
    required this.packageType,
    super.key,
    this.backAllowedButton,
    this.barrierDismissable,
    this.isAcceptContainesPush,
  });

  final SubscriptionPackageType packageType;
  final bool? backAllowedButton;
  final bool? barrierDismissable;
  final bool? isAcceptContainesPush;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(context),
        _buildPopScope(context),
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (barrierDismissable ?? false) {
          Navigator.pop(context);
        }
      },
      child: Container(color: Colors.black87),
    );
  }

  Widget _buildPopScope(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (backAllowedButton == false) {
          return Future.value(false);
        }
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AlertDialog(
            elevation: 0,
            titlePadding: const EdgeInsets.only(top: 18, left: 24, right: 24),
            contentPadding: EdgeInsets.zero,
            backgroundColor: context.color.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            title: _buildTitle(context),
            content: _buildContent(context),
            actionsAlignment: .center,
            actions: [_buildViewPlansButton(context, constraints)],
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          'subscribeNow'.translate(context),
          fontSize: context.font.lg,
          fontWeight: .w700,
        ),
        const Spacer(),
        _buildCloseButton(context),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 24.rh(context),
        width: 24.rw(context),
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(99999),
        ),
        child: Icon(
          Icons.close,
          color: context.color.inverseSurface,
          size: 16.rh(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Container(
          width: 267.rw(context),
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            border: Border.all(color: context.color.borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _buildPackageInfo(context),
        ),
      ],
    );
  }

  Widget _buildPackageInfo(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: CustomImage(imageUrl: AppIcons.premium),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          flex: 3,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              CustomText(
                packageType.title.translate(context),
                fontSize: context.font.md,
                fontWeight: .w700,
              ),
              const SizedBox(height: 2),
              CustomText(
                packageType.description.translate(context),
                fontSize: context.font.xs,
                color: context.color.textColorDark.withValues(alpha: 0.5),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewPlansButton(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Center(
      child: UiUtils.buildButton(
        context,
        onPressed: () => _handleViewPlansPress(context),
        buttonTitle: 'viewPlans'.translate(context),
        fontSize: context.font.md,
        height: 48.rh(context),
        width: 267.rw(context),
      ),
    );
  }

  Future<void> _handleViewPlansPress(BuildContext context) async {
    final apiKeyState = context.read<GetApiKeysCubit>().state;

    if (apiKeyState is GetApiKeysFail) {
      Navigator.pop(context);
      return;
    }

    final isBankTransferEnabled =
        (apiKeyState as GetApiKeysSuccess).bankTransferStatus == '1';

    await Navigator.popAndPushNamed(
      context,
      Routes.subscriptionPackageListRoute,
      arguments: {
        'from': 'home',
        'isBankTransferEnabled': isBankTransferEnabled,
      },
    );
  }
}

/// Empty dialog box with custom child
class EmptyDialogBox extends StatelessWidget with BlurDialoge {
  const EmptyDialogBox({
    required this.child,
    super.key,
    this.barrierDismisable,
  });

  final Widget child;
  final bool? barrierDismisable;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (barrierDismisable ?? true) Navigator.pop(context);
            },
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}

/// Subscription package types enum
enum SubscriptionPackageType {
  propertyList(
    'property_list',
    title: 'propertyListTitle',
    description: 'propertyListDescription',
  ),
  propertyFeature(
    'property_feature',
    title: 'propertyFeatureTitle',
    description: 'propertyFeatureDescription',
  ),
  projectList(
    'project_list',
    title: 'projectListTitle',
    description: 'projectListDescription',
  ),
  projectFeature(
    'project_feature',
    title: 'projectFeatureTitle',
    description: 'projectFeatureDescription',
  ),
  mortgageCalculatorDetail(
    'mortgage_calculator_detail',
    title: 'mortgageCalculatorDetailTitle',
    description: 'mortgageCalculatorDetailDescription',
  ),
  premiumProperties(
    'premium_properties',
    title: 'premiumPropertiesTitle',
    description: 'premiumPropertiesDescription',
  ),
  projectAccess(
    'project_access',
    title: 'projectAccessTitle',
    description: 'projectAccessDescription',
  );

  const SubscriptionPackageType(
    this.value, {
    required this.title,
    required this.description,
  });

  final String value;
  final String title;
  final String description;
}
