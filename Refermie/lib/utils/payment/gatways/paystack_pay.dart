import 'dart:developer';

import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/gatways/paystack.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/purchase_package.dart';

class Paystack extends Payment {
  SubscriptionPackageModel? _modal;
  Map<String, dynamic>? _paymentIntent;
  @override
  Future<void> pay(BuildContext context) async {
    if (_modal == null) {
      log('Please set modal');
    }
    isPaymentGatewayOpen = true;
    await Navigator.push<dynamic>(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return PaystackWidget(
            pacakge: _modal!,
            paymentIntent: _paymentIntent,
            onSuccess: (msg) {
              Navigator.pop(context, {
                'msg': msg,
                'type': 'success',
              });
            },
            onFail: (msg) {
              Navigator.pop(context, {'msg': msg, 'type': 'fail'});
            },
          );
        },
      ),
    ).then((value) {
      isPaymentGatewayOpen = false;
      if (value != null && value is bool) {
        HelperUtils.showSnackBarMessage(
          context,
          value ? '' : 'Payment Failed',
        );
        return;
      }
      if (value != null) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () async {
            await UiUtils.showBlurredDialoge(
              context,
              dialog: BlurredDialogBox(
                title: (value['type'] == 'success' ? 'success' : 'Failed')
                    .translate(context),
                onAccept: () async {
                  if (value['type'] == 'success') {
                    emit(Success(message: 'Success'));
                    // _purchase(context);
                  }
                  if (value['type'] == 'Failed') {
                    emit(
                      Failure(
                        message: 'Something went wrong while making payment',
                      ),
                    );
                  }
                },
                onCancel: () {
                  if (value['type'] == 'success') {
                    emit(Success(message: 'Success'));
                  }
                  if (value['type'] == 'Failed') {
                    emit(
                      Failure(
                        message: 'Something went wrong while making payment',
                      ),
                    );
                  }
                },
                isAcceptContainesPush: true,
                content: CustomText(value['msg']?.toString() ?? ''),
              ),
            );
          },
        );
      }
    });
  }

  @override
  Paystack setPackage(SubscriptionPackageModel modal) {
    _modal = modal;
    return this;
  }

  @override
  Paystack setPaymentIntent(Map<String, dynamic> paymentIntent) {
    _paymentIntent = paymentIntent;
    return this;
  }

  @override
  Future<void> onEvent(
    BuildContext context,
    covariant PaymentStatus currentStatus,
  ) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }
}
