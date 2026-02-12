import 'dart:developer';

import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/gatways/flutterwave.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/purchase_package.dart';

class Flutterwave extends Payment {
  SubscriptionPackageModel? _modal;
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
          return FlutterwaveWidget(
            pacakge: _modal!,
            onSuccess: (msg) {
              isPaymentGatewayOpen = false;
              Navigator.pop(context, {
                'msg': msg,
                'type': 'success',
              });
            },
            onFail: (msg) {
              isPaymentGatewayOpen = false;
              Navigator.pop(context, {'msg': msg, 'type': 'fail'});
            },
          );
        },
      ),
    );
  }

  @override
  Flutterwave setPackage(SubscriptionPackageModel modal) {
    _modal = modal;
    return this;
  }

  @override
  Flutterwave setPaymentIntent(Map<String, dynamic> paymentIntent) {
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
