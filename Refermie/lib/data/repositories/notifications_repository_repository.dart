import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/notification_data.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';

class NotificationsRepository {
  Future<DataOutput<NotificationData>> fetchNotifications({
    required int offset,
  }) async {
    try {
      final parameters = <String, dynamic>{
        // Api.userid: HiveUtils.getUserId(),
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
      };
      final response = await Api.get(
        url: Api.apiGetNotifications,
        queryParameters: parameters,
      );

      final modelList = (response['data'] as List).map((e) {
        return NotificationData.fromJson(e as Map<String, dynamic>? ?? {});
      }).toList();

      return DataOutput(
        total: response['total'] as int? ?? 0,
        modelList: modelList,
      );
    } on Exception catch (_) {
      rethrow;
    }
  }
}
