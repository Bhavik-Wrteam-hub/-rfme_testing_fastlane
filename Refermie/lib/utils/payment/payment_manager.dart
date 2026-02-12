import 'package:ebroker/data/cubits/payment/payment_intent_cubit.dart';
import 'package:ebroker/data/cubits/payment/payment_link_cubit.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/gatways/flutterwave_pay.dart';
import 'package:ebroker/utils/payment/gatways/paypal_pay.dart';
import 'package:ebroker/utils/payment/gatways/paystack_pay.dart';
import 'package:ebroker/utils/payment/gatways/razorpay_pay.dart';
import 'package:ebroker/utils/payment/gatways/stripe_pay.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';

class PaymentManager {
  PaymentManager({
    required PaymentIntentCubit paymentIntentCubit,
    required PaymentLinkCubit paymentLinkCubit,
  }) : _paymentIntentCubit = paymentIntentCubit,
       _paymentLinkCubit = paymentLinkCubit;

  final PaymentIntentCubit _paymentIntentCubit;
  final PaymentLinkCubit _paymentLinkCubit;

  Future<void> pay({
    required BuildContext context,
    required SubscriptionPackageModel package,
    required String gatewayKey,
  }) async {
    final targetGatewayKey = gatewayKey.toLowerCase();
    final requiresPaymentIntent = !_isLinkBasedGateway(targetGatewayKey);
    var preparedIntent = <String, dynamic>{};
    try {
      if (requiresPaymentIntent) {
        final intent = await _paymentIntentCubit.createIntent(
          packageId: package.id,
          paymentMethod: targetGatewayKey,
        );

        if (intent == null) {
          HelperUtils.showSnackBarMessage(
            context,
            'purchaseFailed',
            type: .error,
          );
          return;
        }
        preparedIntent = intent;
      }

      final payment = _resolveGateway(targetGatewayKey)
        ..setPackage(package)
        ..setPaymentIntent(preparedIntent);

      payment.listen((status) {
        payment.onEvent(context, status);
        if (_isLinkBasedGateway(targetGatewayKey) &&
            (status is Success || status is Failure)) {
          _paymentLinkCubit.clear();
        }
      });

      await payment.pay(context);
    } on Exception catch (e) {
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
    } finally {
      if (_isLinkBasedGateway(targetGatewayKey)) {
        _paymentLinkCubit.clear();
      }
    }
  }

  Payment _resolveGateway(String gatewayKey) {
    switch (gatewayKey.toLowerCase()) {
      case 'paypal':
        return Paypal();
      case 'paystack':
        return Paystack();
      case 'razorpay':
        return RazorpayPay();
      case 'flutterwave':
        return Flutterwave();
      case 'stripe':
      default:
        return Stripe();
    }
  }

  bool _isLinkBasedGateway(String gatewayKey) {
    return gatewayKey == 'paypal' || gatewayKey == 'flutterwave';
  }
}
