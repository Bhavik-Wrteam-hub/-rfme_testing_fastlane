import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString();
    final headers = options.headers;
    final data = options.data;

    final curlBuffer = StringBuffer("curl -X $method '$url'");

    // Add headers
    headers.forEach((String key, dynamic value) {
      curlBuffer.write(" -H '$key: $value'");
    });

    // Handle FormData correctly
    if (data != null) {
      if (data is FormData) {
        // Convert FormData fields to cURL format
        for (final field in data.fields) {
          curlBuffer.write(" -F '${field.key}=${field.value}'");
        }

        // Convert files in FormData
        for (final file in data.files) {
          curlBuffer.write(" -F '${file.key}=@${file.value.filename}'");
        }
      } else if (data is Map || data is List) {
        // Convert JSON to FormData format
        (data as Map<String, dynamic>).forEach((String key, dynamic value) {
          curlBuffer.write(" -F '$key=$value'");
        });
      } else {
        curlBuffer.write(" -F 'body=$data'");
      }
    }

    final curlCommand = curlBuffer.toString();

    // Use developer.log() to remove "I/flutter"
    if (kDebugMode) {
      developer.log('\n🔍 cURL Request:\n$curlCommand\n', name: 'CURL_LOG');
    }

    handler.next(options);
  }
}
