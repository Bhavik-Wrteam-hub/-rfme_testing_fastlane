import 'package:dio/dio.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/transaction_model.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:hive/hive.dart';

class TransactionRepository {
  Future<DataOutput<TransactionModel>> fetchTransactions({
    required int offset,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'offset': offset,
      };

      final response = await Api.get(
        url: Api.getPaymentDetails,
        queryParameters: parameters,
      );
      if (response['error'] == true) {
        throw ApiException(response['message']);
      }

      final transactionList = (response['data'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<TransactionModel>(TransactionModel.fromMap)
          .toList();

      return DataOutput<TransactionModel>(
        total: int.parse(response['total']?.toString() ?? '0'),
        modelList: transactionList,
      );
    } on Exception catch (_) {
      throw ApiException('nodatafound');
    }
  }

  Future<String> getPaymentReceipt(String paymentTransactionId) async {
    final dio = Dio();
    final jwtToken =
        Hive.box<dynamic>(
          HiveKeys.userDetailsBox,
        ).get(HiveKeys.jwtToken)?.toString() ??
        '';
    final response = await dio.get<dynamic>(
      Constant.baseUrl + Api.getPaymentReceipt,
      queryParameters: {
        'payment_transaction_id': paymentTransactionId,
      },
      options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
    );

    return response.data.toString();
  }
}
