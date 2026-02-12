import 'dart:developer';

import 'package:ebroker/data/cubits/subscription/assign_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseManager {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  String? packageId;
  String? productId;
  Future<ProductDetails> getProductByProductId(String productId) async {
    final productDetailsResponse = await _inAppPurchase.queryProductDetails({
      productId,
    });
    return productDetailsResponse.productDetails.first;
  }

  Future<void> onSuccessfulPurchase(
    BuildContext context,
    PurchaseDetails purchase,
  ) async {
    await purchaseCompleteDialog(context);
  }

  Future<void> onPurchaseCancel(
    BuildContext context,
    PurchaseDetails purchase,
  ) async {
    await paymentCancelDialog(context);
  }

  Future<void> onErrorPurchase(
    BuildContext context,
    PurchaseDetails purchase,
  ) async {
    await paymentErrorDialog(context, purchase);
  }

  Future<void> onPendingPurchase(PurchaseDetails purchase) async {
    if (purchase.purchaseID != null && purchase.pendingCompletePurchase) {
      try {
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await _inAppPurchase.completePurchase(purchase);
      } on Exception catch (_) {
        // Handle the error appropriately
      }
    }
  }

  Future<void> onRestoredPurchase(PurchaseDetails purchase) async {}
  Future<void> completePending(List<PurchaseDetails> event) async {
    for (final purchaseDetails in event) {
      if (purchaseDetails.purchaseID != null &&
          purchaseDetails.pendingCompletePurchase) {
        try {
          await Future<dynamic>.delayed(const Duration(seconds: 1));
          await _inAppPurchase.completePurchase(purchaseDetails);
        } on Exception catch (_) {
          // Handle the error appropriately
        }
      }
    }
  }

  static void getPendings() {
    // _inAppPurchase.purchaseStream.listen((event) {});
  }

  void listenIAP(BuildContext context) {
    _inAppPurchase.purchaseStream.listen(
      (event) async {
        await completePending(event);
        for (final inAppPurchaseEvent in event) {
          if (inAppPurchaseEvent.error != null) {}

          Future.delayed(Duration.zero, () async {
            if (inAppPurchaseEvent.status == PurchaseStatus.purchased) {
              await _inAppPurchase.completePurchase(inAppPurchaseEvent);
              await onSuccessfulPurchase(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.canceled) {
              await onPurchaseCancel(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.error) {
              await onErrorPurchase(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.pending) {
              await onPendingPurchase(inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.restored) {
              await _inAppPurchase.completePurchase(inAppPurchaseEvent);
              await onRestoredPurchase(inAppPurchaseEvent);
            }
          });
          if (inAppPurchaseEvent.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(inAppPurchaseEvent);
          }
        }
      },
      onError: (_) {},
    );
  }

  Future<void> buy(String productId, String packageId) async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (isAvailable) {
      final productDetails = await getProductByProductId(productId);
      // _inAppPurchase._inAppPurchase.completePurchase();
      this.packageId = packageId;
      this.productId = productId;
      log('Processing to buy!!');
      await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
      log('Processing to success!!');
    } else {
      log('inAppPurchase.buy failed');
    }
  }

  Future<void> purchaseCompleteDialog(BuildContext context) async {
    await context.read<AssignInAppPackageCubit>().assign(
      packageId: packageId!,
      productId: productId!,
    );
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'Purchase completed',
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: const CustomText('Your purchase has completed successfully'),
      ),
    );
  }

  Future<void> paymentCancelDialog(BuildContext context) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'Purchase canceled',
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: const CustomText('Your purchase has been canceled'),
      ),
    );
  }

  Future<void> paymentErrorDialog(
    BuildContext context,
    PurchaseDetails purchase,
  ) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'Purchase error',
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: CustomText('${purchase.error?.message}'),
      ),
    );
  }
}
