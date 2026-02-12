import 'package:ebroker/data/model/ad_banner_model.dart';
import 'package:ebroker/utils/api.dart';

class AdBannersRepository {
  Future<List<AdBanner>> fetchAdBanners({
    required String page, // homepage || property_detail
  }) async {
    final response = await Api.get(
      url: Api.getAdBanners,
      queryParameters: <String, dynamic>{
        'page': page,
        'platform': 'app',
      },
      useAuthToken: false,
    );

    final data = response['data'];
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map<AdBanner>(AdBanner.fromJson)
          .toList();
    }

    return <AdBanner>[];
  }
}
