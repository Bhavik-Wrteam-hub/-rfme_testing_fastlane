import 'package:ebroker/exports/main_export.dart';

class PaymentLinkRepository {
  Future<String> fetchPaymentLink({
    required int packageId,
    required String gateway,
    double? amount,
  }) async {
    final normalizedGateway = gateway.toLowerCase();
    switch (normalizedGateway) {
      case 'flutterwave':
        return _fetchFlutterwaveLink(packageId);
      case 'paypal':
        return _fetchPaypalLink(packageId, amount);
      default:
        throw Exception('Unsupported payment gateway: $gateway');
    }
  }

  Future<String> _fetchFlutterwaveLink(int packageId) async {
    final response = await Api.post(
      url: Api.flutterwave,
      parameter: {'package_id': packageId},
    );

    if (response['error'] == false) {
      final data = response['data'] as Map<String, dynamic>?;
      final link = data?['data']?['link']?.toString() ?? '';
      if (link.isNotEmpty) {
        return link;
      }
    }

    throw Exception(
      response['message'] ?? 'Failed to fetch flutterwave link',
    );
  }

  Future<String> _fetchPaypalLink(int packageId, double? amount) async {
    final queryParameters = <String, dynamic>{
      'package_id': packageId,
    };

    if (amount != null) {
      queryParameters['amount'] = amount;
    }

    // Make the API call to verify it works and get the HTML response
    final response = await Api.get(
      url: Api.paypal,
      queryParameters: queryParameters,
    );

    // The API returns HTML (a string), which is wrapped in {'data': htmlString}
    // Check if we got a valid HTML response
    final data = response['data'];

    if (data is String && data.isNotEmpty) {
      // If we got HTML back, construct and return the API URL
      // The WebView will load this URL, which returns the HTML that auto-submits to PayPal
      final baseUrl = Constant.baseUrl;
      final url = Uri.parse('$baseUrl${Api.paypal}');
      final uri = url.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
      return uri.toString();
    }

    // If response indicates an error
    if (response['error'] == true) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to fetch paypal link',
      );
    }

    throw Exception('Failed to fetch paypal link: Invalid response format');
  }
}
