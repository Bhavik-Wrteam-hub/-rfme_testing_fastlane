//
// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaystackWidget extends StatefulWidget {
  const PaystackWidget({
    required this.pacakge,
    super.key,
    this.onSuccess,
    this.onFail,
    this.paymentIntent,
  });
  final SubscriptionPackageModel pacakge;
  final dynamic Function(dynamic msg)? onSuccess;
  final dynamic Function(dynamic msg)? onFail;
  final Map<String, dynamic>? paymentIntent;

  @override
  State<PaystackWidget> createState() => _PaystackWidgetState();
}

class _PaystackWidgetState extends State<PaystackWidget> {
  WebViewController? controllerGlobal;
  bool _isLoading = true;
  String paymentTransactionID = '';

  @override
  void initState() {
    super.initState();
    unawaited(webViewInitiliased());
  }

  Future<void> webViewInitiliased() async {
    final webViewUrl = await _getAuthorizationUrl(context);
    if (webViewUrl.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'Failed to create payment intent',
      );
      Navigator.pop(context);
      return;
    }

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    await controller.enableZoom(false);
    await controller.loadRequest(
      Uri.parse(webViewUrl),
      headers: {'Authorization': 'Bearer ${HiveUtils.getJWT()}'},
    );
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.addJavaScriptChannel(
      'Toaster',
      onMessageReceived: (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: CustomText(message.message)));
      },
    );
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) async {
          log('[PAYSTACK] onPageStarted: $url');
          log('[PAYSTACK] Transaction ID: $paymentTransactionID');
          await _updateBackButtonStatus(controller);
        },
        onPageFinished: (url) async {
          log('[PAYSTACK] onPageFinished: $url');
          await _updateBackButtonStatus(controller);
        },
        onWebResourceError: (error) {
          log(
            '[PAYSTACK] onWebResourceError: ${error.errorCode} - ${error.description}',
          );
          log('[PAYSTACK] Error URL: ${error.url}');
          log('[PAYSTACK] Error Type: ${error.errorType}');
        },
        onNavigationRequest: (request) async {
          log('[PAYSTACK] onNavigationRequest URL: ${request.url}');
          log('[PAYSTACK] isMainFrame: ${request.isMainFrame}');
          log(
            '[PAYSTACK] Contains paystack: ${request.url.contains('paystack')}',
          );
          log(
            '[PAYSTACK] Contains flutterwave: ${request.url.contains('flutterwave')}',
          );
          if (request.url.contains('paystack') ||
              request.url.contains('flutterwave')) {
            final url = request.url;
            log('[PAYSTACK] Checking payment status in URL...');
            log('[PAYSTACK] Contains success: ${url.contains('success')}');
            log('[PAYSTACK] Contains failure: ${url.contains('failure')}');
            log('[PAYSTACK] Contains cancel: ${url.contains('cancel')}');
            log(
              '[PAYSTACK] Contains status=successful: ${url.contains('status=successful')}',
            );
            if ((request.url.contains('flutterwave') &&
                    url.contains('status=successful')) ||
                (request.url.contains('paystack') && url.contains('success'))) {
              log('[PAYSTACK] ✅ Payment SUCCESS detected - popping with true');
              widget.onSuccess?.call('Payment Successful');
              Navigator.pop(context);

              return NavigationDecision.prevent;
            } else if (url.contains('failure')) {
              log('[PAYSTACK] ❌ Payment FAILURE detected');
              await paymentTransactionFail();

              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            } else if (url.contains('cancel')) {
              log('[PAYSTACK] ⚠️ Payment CANCELLED detected');
              await paymentTransactionFail();
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }
          }
          log('[PAYSTACK] Allowing navigation to proceed');
          return NavigationDecision.navigate;
        },
        onHttpError: (httpError) {
          log('[PAYSTACK] onHttpError: ${httpError.response?.statusCode}');
          log('[PAYSTACK] HTTP Error URI: ${httpError.request?.uri}');
        },
        onProgress: (progress) {
          log('[PAYSTACK] onProgress: $progress%');
        },
        onUrlChange: (change) async {
          final uri = Uri.parse(change.url ?? '');
          log('[PAYSTACK] onUrlChange: $uri');
          log('[PAYSTACK] URI Host: ${uri.host}');
          log('[PAYSTACK] URI Path: ${uri.path}');
          log('[PAYSTACK] URI PathSegments: ${uri.pathSegments}');
          log('[PAYSTACK] AppSettings.baseUrl: ${AppSettings.baseUrl}');
          log(
            '[PAYSTACK] Base URL Host: ${Uri.parse(AppSettings.baseUrl).host}',
          );
          log(
            '[PAYSTACK] Host match: ${uri.host == Uri.parse(AppSettings.baseUrl).host}',
          );
          if (uri.host == Uri.parse(AppSettings.baseUrl).host) {
            log('[PAYSTACK] Host matches baseUrl - checking path segments');
            try {
              if (uri.pathSegments.contains('success')) {
                log(
                  '[PAYSTACK] ✅ Success in path segments - calling onSuccess',
                );
                widget.onSuccess?.call('Payment Successful');
                HelperUtils.showSnackBarMessage(context, 'Payment Successful');
                Navigator.pop(context);
              } else {
                log(
                  '[PAYSTACK] ❌ No success in path segments - showing failure',
                );
                Future.delayed(Duration.zero, () {
                  HelperUtils.showSnackBarMessage(context, 'Payment Failed');
                  Navigator.pop(context);
                });
              }
            } on Exception catch (e) {
              log('[PAYSTACK] Exception caught: $e');
              Navigator.pop(context);
            }
          } else {
            log('[PAYSTACK] Host does not match baseUrl');
            log('[PAYSTACK] Checking for success/failure in URI string...');
            log(
              '[PAYSTACK] URI contains success: ${uri.toString().contains('success')}',
            );
            log(
              '[PAYSTACK] URI contains failure: ${uri.toString().contains('failure')}',
            );
            if (uri.toString().contains('success')) {
              log('[PAYSTACK] ✅ Success found in URI - calling onSuccess');
              widget.onSuccess?.call('Payment Successful');
              HelperUtils.showSnackBarMessage(context, 'Payment Successful');
              Navigator.pop(context);
              return;
            } else if (uri.toString().contains('failure')) {
              log('[PAYSTACK] ❌ Failure found in URI - calling onFail');
              widget.onFail?.call('Payment Failed');
              HelperUtils.showSnackBarMessage(context, 'Payment Failed');
              Navigator.pop(context);
              return;
            } else {
              // Don't launch external browser for payment gateway domains
              // Let the WebView handle them so we can capture the success/failure redirects
              final isPaymentGatewayUrl =
                  uri.host.contains('paystack') ||
                  uri.host.contains('flutterwave') ||
                  uri.host.contains('checkout');
              if (isPaymentGatewayUrl) {
                log(
                  '[PAYSTACK] Staying in WebView for payment gateway URL: $uri',
                );
                // Do nothing - let WebView handle it
              } else {
                log('[PAYSTACK] Launching external URL: $uri');
                await launchUrl(uri);
              }
            }
          }
        },
      ),
    );

    if (controller.platform is AndroidWebViewController) {
      await AndroidWebViewController.enableDebugging(true);
      await (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    setState(() {
      controllerGlobal = controller;
      _isLoading = false;
    });
  }

  // New method to update back button status
  Future<void> _updateBackButtonStatus(WebViewController controller) async {
    await controller.canGoBack();
    setState(() {});
  }

  Future<String> _getAuthorizationUrl(BuildContext context) async {
    final intentFromWidget = widget.paymentIntent;
    if (intentFromWidget != null && intentFromWidget.isNotEmpty) {
      paymentTransactionID =
          intentFromWidget['payment_transaction_id']?.toString() ?? '';
      final paymentGatewayResponse =
          intentFromWidget['payment_gateway_response']
              as Map<String, dynamic>? ??
          <String, dynamic>{};
      final gatewayData =
          paymentGatewayResponse['data'] as Map<String, dynamic>? ??
          <String, dynamic>{};
      final authorizationUrl = gatewayData['authorization_url']?.toString();
      if (authorizationUrl != null && authorizationUrl.isNotEmpty) {
        return authorizationUrl;
      }
    }
    return createPaymentIntent(context);
  }

  Future<String> createPaymentIntent(BuildContext context) async {
    final response = await Api.post(
      url: Api.createPaymentIntent,
      parameter: {
        'platform_type': 'app',
        'package_id': widget.pacakge.id,
        'payment_method': 'paystack',
      },
    );

    if (response['error'] == false) {
      final paymentIntent = response['data']['payment_intent'];
      final authorizationUrl =
          paymentIntent['payment_gateway_response']['data']['authorization_url']
              ?.toString();
      paymentTransactionID =
          paymentIntent['payment_transaction_id']?.toString() ?? '';

      // Redirect to Paystack's checkout page
      if (authorizationUrl != null) {
        return authorizationUrl;
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          'Authorization URL not found',
        );
      }
    } else {
      HelperUtils.showSnackBarMessage(
        context,
        'Failed to create payment intent',
      );
      return '';
    }
    return '';
  }

  Future<void> paymentTransactionFail() async {
    try {
      await Api.post(
        url: Api.paymentTransactionFail,
        parameter: {'payment_transaction_id': paymentTransactionID},
      );
    } on Exception catch (e) {
      log('Failed to cancel payment transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.secondaryColor,
      appBar: CustomAppBar(
        onTapBackButton: () async {
          HelperUtils.showSnackBarMessage(context, 'Payment Failed');
          await paymentTransactionFail();
        },
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : controllerGlobal != null
            ? WebViewWidget(controller: controllerGlobal!)
            : const Center(child: Text('Failed to load payment page')),
      ),
    );
  }
}
