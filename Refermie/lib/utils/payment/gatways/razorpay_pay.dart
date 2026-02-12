import 'dart:developer';

import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/purchase_package.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPay extends Payment {
  late SubscriptionPackageModel? _model;
  Map<String, dynamic>? _paymentIntent;
  String? orderId;
  String? paymentTransactionID;

  @override
  Future<void> onEvent(
    BuildContext context,
    covariant PaymentStatus currentStatus,
  ) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }

  Future<bool> createPaymentIntent(BuildContext context) async {
    try {
      final response = await Api.post(
        url: Api.createPaymentIntent,
        parameter: {
          'platform_type': 'app',
          'package_id': _model!.id,
          'payment_method': 'razorpay',
        },
      );

      if (response['error'] == false) {
        // Extract the required data from the API response
        orderId = response['data']['payment_intent']['id']?.toString();
        paymentTransactionID =
            response['data']['payment_intent']['payment_transaction_id']
                ?.toString();

        return true;
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          'Failed to create payment intent: ${response['message']}',
        );
        return false;
      }
    } on Exception catch (e) {
      HelperUtils.showSnackBarMessage(
        context,
        'Failed to create payment intent: $e',
      );
      return false;
    }
  }

  Future<void> paymentTransactionFail() async {
    try {
      await Api.post(
        url: Api.paymentTransactionFail,
        parameter: {
          'payment_transaction_id': paymentTransactionID,
        },
      );
    } on Exception catch (e) {
      log('Failed to cancel payment transaction: $e');
    }
  }

  @override
  Future<void> pay(BuildContext context) async {
    if (_paymentIntent == null) {
      final success = await createPaymentIntent(context);
      if (!success) return;
    } else {
      orderId = _paymentIntent?['id']?.toString();
      paymentTransactionID = _paymentIntent?['payment_transaction_id']
          ?.toString();
    }

    final razorpay = Razorpay();

    // Use the data from the payment intent
    final options = {
      'key': Constant.razorpayKey,
      'amount': _model!.price, // Use the amount from API response
      'order_id': orderId, // Use the order ID from API response
      'name': _model!.name,
      'description': '',
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile,
        'email': HiveUtils.getUserDetails().email,
      },
      'notes': {
        'package_id': _model!.id,
        'user_id': HiveUtils.getUserId(),
        'payment_transaction_id': paymentTransactionID,
      },
    };

    if (Constant.razorpayKey != '') {
      isPaymentGatewayOpen = true;

      razorpay
        ..open(options)
        ..on(
          Razorpay.EVENT_PAYMENT_SUCCESS,
          (
            PaymentSuccessResponse response,
          ) async {
            isPaymentGatewayOpen = false;
            emit(Success(message: 'Success'));
          },
        )
        ..on(
          Razorpay.EVENT_PAYMENT_ERROR,
          (PaymentFailureResponse response) async {
            isPaymentGatewayOpen = false;
            emit(Failure(message: 'failure'));
            HelperUtils.showSnackBarMessage(
              context,
              'purchaseFailed',
            );
            await paymentTransactionFail();
          },
        )
        ..on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse e) async {
          isPaymentGatewayOpen = false;
          await paymentTransactionFail();
          log('ISSUE IS ON RAZORPAY ITSELF $e');
        })
        ..on(
          Razorpay.EVENT_EXTERNAL_WALLET,
          (ExternalWalletResponse e) {
            log('External wallet response is $e');
          },
        );
    } else {
      await paymentTransactionFail();
      HelperUtils.showSnackBarMessage(
        context,
        'setAPIkey',
      );
    }
  }

  @override
  Payment setPackage(SubscriptionPackageModel modal) {
    _model = modal;
    return this;
  }

  @override
  RazorpayPay setPaymentIntent(Map<String, dynamic> paymentIntent) {
    _paymentIntent = paymentIntent;
    orderId = paymentIntent['id']?.toString();
    paymentTransactionID = paymentIntent['payment_transaction_id']?.toString();
    return this;
  }
}
