import 'package:ebroker/data/cubits/payment/payment_link_cubit.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalWidget extends StatefulWidget {
  const PaypalWidget({
    required this.pacakge,
    super.key,
    this.onSuccess,
    this.onFail,
  });
  final SubscriptionPackageModel pacakge;
  final dynamic Function(dynamic msg)? onSuccess;
  final dynamic Function(dynamic msg)? onFail;

  @override
  State<PaypalWidget> createState() => _PaypalWidgetState();
}

class _PaypalWidgetState extends State<PaypalWidget> {
  WebViewController? controllerGlobal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_initializePaymentLink());
  }

  Future<void> _initializePaymentLink() async {
    try {
      final paymentLinkCubit = context.read<PaymentLinkCubit>();
      await paymentLinkCubit.fetchLink(
        packageId: widget.pacakge.id,
        gateway: 'paypal',
        amount: widget.pacakge.price.toDouble(),
      );

      final state = paymentLinkCubit.state;
      if (state is PaymentLinkSuccess && state.link.isNotEmpty) {
        await _initializeWebView(state.link);
      } else if (state is PaymentLinkFailure) {
        _handleInitializationError(state.error.toString());
      } else {
        _handleInitializationError('purchaseFailed'.translate(context));
      }
    } on Exception catch (e) {
      _handleInitializationError(e.toString());
    }
  }

  void _handleInitializationError(String errorMessage) {
    setState(() {
      isLoading = false;
    });
    HelperUtils.showSnackBarMessage(
      context,
      errorMessage,
      type: .error,
    );
    widget.onFail?.call(errorMessage);
    Navigator.of(context).pop();
  }

  Future<void> _initializeWebView(String link) async {
    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final controller = WebViewController.fromPlatformCreationParams(params);
    await controller.enableZoom(false);
    await controller.loadRequest(
      Uri.parse(link),
      headers: {'Authorization': 'Bearer ${HiveUtils.getJWT()}'},
    );
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.addJavaScriptChannel(
      'Toaster',
      onMessageReceived: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: CustomText(message.message)),
        );
      },
    );
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onUrlChange: (change) {
          final uri = Uri.parse(change.url ?? '');

          final payerID = uri.queryParameters['PayerID'];
          if (uri.host == Uri.parse(AppSettings.baseUrl).host &&
              uri.pathSegments.contains('app_payment_status')) {
            try {
              if (uri.queryParameters['error'] == 'false' && payerID != null) {
                widget.onSuccess?.call('Payment Successful');
              } else {
                Future.delayed(
                  Duration.zero,
                  () {
                    widget.onFail?.call('Payment Failed');
                    Navigator.pop(context);
                  },
                );
              }
            } on Exception catch (e) {
              widget.onFail?.call(e.toString());
              Navigator.pop(context);
            }
          }
        },
      ),
    );

    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }

    setState(() {
      controllerGlobal = controller;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: context.color.tertiaryColor,
          ),
        ),
      );
    }

    if (controllerGlobal == null) {
      return Scaffold(
        body: Center(
          child: CustomText('errorLoadingPayment'.translate(context)),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await controllerGlobal!.canGoBack()) {
          await controllerGlobal!.goBack();
          setState(() {});
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pop();
          });
        } else {
          setState(() {});
          return Future.value(false);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: controllerGlobal!),
        ),
      ),
    );
  }
}
