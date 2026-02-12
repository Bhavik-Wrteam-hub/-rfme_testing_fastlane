import 'package:ebroker/exports/main_export.dart';

class SystemRepository {
  Future<Map<dynamic, dynamic>> fetchSystemSettings({
    required bool isAnonymouse,
  }) async {
    final response = await Api.get(
      url: Api.apiGetAppSettings,
      useAuthToken: !isAnonymouse,
    );

    return response;
  }
}
