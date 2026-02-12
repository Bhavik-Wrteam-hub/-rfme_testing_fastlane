import 'package:ebroker/utils/api.dart';

class AdvertisementRepository {
  Future<String> create({
    required String featureFor,
    String? propertyId,
    String? projectId,
  }) async {
    final parameters = <String, dynamic>{
      'feature_for': featureFor,
      if (featureFor == 'property') Api.propertyId: propertyId,
      if (featureFor == 'project') Api.projectId: projectId,
    };

    final result = await Api.post(
      url: Api.storeAdvertisement,
      parameter: parameters,
    );
    if (result['error'] == true) {
      throw ApiException(result['message']?.toString() ?? '');
    }

    return result['message']?.toString() ?? '';
  }

  Future<dynamic> deleteAdvertisment(
    String id,
  ) async {
    await Api.post(
      url: Api.deleteAdvertisement,
      parameter: {Api.id: id},
    );
  }
}
