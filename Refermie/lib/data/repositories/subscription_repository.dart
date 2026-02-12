import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/utils/api.dart';

class SubscriptionRepository {
  Future<PackageResponseModel> getSubscriptionPackages({
    required int offset,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getPackage,
        queryParameters: {
          if (Platform.isIOS) 'platform_type': 'ios',
          // "current_user": HiveUtils.getUserId()
        },
      );
      if (response['error'] == true) {
        throw Exception(response['message']);
      }
      final result = PackageResponseModel.fromJson(response);

      return result;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getPackageLimit({
    required String limitType,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'type': limitType,
      };
      final response = await Api.get(
        url: Api.apiCheckPackageLimit,
        queryParameters: parameters,
      );

      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> assignFreePackage(int packageId) async {
    await Api.post(
      url: Api.assignPackage,
      parameter: {'package_id': packageId, 'in_app': false},
    );
  }

  Future<void> assignPackage({
    required String packageId,
    required String productId,
  }) async {
    try {
      await Api.post(
        url: Api.assignPackage,
        parameter: {
          'package_id': packageId,
          'product_id': productId,
          'in_app': true,
        },
      );
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiateBankTransfer({
    required String packageId,
    required MultipartFile? file,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'package_id': packageId,
        'file': file,
      };
      final response = await Api.post(
        url: Api.initiateBankTransfer,
        parameter: parameters,
      );
      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> uploadBankReceiptFile({
    required String paymentTransactionId,
    required MultipartFile file,
  }) async {
    try {
      final response = await Api.post(
        url: Api.uploadBankReceiptFile,
        parameter: {
          'payment_transaction_id': paymentTransactionId,
          'file': file,
        },
      );

      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }
}
