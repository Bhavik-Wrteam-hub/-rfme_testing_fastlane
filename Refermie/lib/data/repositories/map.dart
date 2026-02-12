import 'package:ebroker/exports/main_export.dart';

class GMap {
  static Future<List<PropertyModel>> getNearByProperty(
    String city,
    String latitude,
    String longitude,
    String placeId,
  ) async {
    try {
      final response = await Api.get(
        url: Api.getPropertiesOnMap,
        queryParameters: {
          'city': city,
          'place_id': placeId,
          'latitude': latitude,
          'longitude': longitude,
        },
        useAuthToken: false,
      );
      // response.mlog('City response');
      if (response['error'] == true) {
        throw ApiException(response['message']);
      }
      final points = (response['data'] as List? ?? []).map((e) {
        return PropertyModel.fromMap(e as Map<String, dynamic>? ?? {});
      }).toList();
      return points;
    } on Exception catch (_) {
      rethrow;
    }
  }
}
